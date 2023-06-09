##
# import torch.nn.functional as F
import jax.nn as jnn
##
from rich import inspect

def h(x, **kwargs):
    return inspect(x, help=True, **kwargs)
##
from datetime import datetime, timedelta
import pathlib
from pathlib import Path
import os
import sys
import re
import random
import math
import logging

logger = logging.getLogger("ipy")

try:
    import numpy
    np = numpy
except:
    pass

try:
    import pandas
    pd = pandas
except:
    pass

try:
    from brish import z, zp, zs, zq, bsh
except:
    pass
try:
    from icecream import ic
except ImportError:  # Graceful fallback if IceCream isn't installed.
    ic = lambda *a: None if not a else (a[0] if len(a) == 1 else a)  # noqa

###
from functools import wraps
from time import time

def timing(f):
    @wraps(f)
    def wrap(*args, **kw):
        ts = time()
        result = f(*args, **kw)
        te = time()
        print('func:%r args:[%r, %r] took: %2.4f sec' % (f.__name__, args, kw, te-ts))
        return result
    return wrap
###
def char_range(c1, c2):
    """Generates the characters from `c1` to `c2`, inclusive."""
    for c in range(ord(c1), ord(c2) + 1):
        yield chr(c)


###
