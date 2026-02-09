from odoo import http
from odoo.http import request
from odoo.addons.portal.controllers.portal import CustomerPortal

class SubscriptionPortal(CustomerPortal):
    
    def _prepare_home_portal_values(self, counters):
        """Agregar contador de suscripciones activas en la página principal"""
        values = super()._prepare_home_portal_values(counters)
        partner = request.env.user.partner_id
        
        if 'subscription_count' in counters:
            subscription_count = request.env['subscription.subscription'].sudo().search_count([
                ('partner_id', '=', partner.id),
                ('state', '=', 'active')
            ])
            values['subscription_count'] = subscription_count
        
        return values
    
    @http.route(['/my/subscriptions'], type='http', auth="user", website=True)
    def portal_my_subscriptions(self, **kw):
        partner = request.env.user.partner_id
        
        active_subscriptions = request.env['subscription.subscription'].sudo().search([
            ('partner_id', '=', partner.id),
            ('state', '=', 'active')
        ])
        
        expired_subscriptions = request.env['subscription.subscription'].sudo().search([
            ('partner_id', '=', partner.id),
            ('state', 'in', ['expired', 'cancelled'])
        ])
        
        values = {
            'active_subscriptions': active_subscriptions,
            'expired_subscriptions': expired_subscriptions,
            'page_name': 'subscription',
        }
        
        return request.render("subscription_timer.portal_my_subscriptions", values)

    @http.route(['/my/subscription/toggle_auto_renew/<int:sub_id>'], type='http', auth="user", website=True)
    def portal_subscription_toggle_auto_renew(self, sub_id, **kw):
        subscription = request.env['subscription.subscription'].sudo().browse(sub_id)
        if subscription and subscription.partner_id.id == request.env.user.partner_id.id:
            subscription.action_toggle_auto_renew()
        return request.redirect('/my/subscriptions')

    @http.route(['/my/subscription/cancel/<int:sub_id>'], type='http', auth="user", website=True)
    def portal_subscription_cancel(self, sub_id, **kw):
        subscription = request.env['subscription.subscription'].sudo().browse(sub_id)
        if subscription and subscription.partner_id.id == request.env.user.partner_id.id:
            subscription.action_cancel()
        return request.redirect('/my/subscriptions')