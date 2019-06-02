# encoding: utf-8
# package: qctrl-demo
# author: Daniel Kovacs <danadeasysau@gmail.com>
# file-version: 1.0

# -------------------------------------------------------------------------------
# imports
# -------------------------------------------------------------------------------

from . import blueprint
from .. auto_imports import *

# -------------------------------------------------------------------------------
# exports
# -------------------------------------------------------------------------------

__all__ = qlist()


# -------------------------------------------------------------------------------
# error()
# -------------------------------------------------------------------------------

@blueprint.route("/debug/error")
def error():
    does_not_exist()
    return render_template("main/about.html")

# -------------------------------------------------------------------------------
# drop_db()
# -------------------------------------------------------------------------------

@blueprint.route("/debug/drop_db", methods=['DELETE'])
def drop_db():
    from mongoengine import connect
    from flask import current_app
    db_name = current_app.config['MONGODB_SETTINGS']['db']

    db = connect(db_name)
    db.drop_database(db_name)

    return "database {} dropped".format(db_name), 204

