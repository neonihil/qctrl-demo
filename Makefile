# -----------------------------------------------------------------------------
# description: General Python Makefile
# author: Daniel Kovacs <mondomhogynincsen@gmail.com>
# licence: GPL3 <https://opensource.org/licenses/GPL3>
# version: 4.19
# supported: virtualenv, pytest
# -----------------------------------------------------------------------------

SHELL=/bin/bash


# -----------------------------------------------------------------------------
# package config
# -----------------------------------------------------------------------------

PACKAGE_NAME=my_python_module
PACKAGE_VERSION=0.1.0
PACKAGE_HOME=.
PACAKGE_SOURCES=src
PACKAGE_TEST=test
PACKAGE_ENVIRONMENT_FILE=.environment
PACKAGE_SOURCE_FILES=setup.py $(shell find $(PACAKGE_SOURCES) -name '*.py')


# -----------------------------------------------------------------------
# python specific overrides
# -----------------------------------------------------------------------

export PY_MODULE_NAME=$(PACKAGE_NAME).cli
export PY_EXECUTABLE=$(PACKAGE_NAME)
export PY_EXECUTE_ARGS=


# -----------------------------------------------------------------------
# google cloud config
# -----------------------------------------------------------------------

# export GOOGLE_PROJECT_ID=
export GOOGLE_PROJECT_ID=$(shell gcloud config get-value project -q 2>/dev/null)
export GOOGLE_APPLICATION_CREDENTIALS=
export PROJECT_ID=$(GOOGLE_PROJECT_ID)


# ---------------------------------------------------------------------------------------------------
# namespace config
# ---------------------------------------------------------------------------------------------------

export GLOBAL_NAMESPACE=$(HOSTNAME)


# ---------------------------------------------------------------------------------------------------
# docker config
# ---------------------------------------------------------------------------------------------------

# Docker namespace for image naming
DOCKER_NAMESPACE=$(GLOBAL_NAMESPACE)


# Base image for buildbox
export DOCKER_BASE_IMAGE_TAG=isentia/gcp-py3:0.2

# Buildbox docker image name  based on the lambda name
DOCKER_BUILDBOX_IMAGE_NAME=isentia/$(PACKAGE_NAME)-buildbox

# Buildbox files responsible for setting up the buildbox
DOCKER_BUILDBOX_FILES=provisioning/provision.sh requirements.txt

# Buildbox docker image version derivated from the contents of the provisioning script
DOCKER_BUILDBOX_IMAGE_HASH=$(shell cat $(DOCKER_BUILDBOX_FILES) | md5sum | awk '{print $$1}')

# Buildbox docker image tag includes the image name and the required hash version
export DOCKER_BUILDBOX_IMAGE_TAG=$(DOCKER_BUILDBOX_IMAGE_NAME):$(DOCKER_BUILDBOX_IMAGE_HASH)

# Docker invocation to execute something in the buildbox as dev user
DOCKER_BUILDBOX_RUN=docker run --rm -v "~/.ssh":/home/dev/.ssh -t $(DOCKER_BUILDBOX_IMAGE_TAG) su - dev -c 

# Docker application image name
export DOCKER_IMAGE_NAME=gcr.io/$(GOOGLE_PROJECT_ID)/$(PACKAGE_NAME)

# Docker application image version
export DOCKER_IMAGE_VERSION=$(PACKAGE_VERSION)

# Docker application image tag
export DOCKER_IMAGE_TAG=$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)

ifneq "$(DOCKER_NAMESPACE)" ""
	export DOCKER_IMAGE_TAG=$(DOCKER_IMAGE_NAME):$(DOCKER_NAMESPACE)-$(DOCKER_IMAGE_VERSION)
endif


# Docker additional arguments for docker image build
DOCKER_IMAGE_BUILD_ARGS=

# Docker additional arguments for docker run
DOCKER_RUN_ARGS=


# ---------------------------------------------------------------------------------------------------
# firebase config
# ---------------------------------------------------------------------------------------------------

export FIREBASE_NAMESPACE=$(GLOBAL_NAMESPACE)


# ---------------------------------------------------------------------------------------------------
# kubernetes config
# ---------------------------------------------------------------------------------------------------

export KUBERNETES_NAMESPACE=$(GLOBAL_NAMESPACE)
ifneq "$(KUBERNETES_NAMESPACE)" ""
KUBERNETES_NAMESPACE_ARG=--namespace $(KUBERNETES_NAMESPACE)
endif
KUBERNETES_NAMESPACE_EXISTS=$(CACHE_DIR)/kubernetes_namespace_$(KUBERNETES_NAMESPACE)
KUBERNETES_DEPLOYMENT_POD_NAME=$(CACHE_DIR)/kubernetes_pod_name
KUBERNETES_DEPLOYMENT_NAME=$(subst _,-,$(PACKAGE_NAME))
KUBERNETES_DEPLOYMENT_ARGS_0=
KUBERNETES_DEPLOYMENT_ARGS_1=
KUBERNETES_DEPLOYMENT_ARGS_2=
KUBERNETES_DEPLOYMENT_ARGS_3=
KUBERNETES_DEPLOYMENT_ARGS=$(KUBERNETES_DEPLOYMENT_ARGS_0) \
	$(KUBERNETES_DEPLOYMENT_ARGS_1) \
	$(KUBERNETES_DEPLOYMENT_ARGS_2) \
	$(KUBERNETES_DEPLOYMENT_ARGS_3) 
export KUBERNETES_CLUSTER_ID=$(shell cat $(CACHE_DIR)/kubernetes_cluster_id 2>/dev/null)
export KUBERNETES_CLUSTER_ZONE=$(shell cat $(CACHE_DIR)/kubernetes_cluster_zone 2>/dev/null)


# ---------------------------------------------------------------------------------------------------
# google package config
# ---------------------------------------------------------------------------------------------------

export GOOGLE_STORAGE_NAMESPACE=$(GLOBAL_NAMESPACE)


# -----------------------------------------------------------------------------
# cache config
# -----------------------------------------------------------------------------

CACHE_DIR=.cache
BUILDBOX_CACHE_DIR=$(CACHE_DIR)/buildbox


# -----------------------------------------------------------------------------
# build config
# -----------------------------------------------------------------------------

BUILD_DIST_DIR=$(PACKAGE_HOME)/dist
BUILD_TARGET=sdist
BUILD_ARG=

# -----------------------------------------------------------------------------
# python config
# -----------------------------------------------------------------------------

PYTHON_VERSION="python3"

# -----------------------------------------------------------------------------
# virtualenv config
# -----------------------------------------------------------------------------

VIRTUALENV_DIR=.virtualenv
VIRTUALENV_HOME=$(VIRTUALENV_DIR)
VIRTUALENV_ACTIVATE=$(VIRTUALENV_HOME)/bin/activate


# -----------------------------------------------------------------------
# define checkenv-start-validation
# -----------------------------------------------------------------------

define checkenv-start-validation
	@echo "checking environment...."
	@rm -f $(PACKAGE_ENVIRONMENT_FILE)
endef


# -----------------------------------------------------------------------
# define checkenv-command
# -----------------------------------------------------------------------

define checkenv-command
	@printf "checking $(1)..." && (type $(1) >> $(PACKAGE_ENVIRONMENT_FILE) 2>&1 && echo "ok") || (echo "error: $(1) not found" >> $(PACKAGE_ENVIRONMENT_FILE) && echo "NOT FOUND" && true)
endef


# -----------------------------------------------------------------------
# define checkenv-validate
# -----------------------------------------------------------------------

define checkenv-validate
	@(grep error $(PACKAGE_ENVIRONMENT_FILE) > /dev/null 2>&1 && rm -f $(PACKAGE_ENVIRONMENT_FILE) || true)
	@( [ -f $(PACKAGE_ENVIRONMENT_FILE) ] || (echo "error: invalid environment configuration.\n\nPlease install the missing packages listed above.\n" && false) )
endef


# -----------------------------------------------------------------------
# _recheckenv
# -----------------------------------------------------------------------

_recheckenv::
	@rm -f $(PACKAGE_ENVIRONMENT_FILE)


# -----------------------------------------------------------------------
# checkenv
# -----------------------------------------------------------------------

.PHONY: checkenv
checkenv:: _recheckenv $(PACKAGE_ENVIRONMENT_FILE)


# -----------------------------------------------------------------------
# $(PACKAGE_ENVIRONMENT_FILE)
# -----------------------------------------------------------------------

$(PACKAGE_ENVIRONMENT_FILE):: Makefile
	$(call checkenv-start-validation)
	$(call checkenv-command,git)
	$(call checkenv-command,python)
	$(call checkenv-command,pip)
	$(call checkenv-command,virtualenv)
	$(call checkenv-command,md5sum)
	# $(call checkenv-command,docker)
	$(call checkenv-validate)
	
# -----------------------------------------------------------------------------
# clean
# -----------------------------------------------------------------------------

.PHONY:clean
clean::
	rm -rf $(PACKAGE_ENVIRONMENT_FILE) $(VIRTUALENV_HOME) $(ASSETS_HOME) activate build dist .cache .eggs .tmp *.egg-info src/*.egg-info
	find . -name ".DS_Store" -exec rm -rf {} \; || true
	find . -name "*.pyc" -exec rm -rf {} \; || true
	find . -name "__pycache__" -exec rm -rf {} \; || true


# -----------------------------------------------------------------------------
# $(VIRTUALENV_HOME)/created
# -----------------------------------------------------------------------------

$(VIRTUALENV_HOME)/created:: $(PACKAGE_ENVIRONMENT_FILE) 
	virtualenv --python $(PYTHON_VERSION) $(VIRTUALENV_HOME)
	ln -sf $(VIRTUALENV_ACTIVATE) activate
	date > $@


# -----------------------------------------------------------------------------
# $(VIRTUALENV_HOME)
# -----------------------------------------------------------------------------

$(VIRTUALENV_HOME):: $(VIRTUALENV_HOME)/created
	touch $@


# -----------------------------------------------------------------------------
# $(VIRTUALENV_HOME)/deps
# -----------------------------------------------------------------------------

$(VIRTUALENV_HOME)/deps:: requirements.txt $(VIRTUALENV_HOME)/created
	@echo "Reinstalling dependencies because the following files were changed: $?"
	source activate && pip install -r $<
	touch $@


# -----------------------------------------------------------------------------
# virtualenv
# -----------------------------------------------------------------------------

.PHONY: virtualenv
virtualenv:: $(VIRTUALENV_HOME)/created


# -----------------------------------------------------------------------------
# deps
# -----------------------------------------------------------------------------

deps:: $(VIRTUALENV_HOME)/deps


# -----------------------------------------------------------------------------
# $(VIRTUALENV_HOME)/deps-%
# -----------------------------------------------------------------------------

$(VIRTUALENV_HOME)/deps-%:: requirements-%.txt $(VIRTUALENV_HOME)/deps
	source activate && pip install -r $<
	touch $@


# -----------------------------------------------------------------------------
# deps-test
# -----------------------------------------------------------------------------

deps-test:: $(VIRTUALENV_HOME)/deps-test


# -----------------------------------------------------------------------------
# deps-test
# -----------------------------------------------------------------------------

deps-build:: $(VIRTUALENV_HOME)/deps-build


# -----------------------------------------------------------------------------
# $(VIRTUALENV_HOME)/deplink_%
# -----------------------------------------------------------------------------

$(VIRTUALENV_HOME)/deplink_%:: requirements.txt $(VIRTUALENV_HOME)/created
	$(eval LINKED_PACKAGE_DIR=$(subst $(VIRTUALENV_HOME)/deplink_,,$@))
	@echo "LINKED_PACKAGE_DIR=$(LINKED_PACKAGE_DIR)"
	@if [[ -d ../$(LINKED_PACKAGE_DIR) ]]; then \
		echo "Linking working copy of $(LINKED_PACKAGE_DIR)"; \
		source activate && pip install -e ../$(LINKED_PACKAGE_DIR); \
	else \
		echo "NOTICE: SKIP: working copy not found locally, skipping linking: $(LINKED_PACKAGE_DIR)"; \
	fi
	touch $@


# -----------------------------------------------------------------------------
# local_install
# -----------------------------------------------------------------------------

$(VIRTUALENV_HOME)/local_install:: setup.py $(VIRTUALENV_HOME)/deps $(VIRTUALENV_HOME)/deps-build
	source activate && pip install -e .
	date > $@

local-install: $(VIRTUALENV_HOME)/local_install


# -----------------------------------------------------------------------
# test-modules
# -----------------------------------------------------------------------

.PHONY: test-modules
test-modules:: deps-test
	source activate && pytest $(PACAKGE_SOURCES)/


# -----------------------------------------------------------------------
# test-e2e
# -----------------------------------------------------------------------

.PHONY: test-e2e
test-e2e:: deps-test
	source activate && pytest test/


# -----------------------------------------------------------------------
# test
# -----------------------------------------------------------------------

.PHONY: test
test:: deps-test
	source activate && pytest $(PACAKGE_SOURCES)/ $(PACKAGE_TEST)/


# -----------------------------------------------------------------------
# test-%
# -----------------------------------------------------------------------

test-%:: $(PACKAGE_TEST)/%_test.py deps deps-test
	source activate && pytest -sv $<


# -----------------------------------------------------------------------------
# shell
# -----------------------------------------------------------------------------

shell:: setup
	@echo "GLOBAL_NAMESPACE:     $(GLOBAL_NAMESPACE)"
	@echo "FIREBASE_NAMESPACE:   $(FIREBASE_NAMESPACE)"
	@echo "KUBERNETES_NAMESPACE: $(FIREBASE_NAMESPACE)"
	@echo "GOOGLE_STORAGE_NAMESPACE:    $(FIREBASE_NAMESPACE)"
	source activate && python -i shell.py

# -----------------------------------------------------------------------------
# shell-%
# -----------------------------------------------------------------------------

shell-%:: setup
	source activate && python -i $@.py


# -----------------------------------------------------------------------
# build
# -----------------------------------------------------------------------

build:: $(SOURCES) deps deps-build
	./setup.py $(BUILD_TARGET) $(BUILD_ARGS)


# -----------------------------------------------------------------------
# install-deps
# -----------------------------------------------------------------------

install-deps:: requirements.txt
	pip install -r $<


# -----------------------------------------------------------------------
# install-private-deps
# -----------------------------------------------------------------------

install-private-deps:: requirements.txt
	pip install $$(grep "git+ssh" $<)


# -----------------------------------------------------------------------
# install
# -----------------------------------------------------------------------

install:: $(SOURCES)
	pip install .


# -----------------------------------------------------------------------
# setup
# -----------------------------------------------------------------------

setup:: deps deps-build deps-test local-install


# -----------------------------------------------------------------------------
# general-pre-run
# -----------------------------------------------------------------------------

general-pre-run::


# -----------------------------------------------------------------------------
# pre-run
# -----------------------------------------------------------------------------

pre-run:: general-pre-run


# -----------------------------------------------------------------------------
# run
# -----------------------------------------------------------------------------

run:: setup pre-run
	source activate && ${PY_EXECUTABLE} ${PY_EXECUTE_ARGS}


# -----------------------------------------------------------------------------
# bump-%
# -----------------------------------------------------------------------------

bump-%:: deps-build
	source activate && bumpversion --list --commit --tag $(subst bump-,,$@)


# -----------------------------------------------------------------------------
# release-minor
# -----------------------------------------------------------------------------

release-minor:: bump-minor build

# -----------------------------------------------------------------------------
# release-patch
# -----------------------------------------------------------------------------

release-patch:: bump-patch build

# -----------------------------------------------------------------------------
# release-major
# -----------------------------------------------------------------------------

release-major:: test bump-major build


# -----------------------------------------------------------------------------
# release
# -----------------------------------------------------------------------------

release::release-minor


# ---------------------------------------------------------------------------------------------------
# $(CACHE_DIR)
# ---------------------------------------------------------------------------------------------------

$(CACHE_DIR):: $(PACKAGE_ENVIRONMENT_FILE)
	mkdir -p $@
	touch $@


# ---------------------------------------------------------------------------------------------------
# buildbox-hash
# ---------------------------------------------------------------------------------------------------
# gives a shell in the docker build box
#

buildbox-hash::
	@echo "Current BUILDBOX image hash: $(DOCKER_BUILDBOX_IMAGE_HASH)"


# ---------------------------------------------------------------------------------------------------
# buildbox-cache
# ---------------------------------------------------------------------------------------------------
# builds a filesystem cache of the available buildbox images
#
# This cache is used to avoid unneccessary rebuilds of the buildbox docker image.
#

$(BUILDBOX_CACHE_DIR):: $(PACKAGE_ENVIRONMENT_FILE)
	@echo "==========================================================================================="
	@echo "Creating local BUILDBOX cache..."
	@echo "==========================================================================================="
	@if [[ ! -d $@ ]]; then mkdir -p $@; fi
	docker images --format '{{.Tag}}' ${DOCKER_BUILDBOX_IMAGE_NAME} | while read IMAGE_HASH; do \
		if [[ ! -f $@/$${IMAGE_HASH} ]]; then \
		    touch $@/$${IMAGE_HASH}; \
		fi \
	done
	@touch $@
	@echo "Buildbox cache refreshed."

buildbox-cache:: $(BUILDBOX_CACHE_DIR)


# ---------------------------------------------------------------------------------------------------
# buildbox-cache-refresh
# ---------------------------------------------------------------------------------------------------

buildbox-cache-refresh::
	rm -rf $(BUILDBOX_CACHE_DIR)
	make buildbox-cache


# ---------------------------------------------------------------------------------------------------
# buildbox-docker-image
# ---------------------------------------------------------------------------------------------------
# provisions the buildbox docker image 
#

$(BUILDBOX_CACHE_DIR)/$(DOCKER_BUILDBOX_IMAGE_HASH):: Dockerfile-buildbox provisioning/provision.sh
	@echo "==========================================================================================="
	@echo "Creating BUILDBOX docker image..."
	@echo "==========================================================================================="
	@echo "Creating buildbox docker image: $(DOCKER_BUILDBOX_IMAGE_TAG)"
	@if [[ ! -d $(BUILDBOX_CACHE_DIR) ]]; then mkdir -p $(BUILDBOX_CACHE_DIR); fi
	docker build \
		--build-arg DOCKER_BASE_IMAGE_TAG \
		--build-arg SSH_PRIVATE_KEY="$$(cat ~/.ssh/id_rsa)" \
		-t $(DOCKER_BUILDBOX_IMAGE_TAG) \
		-f $< .
	docker images -q $(DOCKER_BUILDBOX_IMAGE_TAG) > $@
	touch $@


buildbox-docker-image:: buildbox-cache $(BUILDBOX_CACHE_DIR)/$(DOCKER_BUILDBOX_IMAGE_HASH)


# ---------------------------------------------------------------------------------------------------
# buildbox-shell
# ---------------------------------------------------------------------------------------------------
# gives a shell in the docker build box
#

buildbox-shell:: buildbox-docker-image
	docker run --rm -it -v "$$PWD":/workdir -v ~/.ssh:/root/.ssh  ~/.ssh:/dev/.ssh  $(DOCKER_BUILDBOX_IMAGE_TAG) bash


# ---------------------------------------------------------------------------------------------------
# docker-image
# ---------------------------------------------------------------------------------------------------

$(CACHE_DIR)/docker_last_build:: Dockerfile package.mk provisioning/setup.sh $(BUILDBOX_CACHE_DIR)/$(DOCKER_BUILDBOX_IMAGE_HASH) $(PACKAGE_SOURCE_FILES)
	@echo "==========================================================================================="
	@echo "Creating APPLICATION docker image..."
	@echo "==========================================================================================="
	@echo "Rebuilding because the following files were changed:" 
	@echo "$?"
	@echo "---------------------------------------"
	@echo "DOCKER_BUILDBOX_IMAGE_TAG: $(DOCKER_BUILDBOX_IMAGE_TAG)"
	@echo "DOCKER_IMAGE_TAG: $(DOCKER_IMAGE_TAG)"
	@echo "PY_MODULE_NAME: ${PY_MODULE_NAME}"
	@echo "PY_EXECUTABLE: ${PY_EXECUTABLE}"
	@if [[ ! -d $(CACHE_DIR) ]]; then mkdir -p $(CACHE_DIR); fi
	docker build \
		--build-arg SSH_PRIVATE_KEY="$$(cat ~/.ssh/id_rsa)" \
		--build-arg DOCKER_BUILDBOX_IMAGE_TAG \
		--build-arg PY_MODULE_NAME \
		--build-arg PY_EXECUTABLE \
		$(DOCKER_IMAGE_BUILD_ARGS) \
		--tag $(DOCKER_IMAGE_TAG) \
		.
	docker images -q $(DOCKER_IMAGE_TAG) > $@


docker-image:: $(CACHE_DIR)/docker_last_build


# ---------------------------------------------------------------------------------------------------
# docker-shell
# ---------------------------------------------------------------------------------------------------

docker-shell:: $(CACHE_DIR)/docker_last_build
	docker run \
		--rm \
		-ti \
		-v $${PWD}:/home/dev/workdir \
		-v $${PWD}/keys:/tmp/keys \
		-e GOOGLE_APPLICATION_CREDENTIALS=/tmp/$(GOOGLE_APPLICATION_CREDENTIALS) \
		--env "GLOBAL_NAMESPACE=${GLOBAL_NAMESPACE}" \
		--env "FIREBASE_NAMESPACE=${FIREBASE_NAMESPACE}" \
		--env "KUBERNETES_NAMESPACE=${KUBERNETES_NAMESPACE}" \
		--env "GOOGLE_STORAGE_NAMESPACE=${GOOGLE_STORAGE_NAMESPACE}" \
		$(DOCKER_RUN_ARGS) \
		$(DOCKER_IMAGE_TAG) \
		bash


# ---------------------------------------------------------------------------------------------------
# docker-pre-run
# ---------------------------------------------------------------------------------------------------

docker-pre-run:: general-pre-run


# ---------------------------------------------------------------------------------------------------
# docker-run
# ---------------------------------------------------------------------------------------------------

docker-run:: $(CACHE_DIR)/docker_last_build
	docker run -it -P \
		-v $${PWD}/keys:/tmp/keys \
		-e GOOGLE_APPLICATION_CREDENTIALS=/tmp/$(GOOGLE_APPLICATION_CREDENTIALS) \
		--env "GLOBAL_NAMESPACE=${GLOBAL_NAMESPACE}" \
		--env "FIREBASE_NAMESPACE=${FIREBASE_NAMESPACE}" \
		--env "KUBERNETES_NAMESPACE=${KUBERNETES_NAMESPACE}" \
		--env "GOOGLE_STORAGE_NAMESPACE=${GOOGLE_STORAGE_NAMESPACE}" \
		$(DOCKER_RUN_ARGS) \
		$(DOCKER_IMAGE_TAG)
		$(PY_EXECUTE_ARGS)


# ---------------------------------------------------------------------------------------------------
# docker-image-push
# ---------------------------------------------------------------------------------------------------

$(CACHE_DIR)/docker_last_push:: $(CACHE_DIR)/docker_last_build
	docker push $(DOCKER_IMAGE_TAG)
	date > $@


docker-image-push:: $(CACHE_DIR)/docker_last_push



# ---------------------------------------------------------------------------------------------------
# $(CACHE_DIR)/kubernetes_cluster_id
# ---------------------------------------------------------------------------------------------------

$(CACHE_DIR)/kubernetes_cluster_id:: Makefile
	@echo "Creating Kubernetes connection information cache: $@"
	mkdir -p $(CACHE_DIR)
	gcloud container clusters list --format "get(name)" > $@
	@echo $$(cat $@)


# ---------------------------------------------------------------------------------------------------
# $(CACHE_DIR)/kubernetes_cluster_zone
# ---------------------------------------------------------------------------------------------------

$(CACHE_DIR)/kubernetes_cluster_zone:: Makefile
	@echo "Creating Kubernetes connection information cache: $@"
	mkdir -p $(CACHE_DIR)
	gcloud container clusters list --format "get(zone)" > $@
	@echo $$(cat $@)


# ---------------------------------------------------------------------------------------------------
# kube-info-cache
# ---------------------------------------------------------------------------------------------------

kube-info-cache:: $(CACHE_DIR)/kubernetes_cluster_zone $(CACHE_DIR)/kubernetes_cluster_id


# ---------------------------------------------------------------------------------------------------
# kube-info-clean
# ---------------------------------------------------------------------------------------------------

kube-info-clean:: 
	rm -f $(CACHE_DIR)/kubernetes_cluster*


# ---------------------------------------------------------------------------------------------------
# kube-namespace
# ---------------------------------------------------------------------------------------------------

$(KUBERNETES_NAMESPACE_EXISTS):: Makefile
	@if [[ ! -z "$(KUBERNETES_NAMESPACE)" ]] && ! kubectl get namespace $(KUBERNETES_NAMESPACE); then \
		echo "Creating Kubernetes namespace: $(KUBERNETES_NAMESPACE)"; \
		kubectl create namespace $(KUBERNETES_NAMESPACE); \
	fi
	touch $@


kube-namespace:: $(KUBERNETES_NAMESPACE_EXISTS)


# ---------------------------------------------------------------------------------------------------
# kube-delete-namespace
# ---------------------------------------------------------------------------------------------------

kube-delete-namespace::
	kubectl delete namespace --grace-period=0 --force $(KUBERNETES_NAMESPACE)


# ---------------------------------------------------------------------------------------------------
# kube-pre-start
# ---------------------------------------------------------------------------------------------------

kube-pre-start:: general-pre-run


# ---------------------------------------------------------------------------------------------------
# $(KUBERNETES_DEPLOYMENT_POD_NAME)
# ---------------------------------------------------------------------------------------------------

$(KUBERNETES_DEPLOYMENT_POD_NAME):: $(KUBERNETES_NAMESPACE_EXISTS) kube-pre-start
	@echo -e "\n==== KUBERNETES DEPLOYMENT START ========================================"
	kubectl $(KUBERNETES_NAMESPACE_ARG) run $(KUBERNETES_DEPLOYMENT_NAME) \
		--grace-period 120 \
		--env "GLOBAL_NAMESPACE=${GLOBAL_NAMESPACE}" \
		--env "FIREBASE_NAMESPACE=${FIREBASE_NAMESPACE}" \
		--env "KUBERNETES_NAMESPACE=${KUBERNETES_NAMESPACE}" \
		--env "GOOGLE_STORAGE_NAMESPACE=${GOOGLE_STORAGE_NAMESPACE}" \
		--image $(DOCKER_IMAGE_TAG) \
		--image-pull-policy Always \
		$(KUBERNETES_DEPLOYMENT_ARGS)
	kubectl $(KUBERNETES_NAMESPACE_ARG) get pods --selector "run=$(KUBERNETES_DEPLOYMENT_NAME)" -o jsonpath='{.items[*].metadata.name}' --field-selector=status.phase=Pending > $@
	@echo "Kubernetes deployment created, pod: $$(cat $@)"


# ---------------------------------------------------------------------------------------------------
# $(CACHE_DIR)/kubernetes_last_deployment
# ---------------------------------------------------------------------------------------------------

$(CACHE_DIR)/kubernetes_last_deployment:: $(CACHE_DIR)/docker_last_push $(KUBERNETES_DEPLOYMENT_POD_NAME)
	touch $@


# ---------------------------------------------------------------------------------------------------
# kube-start
# ---------------------------------------------------------------------------------------------------

kube-start:: $(CACHE_DIR)/kubernetes_last_deployment


# ---------------------------------------------------------------------------------------------------
# kube-start-norebuild
# ---------------------------------------------------------------------------------------------------

kube-start-norebuild: $(KUBERNETES_DEPLOYMENT_POD_NAME)


# ---------------------------------------------------------------------------------------------------
# kube-pre-stop
# ---------------------------------------------------------------------------------------------------

kube-pre-stop::


# ---------------------------------------------------------------------------------------------------
# kube-stop
# ---------------------------------------------------------------------------------------------------

kube-stop:: kube-pre-stop
	@echo -e "\n==== KUBERNETES DEPLOYMENT STOP ==================================================="
	kubectl $(KUBERNETES_NAMESPACE_ARG) delete deployment $(KUBERNETES_DEPLOYMENT_NAME)
	rm -f $(KUBERNETES_DEPLOYMENT_POD_NAME)


# ---------------------------------------------------------------------------------------------------
# kube-logs
# ---------------------------------------------------------------------------------------------------

kube-logs::
	@if [[ ! -f $(KUBERNETES_DEPLOYMENT_POD_NAME) ]]; then \
		echo "ERROR: Kubernetes pod name cache not found: $(KUBERNETES_DEPLOYMENT_POD_NAME)"; \
		echo -e "Hint: Have you started the deployment with `make kube-start`?\n"; \
		exit 5; \
	fi
	@echo -e "\n==== KUBERNETES POD LOGS of $$(cat $(KUBERNETES_DEPLOYMENT_POD_NAME)) =============================="
	kubectl $(KUBERNETES_NAMESPACE_ARG) logs -f $$(cat $(KUBERNETES_DEPLOYMENT_POD_NAME))


# ---------------------------------------------------------------------------------------------------
# kube-start-logs
# ---------------------------------------------------------------------------------------------------

kube-start-logs:: kube-start kube-logs


# ---------------------------------------------------------------------------------------------------
# kube-list
# ---------------------------------------------------------------------------------------------------

kube-list::
	@echo -e "\n==== KUBERNETES DEPLOYMENT ========================================================"
	kubectl $(KUBERNETES_NAMESPACE_ARG) get deployment $(KUBERNETES_DEPLOYMENT_NAME) || true
	@echo -e "\n==== KUBERNETES PODS =============================================================="
	kubectl $(KUBERNETES_NAMESPACE_ARG) get pods --selector "run=$(KUBERNETES_DEPLOYMENT_NAME)" || true
	@echo -e ""

kube-ls:: kube-list


# ---------------------------------------------------------------------------------------------------
# kube-list-all
# ---------------------------------------------------------------------------------------------------

kube-list-all::
	kubectl $(KUBERNETES_NAMESPACE_ARG) get pods

kube-lsa:: kube-list-all




# -----------------------------------------------------------------------
# include package specific targets (if there is any)
# -----------------------------------------------------------------------

-include package.mk


# -----------------------------------------------------------------------
# debug stuff
# -----------------------------------------------------------------------

# 
#	# @echo "DEPS: $^"
#	# @echo "UDPATED DEPS: $?" 
#

