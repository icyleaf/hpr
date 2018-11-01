hpr_image_name ?= icyleafcn/hpr
hpr_version ?= 0.6.2

all: build

build:
	docker build --no-cache -t $(hpr_image_name):$(hpr_version) .
	docker tag $(hpr_image_name):$(hpr_version) $(hpr_image_name):latest

publish:
	docker push $(hpr_image_name):latest
	docker push $(hpr_image_name):$(hpr_version)

doc:
	docsify serve docs -p 3001
