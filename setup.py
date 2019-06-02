#!/usr/bin/env python
# package: qctrl_api
# licence: GPL3 <https://opensource.org/licenses/GPL3>
# author: Daniel Kovacs <danadeasysau@gmail.com>
# file: qctrl-api/setup.py
# file-version: 2.2.1


# ---------------------------------------------------------------------------------------
# configuration
# ---------------------------------------------------------------------------------------

NAME = "qctrl_api"
VERSION = "0.1.0"
DESCRIPTION = """Q-CTRL API"""
AUTHOR = "Daniel Kovacs"
AUTHOR_EMAIL = "danadeasysau@gmail.com"
MAINTAINER = "Daniel Kovacs"
MAINTAINER_EMAIL = "danadeasysau@gmail.com"
SCM_URL= ""
KEYWORDS = []
CLASSIFIERS = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: Other/Proprietary License"
    "Operating System :: OS Independent",
    "Programming Language :: Python",
    "Programming Language :: Python :: 3.6",
]

# ---------------------------------------------------------------------------------------
# imports
# ---------------------------------------------------------------------------------------

import codecs
import os
import re

from setuptools import setup, find_packages
try: # for pip >= 10
    from pip._internal.req import parse_requirements
except ImportError: # for pip <= 9.0.3
    from pip.req import parse_requirements


# ---------------------------------------------------------------------------------------
# _read()
# ---------------------------------------------------------------------------------------

def _read(*parts):
    with codecs.open(os.path.join(HOME, *parts), "rb", "utf-8") as f:
        return f.read()


# ---------------------------------------------------------------------------------------
# get_requirements
# ---------------------------------------------------------------------------------------

def get_requirements():
    packages, dependencies = [], []
    for ir in parse_requirements(os.path.join( HOME, 'requirements.txt' ), session=False):
        if ir.link:
            dependencies.append(ir.link.url)
            continue
        packages.append(str(ir.req))
    return packages, dependencies


# ---------------------------------------------------------------------------------------
# internal variables
# ---------------------------------------------------------------------------------------

HOME = os.path.abspath(os.path.dirname(__file__))
PACKAGES = find_packages(where='src')
INSTALL_REQUIRES, DEPENDENCY_LINKS = get_requirements()


# ---------------------------------------------------------------------------------------
# setup()
# ---------------------------------------------------------------------------------------

if __name__ == "__main__":
    setup(
        name=NAME,
        description=DESCRIPTION,
        license="License :: GPL3",
        url=SCM_URL,
        version=VERSION,
        author=AUTHOR,
        author_email=AUTHOR_EMAIL,
        maintainer=MAINTAINER,
        maintainer_email=MAINTAINER_EMAIL,
        keywords=KEYWORDS,
        long_description=_read("README.md"),
        include_package_data=True,
        packages=PACKAGES,
        package_dir={"": "src"},
        zip_safe=False,
        classifiers=CLASSIFIERS,
        install_requires=INSTALL_REQUIRES,
        dependency_links=DEPENDENCY_LINKS,
        setup_requires=[
        ],
        tests_require=[
            'pytest',
        ],
    )
