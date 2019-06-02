# encoding: utf-8
# package: qctrl-demo
# author: Daniel Kovacs <danadeasysau@gmail.com>
# file-version: 1.1

# -------------------------------------------------------------------------------
# imports
# -------------------------------------------------------------------------------

import os

from sutils import qdict, qlist


# -------------------------------------------------------------------------------
# exports
# -------------------------------------------------------------------------------

__all__ = qlist()


# -------------------------------------------------------------------------------
# globals
# -------------------------------------------------------------------------------

# basedir = os.path.abspath(os.path.dirname(__file__))


# -------------------------------------------------------------------------------
# BaseConfig
# -------------------------------------------------------------------------------

class BaseConfig(object):
    """Base configuration."""
    APP_NAME = "qctrl_api"
    APISPEC_SWAGGER_URL = "/api/spec.json"
    APISPEC_SWAGGER_UI_URL = "/api/docs"
    # BCRYPT_LOG_ROUNDS = 4
    # DEBUG_TB_ENABLED = False
    # SECRET_KEY = os.getenv('SECRET_KEY', 'my_precious')
    # SQLALCHEMY_TRACK_MODIFICATIONS = False
    # WTF_CSRF_ENABLED = False
    CORS_RESOURCES = {}


# -------------------------------------------------------------------------------
# DevelopmentConfig
# -------------------------------------------------------------------------------

class DevelopmentConfig(BaseConfig):
    """Development configuration."""
    SECRET_KEY = os.urandom(24)
    # EXPLAIN_TEMPLATE_LOADING = True
    MONGODB_SETTINGS = qdict(
        db = 'qctrldemo',
        host = 'localhost',
        # port = 12345,
    )
    DEBUG_TB_ENABLED = True
    DEBUG_TB_PANELS = [
        "flask_debugtoolbar.panels.timer.TimerDebugPanel",
        "flask_debugtoolbar.panels.headers.HeaderDebugPanel",
        "flask_debugtoolbar.panels.request_vars.RequestVarsDebugPanel",
        "flask_debugtoolbar.panels.template.TemplateDebugPanel",
        # 'flask_mongoengine.panels.MongoDebugPanel',
        "flask_debugtoolbar.panels.route_list.RouteListDebugPanel",
        "flask_debugtoolbar.panels.config_vars.ConfigVarsDebugPanel",
    ]
    TRAP_HTTP_EXCEPTIONS = True
    TRAP_BAD_REQUEST_ERRORS = True
    # DEBUG_TB_INTERCEPT_REDIRECTS = False
    # SQLALCHEMY_DATABASE_URI = os.environ.get(
    #     'DATABASE_URL',
    #     'sqlite:///{0}'.format(os.path.join(basedir, 'dev.db')))

    CORS_RESOURCES = {
        r"*": { "origins": "*" }
    }

    pass



# -------------------------------------------------------------------------------
# TestingConfig
# -------------------------------------------------------------------------------

class TestingConfig(BaseConfig):
    """Testing configuration."""

    # PRESERVE_CONTEXT_ON_EXCEPTION = False
    # SQLALCHEMY_DATABASE_URI = 'sqlite:///'
    # SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_TEST_URL', 'sqlite:///')
    TESTING = True

    CORS_RESOURCES = {
        r"*": { "origins": "*" }
    }


# -------------------------------------------------------------------------------
# ProductionConfig
# -------------------------------------------------------------------------------

class ProductionConfig(BaseConfig):
    """Production configuration."""

    # BCRYPT_LOG_ROUNDS = 13
    # SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    # WTF_CSRF_ENABLED = True

    CORS_RESOURCES = {}
    pass


