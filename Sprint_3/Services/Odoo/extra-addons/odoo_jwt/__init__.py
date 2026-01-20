# -*- coding: utf-8 -*-
"""
__init__.py del módulo odoo_jwt parcheado para Odoo 16
"""

# Importaciones estándar del módulo
from . import models
from . import controllers

# Hook de post-inicialización para generar JWT
def _install_jwt(cr, registry):
    import os
    import secrets
    import odoo

    # Crear un environment con SUPERUSER_ID
    env = odoo.api.Environment(cr, odoo.SUPERUSER_ID, {})

    # Ruta del archivo secreto
    setup_dir = os.path.join(os.path.dirname(__file__), 'setup')
    if not os.path.exists(setup_dir):
        os.makedirs(setup_dir)  # Crear carpeta setup si no existe

    file_for_secret = os.path.join(setup_dir, '.translator')

    # Generar JWT aleatorio y escribirlo en el archivo
    jwt_secret = secrets.token_hex(32)
    with open(file_for_secret, 'w') as f:
        f.write(jwt_secret)

