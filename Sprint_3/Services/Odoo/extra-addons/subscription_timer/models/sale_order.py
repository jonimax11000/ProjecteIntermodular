from odoo import models, api, _
from odoo.exceptions import UserError

class SaleOrder(models.Model):
    _inherit = 'sale.order'
    
    def _cart_update(self, product_id=None, line_id=None, add_qty=0, set_qty=0, **kwargs):
        """Prevenir añadir suscripción al carrito si ya tiene una activa y limitar a 1"""
        try:
            f_add = float(add_qty or 0)
            f_set = float(set_qty or 0)
        except (ValueError, TypeError):
            f_add = 0
            f_set = 0

        # Identificar el producto y la línea
        product = self.env['product.product'].browse(product_id) if product_id else None
        line = self.env['sale.order.line'].browse(line_id) if line_id else None
        if not product and line:
            product = line.product_id
        if not line and product:
            line = self.order_line.filtered(lambda l: l.product_id.id == product.id)[:1]

        if product and product.product_tmpl_id.is_subscription:
            current_qty = line.product_uom_qty if line else 0
            # Determinar la cantidad objetivo aproximada para decidir si bloqueamos
            target_qty = f_set if f_set > 0 else (current_qty + f_add)
            
            if target_qty > current_qty:
                # Bloquear solo si estamos intentando AUMENTAR y ya tiene una suscripción activa
                active_sub = self.env['subscription.subscription'].search([
                    ('partner_id', '=', self.partner_id.id),
                    ('state', '=', 'active'),
                ], limit=1)
                if active_sub:
                    raise UserError(_("Ya tienes una suscripción activa ('%s'). No puedes comprar otra hasta que esa expire.") % active_sub.product_id.name)
                
                # Forzar máximo 1 en el carrito
                if target_qty > 1:
                    if f_set > 1:
                        set_qty = 1
                    elif f_add > 0:
                        add_qty = max(0, 1 - current_qty)

        return super(SaleOrder, self)._cart_update(product_id=product_id, line_id=line_id, add_qty=add_qty, set_qty=set_qty, **kwargs)

    def action_confirm(self):
        """Sobrescribir para crear suscripciones al confirmar pedido"""
        # Verificar si el cliente ya tiene una suscripción activa antes de confirmar
        for order in self:
            for line in order.order_line:
                if line.product_id.product_tmpl_id.is_subscription:
                    active_sub = self.env['subscription.subscription'].search([
                        ('partner_id', '=', order.partner_id.id),
                        ('state', '=', 'active'),
                    ], limit=1)
                    if active_sub:
                        raise UserError(_("El cliente ya tiene una suscripción activa ('%s'). No puede comprar otra hasta que la actual expire.") % active_sub.product_id.name)

        res = super(SaleOrder, self).action_confirm()
        
        for order in self:
            for line in order.order_line:
                if line.product_id.product_tmpl_id.is_subscription:
                    # Crear la suscripción
                    self.env['subscription.subscription'].create({
                        'partner_id': order.partner_id.id,
                        'product_id': line.product_id.id,
                        'sale_order_id': order.id,
                        'total_days': line.product_id.product_tmpl_id.subscription_days,
                        'state': 'active',
                    })
        
        return res