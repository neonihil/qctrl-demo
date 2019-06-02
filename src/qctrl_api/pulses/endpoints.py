# encoding: utf-8
# package: qctrl-demo
# author: Daniel Kovacs <danadeasysau@gmail.com>
# file-version: 1.0

# -------------------------------------------------------------------------------
# imports
# -------------------------------------------------------------------------------

from ..auto_imports import *

from .pulse import *

# -------------------------------------------------------------------------------
# exports
# -------------------------------------------------------------------------------

__all__ = qlist()

views = ObjectList()
schemas = ObjectList()


# -------------------------------------------------------------------------------
# PulseSchema
# -------------------------------------------------------------------------------

@schemas.register
class PulseSchema(ModelSchema):
    class Meta:
        model = Pulse
        strict = True


# -------------------------------------------------------------------------------
# Schema registering
# -------------------------------------------------------------------------------

schemas.register(PulseSchema)



# -------------------------------------------------------------------------------
# PulseResource
# -------------------------------------------------------------------------------

@views.register
@doc(tags=['pulse'])
class PulseResource(MethodResource):

    BASE_URL = '/api/pulse'

    @use_kwargs(
        {
            'index': fields.Str(required=False),
            'name': fields.Str(required=False),
            'kind': fields.Str(required=False),
            'maximum_rabi_rate': fields.Float(required=False),
            'polar_angle ': fields.Float(required=False),
        },
        locations=["query"]
    )
    @marshal_with(PulseSchema(many=True), code=200)
    @doc()
    def get(self, **filters):
        """Returns pulses
        """
        return Pulse.objects(**filters).all()

    @use_kwargs(PulseSchema())
    @marshal_with(PulseSchema, code=200, description = "Updated")
    @marshal_with(PulseSchema, code=201, description = "Created")
    @doc()
    def put(self, obj):
        """Creates or updates a pulse
        """
        try:
            existing_obj = Pulse.objects.get(index=obj.index)
        except DoesNotExist:
            obj.save()
            return obj, 201
        else:
            obj.id = existing_obj.id
            obj.save()
            return obj, 200

    @use_kwargs(
        {
            'index': fields.Str(required=False),
        }, 
        locations=["query"]
    )
    @marshal_with(None, code=204, description="Deleted")
    @doc()
    def delete(self, **filters):
        """Removes a single pulse
        """
        obj = Pulse.objects.get_or_404(**filters)
        obj.delete()
        return None, 204




