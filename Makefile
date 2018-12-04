hpr_image_name ?= icyleafcn/hpr
hpr_version ?= 0.9.1

all: build

build: build-alpine build-ubuntu

publish: publish-alpine publish-ubuntu

alpine: build-alpine publish-alpine

ubuntu: build-ubuntu publish-ubuntu

build-alpine:
	docker build -t $(hpr_image_name):$(hpr_version)-alpine .
	docker tag $(hpr_image_name):$(hpr_version)-alpine $(hpr_image_name):alpine

publish-alpine:
	docker push $(hpr_image_name):ubuntu
	docker push $(hpr_image_name):$(hpr_version)-ubuntu

build-ubuntu:
	docker build -t $(hpr_image_name):$(hpr_version)-ubuntu -f Dockerfile.ubuntu .
	docker tag $(hpr_image_name):$(hpr_version)-ubuntu $(hpr_image_name):ubuntu

publish-ubuntu:
	docker push $(hpr_image_name):ubuntu
	docker push $(hpr_image_name):$(hpr_version)-ubuntu

doc:
	docsify serve docs -p 3001
