build:
	docker build -t ubuntu-firecracker .

run:
	docker \
		run \
		--privileged \
		-it \
		--rm \
		-v $(shell pwd)/output:/output \
		-v $(shell pwd)/script:/script \
		ubuntu-firecracker \
		bash
