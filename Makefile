IMAGE_NAME=detectron
DOCKER_FILE=Dockerfile
DOCKERHUB_IMAGE=teeboneding/$(IMAGE_NAME)

all: build push_dockerhub

build:
	docker build -t $(IMAGE_NAME) -f $(DOCKER_FILE) .

push_dockerhub:
	docker tag $(IMAGE_NAME) $(DOCKERHUB_IMAGE)
	docker login
	docker push $(DOCKERHUB_IMAGE)