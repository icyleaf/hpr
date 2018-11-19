hpr_image_name ?= icyleafcn/hpr
hpr_version ?= 0.8.0

all: build

build: build-alpine build-ubuntu

build-ubuntu:
	docker build -t $(hpr_image_name):$(hpr_version)-ubuntu -f Dockerfile.ubuntu .
	docker tag $(hpr_image_name):$(hpr_version)-ubuntu $(hpr_image_name):ubuntu

build-alpine:
	docker build -t $(hpr_image_name):$(hpr_version) .
	docker tag $(hpr_image_name):$(hpr_version) $(hpr_image_name):latest

publish:
	docker push $(hpr_image_name):latest
	docker push $(hpr_image_name):$(hpr_version)

doc:
	docsify serve docs -p 3001
