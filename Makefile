FIREBASE_VERSION = 14.2.1
NODE_VERSION = 20

IMAGE_NAME ?= firebase-emulator-suite
DOCKERHUB_IMAGE ?= fixl/$(IMAGE_NAME)
GITLAB_IMAGE ?= registry.gitlab.com/fixl/docker-$(IMAGE_NAME)

BUILD_DATE = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

CI_COMMIT_SHORT_SHA ?= $(shell git rev-parse --short HEAD)
CI_PROJECT_URL ?= $(shell git config --get remote.origin.url)
CI_PIPELINE_URL ?= local

TAG = $(FIREBASE_VERSION)

EXTRACTED_FILE = extracted.tar
DOCKER_BUILDKIT = 1

TRIVY_COMMAND = docker compose run --rm trivy
ANYBADGE_COMMAND = docker compose run --rm anybadge
BINFMT_COMMAND = docker compose run --rm binfmt

# Computed
MAJOR = $(shell echo ${FIREBASE_VERSION} | awk -F. '{print $$1}')
MINOR = $(shell echo ${FIREBASE_VERSION} | awk -F. '{print $$1"."$$2}')
PATCH = $(FIREBASE_VERSION)

GITLAB_IMAGE_LATEST = $(GITLAB_IMAGE)
GITLAB_IMAGE_MAJOR = $(GITLAB_IMAGE):$(MAJOR)
GITLAB_IMAGE_MINOR = $(GITLAB_IMAGE):$(MINOR)
GITLAB_IMAGE_PATCH = $(GITLAB_IMAGE):$(PATCH)

DOCKERHUB_IMAGE_LATEST = $(DOCKERHUB_IMAGE)
DOCKERHUB_IMAGE_MAJOR = $(DOCKERHUB_IMAGE):$(MAJOR)
DOCKERHUB_IMAGE_MINOR = $(DOCKERHUB_IMAGE):$(MINOR)
DOCKERHUB_IMAGE_PATCH = $(DOCKERHUB_IMAGE):$(PATCH)

# Export vairables for child processes
.EXPORT_ALL_VARIABLES:

/proc/sys/fs/binfmt_misc/qemu-aarch64:
	$(BINFMT_COMMAND) --install arm64
	-docker buildx create --use --name firebase

build:
	docker buildx build \
		--platform linux/amd64 \
		--progress=plain \
		--pull \
		--load \
		--build-arg FIREBASE_VERSION=$(FIREBASE_VERSION) \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
		--tag $(IMAGE_NAME) \
		--tag $(GITLAB_IMAGE_LATEST) \
		--tag $(GITLAB_IMAGE_MAJOR) \
		--tag $(GITLAB_IMAGE_MINOR) \
		--tag $(GITLAB_IMAGE_PATCH) \
		--tag $(DOCKERHUB_IMAGE_LATEST) \
		--tag $(DOCKERHUB_IMAGE_MAJOR) \
		--tag $(DOCKERHUB_IMAGE_MINOR) \
		--tag $(DOCKERHUB_IMAGE_PATCH) \
		.

publish: /proc/sys/fs/binfmt_misc/qemu-aarch64
	docker buildx build \
		--platform linux/arm64,linux/amd64\
		--progress=plain \
		--pull \
		--push \
		--build-arg FIREBASE_VERSION=$(FIREBASE_VERSION) \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
		--label "org.opencontainers.image.title=$(IMAGE_NAME)" \
		--label "org.opencontainers.image.url=https://github.com/firebase/firebase-js-sdk" \
		--label "org.opencontainers.image.authors=@fixl" \
		--label "org.opencontainers.image.version=$(FIREBASE_VERSION)" \
		--label "org.opencontainers.image.created=$(BUILD_DATE)" \
		--label "org.opencontainers.image.source=$(CI_PROJECT_URL)" \
		--label "org.opencontainers.image.revision=$(CI_COMMIT_SHORT_SHA)" \
		--label "info.fixl.gitlab.pipeline-url=$(CI_PIPELINE_URL)" \
		--tag $(GITLAB_IMAGE_LATEST) \
		--tag $(GITLAB_IMAGE_MAJOR) \
		--tag $(GITLAB_IMAGE_MINOR) \
		--tag $(GITLAB_IMAGE_PATCH) \
		--tag $(DOCKERHUB_IMAGE_LATEST) \
		--tag $(DOCKERHUB_IMAGE_MAJOR) \
		--tag $(DOCKERHUB_IMAGE_MINOR) \
		--tag $(DOCKERHUB_IMAGE_PATCH) \
		.

scan: $(EXTRACTED_FILE)
	if [ ! -f gitlab.tpl ] ; then curl --output gitlab.tpl https://raw.githubusercontent.com/aquasecurity/trivy/v$(shell docker compose run --rm trivy sh -c "trivy version" | grep Version | head -n1 | awk '{print $$2}')/contrib/gitlab.tpl;  fi

	$(TRIVY_COMMAND) trivy image --input $(EXTRACTED_FILE) --exit-code 0 --no-progress --format template --template "@gitlab.tpl" -o gl-container-scanning-report.json $(IMAGE_NAME)
	$(TRIVY_COMMAND) trivy image --input $(EXTRACTED_FILE) --exit-code 1 --no-progress --ignore-unfixed --severity CRITICAL $(IMAGE_NAME)

$(EXTRACTED_FILE):
	docker save --output $(EXTRACTED_FILE) $(IMAGE_NAME)

shell:
	docker run --rm -it --entrypoint "" $(IMAGE_NAME) bash
.PHONY: shell

badges:
	mkdir -p public
	$(ANYBADGE_COMMAND) docker-size $(DOCKERHUB_IMAGE_PATCH) public/size
	$(ANYBADGE_COMMAND) docker-version $(DOCKERHUB_IMAGE_PATCH) public/version

gitRelease:
	-git tag -d $(TAG)
	-git push origin :refs/tags/$(TAG)
	git tag $(TAG)
	git push origin $(TAG)
	git push

clean:
	$(TRIVY_COMMAND) rm -rf gitlab.tpl .cache *.tar
	-$(BINFMT_COMMAND) --uninstall qemu-aarch64
	-docker buildx prune --force --all
	-docker buildx rm firebase
	-docker rmi $(IMAGE_NAME)
	-docker rmi $(GITLAB_IMAGE_LATEST)
	-docker rmi $(GITLAB_IMAGE_MAJOR)
	-docker rmi $(GITLAB_IMAGE_MINOR)
	-docker rmi $(GITLAB_IMAGE_PATCH)
	-docker rmi $(DOCKERHUB_IMAGE_LATEST)
	-docker rmi $(DOCKERHUB_IMAGE_MAJOR)
	-docker rmi $(DOCKERHUB_IMAGE_MINOR)
	-docker rmi $(DOCKERHUB_IMAGE_PATCH)

cleanAll:
	$(TRIVY_COMMAND) rm -rf public
	$(MAKE) clean
