# encoding: utf-8
# package: qctrl-demo
# author: Daniel Kovacs <danadeasysau@gmail.com>
# file-version: 1.0

# -------------------------------------------------------------------------------
# imports
# -------------------------------------------------------------------------------

from datetime import datetime

from ..auto_imports import *


# -------------------------------------------------------------------------------
# exports
# -------------------------------------------------------------------------------

__all__ = qlist()


# -------------------------------------------------------------------------------
# People
# -------------------------------------------------------------------------------

@__all__.register
class Pulse(Document):

    index = StringField(
        required=True,
        primary_key=True,
    )

    name = StringField(
        required=True,
    )

    kind = StringField(
        required=True,
    )

    maximum_rabi_rate = FloatField(
        required=True,
    )

    polar_angle = FloatField(
        required=True,
    )

