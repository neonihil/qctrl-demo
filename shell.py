# encoding: utf-8
# author: Daniel Kovacs <danadeasysau@gmail.com>
# licence: GPL3 <https://opensource.org/licenses/GPL3>
# file: shell.py
# purpose: interactive demo
# version: 1.0


# ---------------------------------------------------------------------------------------
# imports
# ---------------------------------------------------------------------------------------

import sys, os
import yaml
from datetime import datetime, timedelta
from pprint import pprint
pp = pprint
from sutils import *


# ---------------------------------------------------------------------------------------
# package specific imports
# ---------------------------------------------------------------------------------------

from qctrl_api.pulses import *


# ---------------------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------------------
