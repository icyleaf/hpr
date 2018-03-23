all: build, release

build: clean ## Docker build image
	docker build -t icyleafcn/hpr:build -f Dockerfile.build .

release:  ## Docker release image
	docker container create --name extract icyleafcn/hpr:build
	docker container cp extract:/app/bin/hpr ./hpr
	docker container cp extract:/app/deps ./deps
	docker container rm -f extract

	docker build --no-cache -t icyleafcn/hpr:0.1.0 .
	rm -rf hpr deps

clean:
	rm -rf bin hpr deps
