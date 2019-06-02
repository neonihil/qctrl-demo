# encoding: utf-8
# package: qctrl_api
# author: Daniel Kovacs <daniel.kovacs@qctrl.com>
# file-version: 1.1


# -------------------------------------------------------------------------------
# imports
# -------------------------------------------------------------------------------


from sutils import *
from marshmallow import Schema, fields


# -------------------------------------------------------------------------------
# exports
# -------------------------------------------------------------------------------

__all__ = qlist()


# -------------------------------------------------------------------------------
# ObjectList
# -------------------------------------------------------------------------------

@__all__.register
class ObjectList(list):

    def register(self, obj):
        self.append(obj)
        return obj


# -------------------------------------------------------------------------------
# OperationResult
# -------------------------------------------------------------------------------

@__all__.register
class OperationResult(PrettyObject):

    __slots__ = [
        "id",
        "code",
        "result",
        "message",
        "error",
    ]

    class Schema(Schema):
        id = fields.Str(allow_none=True)
        code = fields.Int(allow_none=True)
        result = fields.Dict(allow_none=True)
        message = fields.Str(allow_none=True)
        error = fields.Str(allow_none=True)

    SCHEMA = Schema(strict=True)


    def __init__(self, **kwargs):
        self.update(**kwargs)


    def update(self, **kwargs):
        values, errors = self.SCHEMA.load(kwargs)
        if errors:
            raise ValidationError(errors)
        for name in self.SCHEMA.fields.keys():
            value = kwargs.pop(name, None)
            setattr(self, name, value)

