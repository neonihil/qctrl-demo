# encoding: utf-8
# package: qctrl-demo
# author: Daniel Kovacs <danadeasysau@gmail.com>
# file-version: 1.1

# -------------------------------------------------------------------------------
# imports
# -------------------------------------------------------------------------------

from . import blueprint
from .. auto_imports import *
from .. import __version__


# -------------------------------------------------------------------------------
# exports
# -------------------------------------------------------------------------------

__all__ = qlist()


# -------------------------------------------------------------------------------
# home()
# -------------------------------------------------------------------------------

@blueprint.route('/')
def home():
    return render_template('general/landing.tpl.html', 
        package_version = __version__, 
    )

