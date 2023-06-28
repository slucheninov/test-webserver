ACCOUNT_NAME := autosetup
PROJECT_NAME := test-webserver
TAG ?= 0.0.4

build::
	docker build -t $(PROJECT_NAME):$(TAG) .
	docker image tag $(PROJECT_NAME):$(TAG) $(ACCOUNT_NAME)/$(PROJECT_NAME):$(TAG)

install::
	docker push $(ACCOUNT_NAME)/$(PROJECT_NAME):$(TAG)
