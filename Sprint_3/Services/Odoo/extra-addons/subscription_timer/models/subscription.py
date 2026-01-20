from odoo import models, fields, api
from datetime import datetime, timedelta

class Subscription(models.Model):
    _name = 'subscription.subscription'
    _description = 'Suscripción del Cliente'
    _order = 'start_date desc'
    
    name = fields.Char(string='Referencia', required=True, copy=False, readonly=True, default='Nuevo')
    partner_id = fields.Many2one('res.partner', string='Cliente', required=True, ondelete='cascade')
    product_id = fields.Many2one('product.product', string='Producto', required=True, domain=[('product_tmpl_id.is_subscription', '=', True)])
    subscription_tier = fields.Selection(related='product_id.subscription_tier', string='Nivel de Suscripción', readonly=True, store=True)
    sale_order_id = fields.Many2one('sale.order', string='Pedido de Venta')
    auto_renew = fields.Boolean(string='Auto-renovar', default=False)
    
    start_date = fields.Date(string='Fecha de Inicio', default=fields.Date.today, required=True)
    end_date = fields.Date(string='Fecha de Fin', compute='_compute_end_date', store=True)
    
    total_days = fields.Integer(string='Total de Días', required=True)
    days_remaining = fields.Integer(string='Días Restantes', compute='_compute_days_remaining', store=True)
    
    state = fields.Selection([
        ('active', 'Activa'),
        ('expired', 'Expirada'),
        ('cancelled', 'Cancelada')
    ], string='Estado', default='active', required=True)
    
    progress = fields.Float(string='Progreso (%)', compute='_compute_progress')
    
    @api.model
    def create(self, vals):
        if vals.get('name', 'Nuevo') == 'Nuevo':
            vals['name'] = self.env['ir.sequence'].next_by_code('subscription.subscription') or 'SUB/'
        return super(Subscription, self).create(vals)
    
    @api.depends('start_date', 'total_days')
    def _compute_end_date(self):
        for record in self:
            if record.start_date and record.total_days:
                record.end_date = record.start_date + timedelta(days=record.total_days)
            else:
                record.end_date = False
    
    @api.depends('end_date', 'state')
    def _compute_days_remaining(self):
        today = fields.Date.today()
        for record in self:
            if record.state == 'expired':
                record.days_remaining = 0
            elif record.end_date:
                delta = record.end_date - today
                record.days_remaining = max(0, delta.days)
            else:
                record.days_remaining = 0
    
    @api.depends('total_days', 'days_remaining')
    def _compute_progress(self):
        for record in self:
            if record.total_days > 0:
                elapsed = record.total_days - record.days_remaining
                record.progress = (elapsed / record.total_days) * 100
            else:
                record.progress = 0
    
    def action_check_expiration(self):
        """Método llamado por el cron para verificar expiraciones"""
        today = fields.Date.today()
        subscriptions = self.search([('state', '=', 'active'), ('end_date', '<=', today)])
        
        for subscription in subscriptions:
            if subscription.auto_renew:
                # Crear una nueva suscripción
                self.create({
                    'partner_id': subscription.partner_id.id,
                    'product_id': subscription.product_id.id,
                    'sale_order_id': subscription.sale_order_id.id,
                    'total_days': subscription.total_days,
                    'start_date': subscription.end_date, # Empieza donde terminó la anterior
                    'auto_renew': True,
                    'state': 'active',
                })
            subscription.write({'state': 'expired'})
        
        return True

    def action_toggle_auto_renew(self):
        for record in self:
            record.auto_renew = not record.auto_renew

    def action_cancel(self):
        for record in self:
            record.write({'state': 'cancelled'})