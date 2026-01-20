{
    'name': 'Gestión de Suscripciones con Temporizador',
    'version': '1.0',
    'category': 'Sales',
    'summary': 'Control de suscripciones con temporizador y portal para clientes',
    'depends': ['sale', 'sale_management', 'product', 'portal', 'website_sale'],
    'data': [
        'security/ir.model.access.csv',
        'data/subscription_cron.xml',
        'views/product_template_views.xml',
        'views/subscription_views.xml',
        'views/portal_my_home.xml',  # ← AGREGAR ESTA LÍNEA
        'views/portal_subscription_templates.xml',
    ],
    'installable': True,
    'application': False,
    'auto_install': False,
}