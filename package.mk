# -----------------------------------------------------------------------------
# description: Package Specific Makefile
# licence: GPL3 <https://opensource.org/licenses/GPL3>
# author: Daniel Kovacs <danadeasysau@gmail.com>
# version: 1.1
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# imports
# -----------------------------------------------------------------------------

include flask.mk


# -----------------------------------------------------------------------------
# declarations
# -----------------------------------------------------------------------------

export PACKAGE_NAME=qctrl_api
export PACKAGE_VERSION=0.1.0
# export PY_EXECUTE_ARGS=--loglevel debug


# -----------------------------------------------------------------------------
# docker config
# -----------------------------------------------------------------------------

export DOCKER_BASE_IMAGE_TAG=qctrl/gcp-py3


# -----------------------------------------------------------------------------
# flask config
# -----------------------------------------------------------------------------

# Using defaults

# export FLASK_SERVICE_PORT=8080
# export KUBE_PUBLIC_PORT=8080


# -----------------------------------------------------------------------------
# application config
# -----------------------------------------------------------------------------

export WORKDIRL=./tmp
export GOOGLE_APPLICATION_CREDENTIALS=keys/

# ---------------------------------------------------------------------------------------------------
# namespace config
# ---------------------------------------------------------------------------------------------------

# export GLOBAL_NAMESPACE=


# -----------------------------------------------------------------------------
# docker config
# -----------------------------------------------------------------------------

DOCKER_RUN_ARGS:=$(DOCKER_RUN_ARGS) \
	--env KUBERNETES_CLUSTER_ID=$(KUBERNETES_CLUSTER_ID) \
	--env KUBERNETES_CLUSTER_ZONE=$(KUBERNETES_CLUSTER_ZONE)


# -----------------------------------------------------------------------------
# kubernetes config
# -----------------------------------------------------------------------------

# KUBERNETES_DEPLOYMENT_NAME=$(subst _,-,$(PACKAGE_NAME))

#
# This will work as long as there is only one cluster available in the current gcloud config.
# If there are more than one clusters, please set these variables externally.
#
# ifeq "$(KUBERNETES_CLUSTER_ID)" ""
# KUBERNETES_CLUSTER_ID=$(eval KUBERNETES_CLUSTER_ID := $$(shell gcloud container clusters list --format "get(name)"))$(KUBERNETES_CLUSTER_ID)
# endif

# ifeq "$(KUBERNETES_CLUSTER_ZONE)" ""
# KUBERNETES_CLUSTER_ZONE=$(eval KUBERNETES_CLUSTER_ZONE := $$(shell gcloud container clusters list --format "get(zone)"))$(KUBERNETES_CLUSTER_ZONE)
# endif


KUBERNETES_DEPLOYMENT_ARGS_3=\
   --env KUBERNETES_CLUSTER_ID=$(KUBERNETES_CLUSTER_ID) \
   --env KUBERNETES_CLUSTER_ZONE=$(KUBERNETES_CLUSTER_ZONE)


# -----------------------------------------------------------------------------
# general-pre-run::
# -----------------------------------------------------------------------------

general-pre-run:: kube-info-cache


# -----------------------------------------------------------------------------
# linking git working copies of dependencies
# -----------------------------------------------------------------------------

#
# Note: this is used when you want to develop the linked package and this 
# package in the same time.
#

deps:: $(VIRTUALENV_HOME)/deplink_dc-broadcast-utils package.mk



