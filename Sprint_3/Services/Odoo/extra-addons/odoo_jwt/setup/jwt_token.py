import os
import jwt
from datetime import datetime, timedelta

from odoo import tools
from odoo.exceptions import AccessDenied


file_private_key = os.path.join(os.path.dirname(__file__), "private_key.pem")
file_public_key = os.path.join(os.path.dirname(__file__), "public_key.pem")


class JwtToken:
    JWT_ALGORITHM = "RS256"
    ACCESS_TOKEN_SECONDS = 6000  # Aumentado para pruebas, ajustar según necesidad
    REFRESH_TOKEN_SECONDS = 86400

    @classmethod
    def _read_key(cls, path):
        if os.path.exists(path):
            with open(path, "r") as f:
                return f.read()
        return None

    @classmethod
    def get_private_key(cls):
        key = cls._read_key(file_private_key)
        if not key:
            raise Exception("Private key not found at %s" % file_private_key)
        return key

    @classmethod
    def get_public_key(cls):
        key = cls._read_key(file_public_key)
        if not key:
            raise Exception("Public key not found at %s" % file_public_key)
        return key

    @classmethod
    def generate_token(cls, user_id, duration=0, extra_payload=None):
        if not duration:
            duration = cls.ACCESS_TOKEN_SECONDS

        payload = {
            "user_id": user_id,
            "exp": datetime.utcnow() + timedelta(seconds=duration),
        }

        if extra_payload:
            payload.update(extra_payload)

        private_key = cls.get_private_key()
        return jwt.encode(payload, private_key, algorithm=cls.JWT_ALGORITHM)

    @classmethod
    def create_refresh_token(cls, req, uid):
        new_token = cls.generate_token(uid, JwtToken.REFRESH_TOKEN_SECONDS)
        refresh_model = req.env["jwt.refresh_token"].sudo()
        existing_token = refresh_model.search([("user_id", "=", uid)])
        if existing_token:
            existing_token.write({"stored_token": new_token, "is_revoked": False})
        else:
            refresh_model.create({"stored_token": new_token, "user_id": uid})

        if hasattr(req, "future_response"):
            req.future_response.set_cookie(
                "refreshToken", new_token, httponly=True, secure=True, samesite="Lax"
            )
        return new_token

    @classmethod
    def verify_refresh_token(cls, req, uid, token):
        try:
            public_key = cls.get_public_key()
            jwt.decode(token, public_key, algorithms=[cls.JWT_ALGORITHM])
        except Exception as e:
            raise AccessDenied("Refresh Token verification failed: %s" % str(e))

        tok_ob = (
            req.env["jwt.refresh_token"].sudo().search([("user_id", "=", int(uid))])
        )
        if not tok_ob:
            raise AccessDenied("Refresh Token is invalid")
        if tok_ob.stored_token != token:
            # En RS256, si el token es válido pero ha cambiado en BD, invalidamos
            raise AccessDenied("Refresh Token has been changed")
        if tok_ob.is_revoked:
            raise AccessDenied(
                "Token has been revoked => User Logged out, Please Log in again"
            )
