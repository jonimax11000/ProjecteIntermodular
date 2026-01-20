from odoo import http
from odoo.http import request
from ..setup.jwt_token import JwtToken


class ApiAuth(http.Controller):

    @http.route('/api/authenticate', type='json', auth='none', methods=['POST'], csrf=False)
    def authenticate_post(self, **kwargs):
        # Robust parameter extraction
        params = kwargs
        if not params:
            try:
                params = request.httprequest.json
            except:
                pass
        if not params:
            params = request.params

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
            # Log the actual exception for debugging purposes if needed
            return {"error": "Authentication failed: %s" % str(e)}
        
        try:
            access_token = JwtToken.generate_token(uid)
            refresh_token = JwtToken.create_refresh_token(request, uid)
            rotation_period = JwtToken.REFRESH_TOKEN_SECONDS * 3/4
            res_data = {
                'rotation_period': rotation_period,
                'token': access_token, 
                'user_id': uid,
                'long_term_token_span': JwtToken.REFRESH_TOKEN_SECONDS,
                'short_term_token_span': JwtToken.ACCESS_TOKEN_SECONDS,
            }
            # Accessing user_agent safely
            user_agent = request.httprequest.user_agent
            is_browser = user_agent.browser if user_agent else False
            
            if not is_browser:
                res_data['refreshToken'] = refresh_token
            return res_data
        except Exception as exc:
            return {"error": str(exc)}

    @http.route('/api/update/access-token', type='json', auth='none', csrf=False)
    def updated_short_term_token(self, **kwargs):
        params = kwargs
        if not params:
             try:
                params = request.httprequest.json
             except:
                pass
        
        user_id = params.get('user_id')
        if not user_id:
            return {'error': 'User id not given'}
        user_id = int(user_id)
        long_term_token = self.__class__.get_refresh_token(request)
        JwtToken.verify_refresh_token(request, user_id, long_term_token)
        new_token = JwtToken.generate_token(user_id)
        return {'access_token': new_token }

    # will be called after for rotation of long term refresh-tokens from client (if rotation_period>=0)
    @http.route('/api/update/refresh-token', type='json', auth='jwt', methods=['POST'], csrf=False)
    def updated_long_term_token(self, **kwargs):
        params = kwargs
        if not params:
             try:
                params = request.httprequest.json
             except:
                pass

        user_id = params.get('user_id')
        if user_id:
            user_id = int(user_id)
        old_token = self.get_refresh_token(request)
        JwtToken.verify_refresh_token(request, user_id, old_token)
        new_token = JwtToken.create_refresh_token(request, user_id)
        res_data = {'status': 'done'}
        user_agent = request.httprequest.user_agent
        is_browser = user_agent.browser if user_agent else False
        if not is_browser:
            res_data['refreshToken'] = new_token
        else:
            res_data['refreshToken'] = 1
            request.future_response.set_cookie('refreshToken', new_token, httponly=True, secure=True, samesite='Lax')
        return res_data

    @http.route('/api/revoke/token', type='json', auth='jwt', methods=['POST'], csrf=False)
    def revoke_api_token(self, **kwargs):
        params = kwargs
        if not params:
             try:
                params = request.httprequest.json
             except:
                pass
        
        user_id = params.get('user_id')
        if user_id:
            user_id = int(user_id)
        tok_ob = request.env['jwt.refresh_token'].sudo().search([('user_id', '=', user_id)])
        # will update the access token, so will become inaccessible immediately
        long_term_token = self.get_refresh_token(request)
        JwtToken.verify_refresh_token(request, user_id, long_term_token)
        tok_ob.is_revoked = True
        return {'status': 'success', 'logged_out': 1}

    @http.route('/api/protected/test', type='json', auth='jwt', methods=['POST'], csrf=False)
    def protected_users_json(self):
        uob = request.env.user
        users = [{'id': 1, 'name': 'sami3'}]
        user_data = [{'id': user['id'], 'name': user['name']} for user in users]
        return {'uid': uob.id, 'data': user_data}

    @classmethod
    def get_refresh_token(cls, req_obj):
        key_name = 'refreshToken'
        http_req = req_obj.httprequest
        long_term_token = http_req.cookies.get(key_name)
        if not long_term_token:
            long_term_token = http_req.headers.get(key_name)
        return long_term_token


