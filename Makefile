hpr_image_name ?= icyleafcn/hpr
hpr_version ?= 0.6.2

all: build

build: clean-docker ## Docker build image
	docker build --no-cache -t $(hpr_image_name):$(hpr_version) .
	docker tag $(hpr_image_name):$(hpr_version) $(hpr_image_name):latest

publish:
	docker push $(hpr_image_name):latest
	docker push $(hpr_image_name):$(hpr_version)

run: clean-docker build
	docker-compose up

doc:
	docsify serve docs -p 3001

clean:
	rm -rf bin

clean-docker:
	docker-compose down
