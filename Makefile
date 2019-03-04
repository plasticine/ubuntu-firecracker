build:
	docker build -t ubuntu-firecracker .

clean:


output:
	mkdir -p ./output

image: build output
	docker \
		run \
		--privileged \
		-it \
		--rm \
		-v $(shell pwd)/cache:/cache \
		-v $(shell pwd)/output:/output \
		-v $(shell pwd)/script:/script \
		ubuntu-firecracker bash
