# -----------------------------------------------------------------------------
# description: Flask extension for General Python Makefile
# licence: GPL3 <https://opensource.org/licenses/GPL3>
# author: Daniel Kovacs <danadeasysau@gmail.com>
# version: 0.10
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# default flask config
# -----------------------------------------------------------------------------

export FLASK_APP=$(PY_MODULE_NAME)
export FLASK_ENV=development 
export FLASK_APP_CONFIG=$(PACKAGE_NAME).config.DevelopmentConfig
export FLASK_VARS=export FLASK_APP=$(FLASK_APP) && export FLASK_ENV=$(FLASK_ENV)
export FLASK_AUTH_USERNAME=dev
export FLASK_AUTH_PASSWORD=8381ljhlzxvnz,mn23;lk12l;()*&72n,n,123nkjn123==

export FLASK_SERVICE_PORT=8080
export KUBE_PUBLIC_PORT=80


# -----------------------------------------------------------------------------
# python config overrides
# -----------------------------------------------------------------------------

export PY_MODULE_NAME=$(PACKAGE_NAME).app:app
export PY_EXECUTABLE=waitress-serve --listen *:$(FLASK_SERVICE_PORT) $(PY_MODULE_NAME)
		

# -----------------------------------------------------------------------------
# docker configuration overrides
# -----------------------------------------------------------------------------

DOCKER_IMAGE_BUILD_ARGS=--build-arg FLASK_SERVICE_PORT \
	--build-arg FLASK_ENV=production \
	--build-arg FLASK_APP_CONFIG=$(PACKAGE_NAME).config.ProductionConfig


DOCKER_RUN_ARGS=-p $(FLASK_SERVICE_PORT):$(FLASK_SERVICE_PORT) \
	--env FLASK_AUTH_USERNAME='$(FLASK_AUTH_USERNAME)' \
	--env FLASK_AUTH_PASSWORD='$(FLASK_AUTH_PASSWORD)' 


# -----------------------------------------------------------------------------
# kubernetes configuration overrides
# -----------------------------------------------------------------------------

KUBERNETES_DEPLOYMENT_ARGS_0=--port $(FLASK_SERVICE_PORT) \
	--env FLASK_AUTH_USERNAME='$(FLASK_AUTH_USERNAME)' \
	--env FLASK_AUTH_PASSWORD='$(FLASK_AUTH_PASSWORD)' 



# -----------------------------------------------------------------------------
# dev
# -----------------------------------------------------------------------------
#
# Start local development server
#

.PHONY: dev
flask-dev:: setup
	source activate && $(FLASK_VARS) && flask run --port $(FLASK_SERVICE_PORT)

dev:: flask-dev


# -----------------------------------------------------------------------------
# shell
# -----------------------------------------------------------------------------

.PHONY: flask-shell
flask-shell:: setup
	source activate && $(FLASK_VARS) && flask shell


# -----------------------------------------------------------------------------
# db-create
# -----------------------------------------------------------------------------
#
# Initialize the local database
#

db-create:: setup
	source activate && flask create_db



# -----------------------------------------------------------------------------
# kube-service-start
# -----------------------------------------------------------------------------
#

kube-service-start: kube-start
	kubectl $(KUBERNETES_NAMESPACE_ARG) expose deployment $(KUBERNETES_DEPLOYMENT_NAME) --type=LoadBalancer --port $(KUBE_PUBLIC_PORT) --target-port $(FLASK_SERVICE_PORT)	


# -----------------------------------------------------------------------------
# kube-service-stop
# -----------------------------------------------------------------------------
#

kube-service-stop: kube-stop
	kubectl $(KUBERNETES_NAMESPACE_ARG) delete service $(KUBERNETES_DEPLOYMENT_NAME)


# -----------------------------------------------------------------------------
# kube-service-status
# -----------------------------------------------------------------------------
#

kube-service-ls: 
	kubectl $(KUBERNETES_NAMESPACE_ARG) get services 


# -----------------------------------------------------------------------------
# kube-service-status
# -----------------------------------------------------------------------------
#

kube-service-public-ip:
	kubectl --namespace devbox get services --selector run=my_service -o jsonpath='{.items[*].status.loadBalancer.ingress[*].ip}'


# -----------------------------------------------------------------------------
# kube-service-status
# -----------------------------------------------------------------------------
#

kube-service-status: 
	gcloud compute forwarding-rules list

