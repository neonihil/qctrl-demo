# encoding: utf-8
# package: qctrl-demo
# author: Daniel Kovacs <danadeasysau@gmail.com>
# file-version: 1.0

# -------------------------------------------------------------------------------
# imports
# -------------------------------------------------------------------------------

import os
from textwrap import dedent

from sutils import qdict, qlist, firstline

import flask
from flask_apispec import doc as old_doc
from flask_apispec import wrapper, annotations, utils
from webargs import flaskparser


# -------------------------------------------------------------------------------
# exports
# -------------------------------------------------------------------------------

__all__ = qlist()


# -------------------------------------------------------------------------------
# ObjectList
# -------------------------------------------------------------------------------

@__all__.register
def doc(**kwargs):
    def _doc(obj):
        if obj.__doc__ is None: return old_doc(**kwargs)(obj)
        summary, description = (obj.__doc__+"\n").split('\n', 1)
        description = dedent(description)
        kwargs.setdefault('summary', summary)
        kwargs.setdefault('description', description)
        return old_doc(**kwargs)(obj)
    return _doc


# -------------------------------------------------------------------------------
# FixedFlaskParser
# -------------------------------------------------------------------------------

class FixedFlaskParser(flaskparser.FlaskParser):

    def handle_invalid_json_error(self, error, req, *args, **kwargs):
        flask.abort(422, error)


# -------------------------------------------------------------------------------
# FixedWrapper
# -------------------------------------------------------------------------------

class FixedWrapper(wrapper.Wrapper):
    # We need to be monkey-patching flask-apispec,
    # because it appears to be broken as of now. :(

    def call_view(self, *args, **kwargs):
        config = flask.current_app.config
        parser = config.get('APISPEC_WEBARGS_PARSER', fixed_parser)
        annotation = utils.resolve_annotations(self.func, 'args', self.instance)
        if annotation.apply is not False:
            for option in annotation.options:
                schema = utils.resolve_schema(option['args'], request=flask.request)
                parsed = parser.parse(schema, locations=option['kwargs']['locations'])
                # if not isinstance(parsed, dict):
                #     parsed = dict(obj=parsed)
                # print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ args", repr(args))
                # print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ kwargs", repr(kwargs))
                # print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ parsed", repr(parsed))
                if isinstance(parsed, list):
                    # parsed = {"obj": parsed }
                    # if getattr(schema, 'many', False):
                    args += tuple(parsed)
                elif isinstance(parsed, dict):
                    kwargs.update(parsed)
                else:
                    args += (parsed,)
        return self.func(*args, **kwargs)

    def marshal_result(self, unpacked, status_code):
        config = flask.current_app.config
        format_response = config.get('APISPEC_FORMAT_RESPONSE', flask.jsonify) or identity
        annotation = utils.resolve_annotations(self.func, 'schemas', self.instance)
        schemas = utils.merge_recursive(annotation.options)
        schema = schemas.get(status_code, schemas.get('default'))
        if schema and annotation.apply is not False and schema['schema']:
            schema = utils.resolve_schema(schema['schema'], request=flask.request)
            dumped = schema.dump(unpacked[0])
            output = dumped.data if wrapper.MARSHMALLOW_VERSION_INFO[0] < 3 else dumped
        else:
            output = unpacked[0]
        return wrapper.format_output((format_response(output), ) + unpacked[1:])


# -------------------------------------------------------------------------------
# global exports
# -------------------------------------------------------------------------------

wrapper.Wrapper = FixedWrapper
annotations.Wrapper = wrapper.Wrapper

fixed_parser = parser = FixedFlaskParser()
use_args = parser.use_args
use_kwargs = parser.use_kwargs


