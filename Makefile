hpr_image_name ?= icyleafcn/hpr
hpr_version ?= 0.8.0

all: build

builder:
	docker build -t $(hpr_image_name):$(hpr_version)-builder -f Dockerfile.build .

build:
	docker build -t $(hpr_image_name):$(hpr_version) .
	docker tag $(hpr_image_name):$(hpr_version) $(hpr_image_name):latest

publish:
	docker push $(hpr_image_name):latest
	docker push $(hpr_image_name):$(hpr_version)

doc:
	docsify serve docs -p 3001
