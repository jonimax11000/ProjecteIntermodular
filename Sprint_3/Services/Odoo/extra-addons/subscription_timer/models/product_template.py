from odoo import models, fields, api

class ProductTemplate(models.Model):
    _inherit = 'product.template'
    
    is_subscription = fields.Boolean(
        string='Es Suscripción',
        default=False,
        help='Marca si este producto es un plan de suscripción'
    )
    
    subscription_days = fields.Integer(
        string='Días de Suscripción',
        default=30,
        help='Número de días que dura la suscripción'
    )
    
    subscription_tier = fields.Selection(
        [('1', 'Cobre'), ('2', 'Plata'), ('3', 'Oro')],
        string='Nivel de Suscripción',
        help='Nivel de suscripción: 1=Cobre, 2=Plata, 3=Oro'
    )