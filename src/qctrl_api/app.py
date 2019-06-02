# encoding: utf-8
# package: qctrl-demo
# author: Daniel Kovacs <danadeasysau@gmail.com>
# file-version: 1.3


# -------------------------------------------------------------------------------
# imports
# -------------------------------------------------------------------------------

import os
import sys
import logging
import traceback
import threading
import atexit

from importlib import import_module

from sutils import qdict, qlist

from flask import Flask, render_template, jsonify, current_app
from flask_debugtoolbar import DebugToolbarExtension
from flask_apispec.extension import FlaskApiSpec
from flask_apispec import wrapper
from flask_cors import CORS

from flask_mongoengine import MongoEngine
# from flask_login import LoginManager
# from flask_bcrypt import Bcrypt
# from flask_bootstrap import Bootstrap
# from flask_sqlalchemy import SQLAlchemy
# from flask_migrate import Migrate

from marshmallow import fields, ValidationError

from apispec import APISpec
from apispec.ext.flask import FlaskPlugin
from apispec.ext.marshmallow import MarshmallowPlugin

from . import __version__



# -------------------------------------------------------------------------------
# exports
# -------------------------------------------------------------------------------

__all__ = qlist(['app', 'db'])


# -------------------------------------------------------------------------------
# Logging Initialization
# -------------------------------------------------------------------------------

logging.basicConfig(level=logging.DEBUG, format="%(asctime)s\t%(levelname)s\t[%(threadName)s]\t%(name)s:\t%(message)s")
# logging.basicConfig(level=logging.INFO, format="%(asctime)s\t%(levelname)s\t[%(threadName)s]\t%(name)s:\t%(message)s")
_app_logger = logging.getLogger('app')

# -------------------------------------------------------------------------------
# Plugin initialization
# -------------------------------------------------------------------------------


# instantiate the extensions
# login_manager = LoginManager()
# bcrypt = Bcrypt()
toolbar = DebugToolbarExtension()
# bootstrap = Bootstrap()
# db = SQLAlchemy()
# migrate = Migrate()
db = MongoEngine()


# -------------------------------------------------------------------------------
# iter_schema()
# -------------------------------------------------------------------------------

def iter_schema(schema):
    yield schema
    for name, field in schema._declared_fields.items():
        if isinstance(field, fields.Nested):
            yield from iter_schema(field.nested)
        elif isinstance(field, fields.List):
            # print("\n\n", "------->>>", name, field, field.container)
            # import pdb; pdb.set_trace()
            if isinstance(field.container, fields.Nested):
                yield from iter_schema(field.container.nested)
        elif isinstance(field, fields.Dict):
            # print("\n\n", "------->>>", name, field, field.default)
            # import pdb; pdb.set_trace()
            if isinstance(field.default, fields.Nested):
                yield from iter_schema(field.default.nested)


# -------------------------------------------------------------------------------
# iter_schemas()
# -------------------------------------------------------------------------------

def iter_schemas(schemas):
    for schema in schemas:
        yield from iter_schema(schema)



# -------------------------------------------------------------------------------
# register_module()
# -------------------------------------------------------------------------------

def register_module(app, module_name):
    module = import_module(module_name)
    for schema in iter_schemas(module.schemas):
        app.docs.spec.definition(schema.__name__.replace('Schema', ''), schema=schema)
    for view in module.views:
        app.add_url_rule( view.BASE_URL, view_func=view.as_view(view.__name__.lower()) )
        # with app.app_context():
        app.docs.register(view)
        # app.docs.



# -------------------------------------------------------------------------------
# handle_unprocessable_entity()
# -------------------------------------------------------------------------------

def handle_unprocessable_entity(err):
    # webargs attaches additional metadata to the `data` attribute
    exc = getattr(err, "exc", None)
    if exc:
        # Get validations from the ValidationError object
        messages = exc.messages
    else:
        messages = ["Invalid request: {}".format(str(err))]
    return jsonify({"messages": messages}), 422


# -------------------------------------------------------------------------------
# handle_validation_error()
# -------------------------------------------------------------------------------

def handle_validation_error(exc):
    messages = getattr(exc, 'messages', None)
    return jsonify({"error": str(exc), "messages": messages}), 400


# -------------------------------------------------------------------------------
# create_app()
# -------------------------------------------------------------------------------

def create_app(script_info=None):
 
    # instantiate the app
    app = Flask(
        __name__,
        template_folder='templates',
        static_folder='static'
    )

    # sys.modules[__name__]._current_app = app

    # set config
    app_settings = os.getenv("FLASK_APP_CONFIG", "qctrl_api.config.DevelopmentConfig")
    app.config.from_object(app_settings)

    app.config.update({
        'APISPEC_SPEC': APISpec(
            title='Q-CTRL API',
            info=qdict(
                # description=open('API.md').read(),
            ),
            basePath="/api",
            version=__version__,
            plugins=[
                # FlaskPlugin(),
                MarshmallowPlugin(),
            ],
        ),
    })

    _app_logger.info("FlaskConfig: {}".format(app.config))

    # Register custom error handler so we can see what is exactly failing at validation.
    app.errorhandler(422)(handle_unprocessable_entity)
    app.errorhandler(ValidationError)(handle_validation_error)

    # Add spec handler to app so we don't need to pass it around separately.
    app.docs = FlaskApiSpec(app)

    # set up extensions
    # login_manager.init_app(app)
    # bcrypt.init_app(app)
    toolbar.init_app(app)
    # bootstrap.init_app(app)
    db.init_app(app)
    # migrate.init_app(app, db)
    
    # CORS Plugin init
    CORS(app)

    # # flask login
    # from project.server.models import User
    # login_manager.login_view = 'user.login'
    # login_manager.login_message_category = 'danger'

    # @login_manager.user_loader
    # def load_user(user_id):
    #     return User.query.filter(User.id == int(user_id)).first()

    # # error handlers
    # @app.errorhandler(401)
    # def unauthorized_page(error):
    #     return render_template('errors/401.html'), 401

    # @app.errorhandler(403)
    # def forbidden_page(error):
    #     return render_template('errors/403.html'), 403

    # @app.errorhandler(404)
    # def page_not_found(error):
    #     return render_template('errors/404.html'), 404

    # @app.errorhandler(500)
    # def server_error_page(error):
    #     return render_template('errors/500.html'), 500

    # shell context for flask cli
    @app.shell_context_processor
    def ctx():
        return {
            "app": app,
        }

    return app


# -------------------------------------------------------------------------------
# enable_other_loggers()
# -------------------------------------------------------------------------------

def enable_other_loggers():
    logging.getLogger('webargs.core').setLevel(logging.DEBUG)
    pass

# enable_other_loggers()


# -------------------------------------------------------------------------------
# initialize the app object
# -------------------------------------------------------------------------------

_app_logger.info("Running as pid: {} with uid: {} gid: {}".format(os.getpid(), os.getuid(), os.getgid() ))
_app_logger.info("Creating Flask app...")
app = create_app()
_app_logger.info("Flask app created: {}".format(app))


# ===============================================================================
# import application modules 
# ===============================================================================
# 
#  WARNING: Application modules will import .auto_import, which will recursively
#     import .app (this file.) Because of this, anything placed below this line
#     will not be importable in .auto_import. 
#
# ===============================================================================


# -------------------------------------------------------------------------------
# General blueprint
# -------------------------------------------------------------------------------

from .general import blueprint as general_blueprint

app.register_blueprint(general_blueprint)


# -------------------------------------------------------------------------------
# Register Module
# -------------------------------------------------------------------------------

# register_module(app, 'qctrl_api.controls.endpoints')
register_module(app, 'qctrl_api.pulses.endpoints')



