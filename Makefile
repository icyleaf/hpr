hpr_image_name ?= icyleafcn/hpr
hpr_version ?= 0.3.0

all: build release

build: clean ## Docker build image
	docker build --no-cache -t $(hpr_image_name):build -f Dockerfile.build .

release:  ## Docker release image
	docker container create --name extract icyleafcn/hpr:build
	docker container cp extract:/app/bin/hpr ./hpr
	docker container cp extract:/app/deps ./deps
	docker container rm -f extract

	docker build --no-cache -t $(hpr_image_name):$(hpr_version) .
	rm -rf hpr deps

publish: release
	docker tag $(hpr_image_name):$(hpr_version) $(hpr_image_name):latest
	docker push $(hpr_image_name):latest
	docker push $(hpr_image_name):$(hpr_version)

clean:
	rm -rf bin hpr deps
