from odoo import http
from odoo.http import request
from ..setup.jwt_token import JwtToken
import logging

_logger = logging.getLogger(__name__)


class ApiAuth(http.Controller):

    @http.route('/api/authenticate', type='json', auth='none', methods=['POST'], csrf=False)
    def authenticate_post(self, **kwargs):
        # Extraer parámetros - Odoo puede enviarlos de varias formas
        params = {}
        
        # Intentar obtener de jsonrequest primero
        if hasattr(request, 'jsonrequest') and request.jsonrequest:
            params = request.jsonrequest.get('params', request.jsonrequest)
        
        # Si no hay params, intentar desde kwargs
        if not params:
            params = kwargs
        
        login = params.get('login')
        password = params.get('password')
        db_name = params.get('db') or request.db or request.session.db

        if not login or not password:
            return {"error": "Please provide login and password"}

        try:
            uid = request.session.authenticate(db_name, login, password)
            if not uid:
                return {"error": "Invalid login or password"}
        except Exception as e:
            return {"error": "Authentication failed: %s" % str(e)}

        try:
            user = request.env['res.users'].browse(uid)
            user_info = self._get_user_info(uid)

            # Generar tokens
            access_token = JwtToken.generate_token(uid, extra_payload={
                'user_id': uid,
                'email': user.login,
                'active': user.active,
                'has_subscription': user_info['has_subscription'],
                'subscription_level': user_info['subscription_level'],
                'role': user_info['role']
            })
            refresh_token = JwtToken.create_refresh_token(request, uid)
            rotation_period = JwtToken.REFRESH_TOKEN_SECONDS * 3/4

            res_data = {
                'rotation_period': rotation_period,
                'token': access_token,
                'user_id': uid,
                'long_term_token_span': JwtToken.REFRESH_TOKEN_SECONDS,
                'short_term_token_span': JwtToken.ACCESS_TOKEN_SECONDS,
                'user': {
                    'id': uid,
                    'nom': user.name,
                }
            }

            # Verificar si es navegador
            user_agent = request.httprequest.user_agent
            is_browser = user_agent.browser if user_agent else False
            if not is_browser:
                res_data['refreshToken'] = refresh_token

            return res_data

        except Exception as exc:
            return {"error": str(exc)}

    @staticmethod
    def _get_user_info(uid):
        user = request.env['res.users'].sudo().browse(uid)
        if not user:
            return {'has_subscription': False, 'subscription_level': None, 'role': 'none'}

        # Determinar rol
        role = 'other'
        if user.has_group('base.group_system'):
            role = 'admin'
        elif user.has_group('base.group_user'):
            role = 'user'

        # Determinar suscripción
        subscription = request.env['subscription.subscription'].sudo().search([
            ('partner_id', '=', user.partner_id.id),
            ('state', '=', 'active')
        ], limit=1)

        return {
            'has_subscription': bool(subscription),
            'subscription_level': subscription.subscription_tier if subscription else None,
            'role': role
        }

    @staticmethod
    def _user_has_active_subscription(uid):
        # Mantenido por compatibilidad si es necesario, pero _get_user_info es preferido
        user = request.env['res.users'].sudo().browse(uid)
        if not user:
            return False

        has_subscription = bool(
            request.env['subscription.subscription']
            .sudo()
            .search([
                ('partner_id', '=', user.partner_id.id),
                ('state', '=', 'active')
            ], limit=1)
        )
        return has_subscription

    @http.route('/api/update/access-token', type='json', auth='none', methods=['POST'], csrf=False)
    def updated_short_term_token(self, **kwargs):
        # Extraer parámetros - compatible con múltiples formatos
        params = {}
        if hasattr(request, 'jsonrequest') and request.jsonrequest:
            params = request.jsonrequest.get('params', request.jsonrequest)
        if not params:
            params = kwargs
        
        user_id = params.get('user_id')
        if not user_id:
            return {'error': 'User id not given'}
        
        user_id = int(user_id)

        # Obtener refresh token desde cookies, headers o body
        long_term_token = self.get_refresh_token(request)
        
        if not long_term_token:
            return {'error': 'Refresh token not provided'}

        try:
            # Verificar el refresh token
            JwtToken.verify_refresh_token(request, user_id, long_term_token)
            
            # Obtener datos del usuario para incluir en el nuevo token
            user = request.env['res.users'].sudo().browse(user_id)
            user_info = self._get_user_info(user_id)
            
            # Generar nuevo access token con los mismos datos extra
            new_token = JwtToken.generate_token(user_id, extra_payload={
                'email': user.login,
                'active': user.active,
                'has_subscription': user_info['has_subscription'],
                'subscription_level': user_info['subscription_level'],
                'role': user_info['role']
            })
            
            return {'access_token': new_token}
        except Exception as e:
            return {'error': str(e)}

    @http.route('/api/update/refresh-token', type='json', auth='jwt', methods=['POST'], csrf=False)
    def updated_long_term_token(self, **kwargs):
        # Extraer parámetros - compatible con múltiples formatos
        params = {}
        if hasattr(request, 'jsonrequest') and request.jsonrequest:
            params = request.jsonrequest.get('params', request.jsonrequest)
        if not params:
            params = kwargs
        
        user_id = params.get('user_id')
        if not user_id:
            # Si no viene user_id, usar el del usuario autenticado
            user_id = request.env.user.id
        else:
            user_id = int(user_id)

        old_token = self.get_refresh_token(request)
        
        if not old_token:
            return {'error': 'Refresh token not provided'}

        try:
            JwtToken.verify_refresh_token(request, user_id, old_token)
            new_token = JwtToken.create_refresh_token(request, user_id)

            res_data = {'status': 'done'}
            user_agent = request.httprequest.user_agent
            is_browser = user_agent.browser if user_agent else False
            
            if not is_browser:
                res_data['refreshToken'] = new_token
            else:
                res_data['refreshToken'] = 1
                if hasattr(request, 'future_response'):
                    request.future_response.set_cookie(
                        'refreshToken', 
                        new_token, 
                        httponly=True, 
                        secure=True, 
                        samesite='Lax'
                    )
            
            return res_data
        except Exception as e:
            return {'error': str(e)}

    @http.route('/api/revoke/token', type='json', auth='jwt', methods=['POST'], csrf=False)
    def revoke_api_token(self, **kwargs):
        # Extraer parámetros - compatible con múltiples formatos
        params = {}
        if hasattr(request, 'jsonrequest') and request.jsonrequest:
            params = request.jsonrequest.get('params', request.jsonrequest)
        if not params:
            params = kwargs
        
        user_id = params.get('user_id')
        if not user_id:
            user_id = request.env.user.id
        else:
            user_id = int(user_id)

        long_term_token = self.get_refresh_token(request)
        
        if not long_term_token:
            return {'error': 'Refresh token not provided'}

        try:
            JwtToken.verify_refresh_token(request, user_id, long_term_token)
            tok_ob = request.env['jwt.refresh_token'].sudo().search([('user_id', '=', user_id)])
            if tok_ob:
                tok_ob.is_revoked = True
            return {'status': 'success', 'logged_out': 1}
        except Exception as e:
            return {'error': str(e)}

    @http.route('/api/protected/test', type='json', auth='jwt', methods=['POST'], csrf=False)
    def protected_users_json(self):
        uob = request.env.user
        users = [{'id': 1, 'name': 'sami3'}]
        user_data = [{'id': user['id'], 'name': user['name']} for user in users]
        return {'uid': uob.id, 'data': user_data}

    @http.route('/api/me', type='json', auth='jwt', methods=['POST'], csrf=False)
    def api_me(self):
        uob = request.env.user
        user_info = self._get_user_info(uob.id)
        return {
            'id': uob.id,
            'nom': uob.name,
            'email': uob.login,
            'active': uob.active,
            'has_subscription': user_info['has_subscription'],
            'subscription_level': user_info['subscription_level'],
            'role': user_info['role']
        }

    @classmethod
    def get_refresh_token(cls, req_obj):
        key_name = 'refreshToken'
        http_req = req_obj.httprequest
        long_term_token = None
        
        # 1. Intentar obtener desde cookies
        long_term_token = http_req.cookies.get(key_name)
        _logger.info("=== GET REFRESH TOKEN DEBUG ===")
        _logger.info("From cookies: %s", long_term_token)
        
        # 2. Intentar desde headers
        if not long_term_token:
            long_term_token = http_req.headers.get(key_name)
            _logger.info("From headers: %s", long_term_token)
        
        # 3. Intentar desde el JSON body (params)
        if not long_term_token:
            if hasattr(req_obj, 'jsonrequest') and req_obj.jsonrequest:
                # Primero intentar desde params
                params = req_obj.jsonrequest.get('params', {})
                long_term_token = params.get('refreshToken') or params.get(key_name)
                _logger.info("From params: %s", long_term_token)
                
                # Si no está en params, intentar directamente en jsonrequest
                if not long_term_token:
                    long_term_token = req_obj.jsonrequest.get('refreshToken') or req_obj.jsonrequest.get(key_name)
                    _logger.info("From jsonrequest direct: %s", long_term_token)
        
        _logger.info("Final token: %s", long_term_token)
        return long_term_token