.EXPORT_ALL_VARIABLES:
OUT_DIR := ./_output
BIN_DIR := ./bin

APP_NAME=structs
PACKAGE=github.com/jasoet/structs
CURRENT_DIR=$(shell pwd)

VERSION=$(shell cat ${CURRENT_DIR}/VERSION)
BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
GIT_COMMIT=$(shell git rev-parse --short HEAD)
GIT_TAG=$(shell if [ -z "`git status --porcelain`" ]; then git describe --exact-match --tags HEAD 2>/dev/null; fi)
GIT_TREE_STATE=$(shell if [ -z "`git status --porcelain`" ]; then echo "clean" ; else echo "dirty"; fi)

$(shell mkdir -p $(OUT_DIR) $(BIN_DIR))

# perform static compilation
STATIC_BUILD?=true

override LDFLAGS += \
  -X ${PACKAGE}.version=${VERSION} \
  -X ${PACKAGE}.buildDate=${BUILD_DATE} \
  -X ${PACKAGE}.gitCommit=${GIT_COMMIT} \
  -X ${PACKAGE}.gitTreeState=${GIT_TREE_STATE}

ifeq (${STATIC_BUILD}, true)
override LDFLAGS += -extldflags "-static"
endif

ifneq (${GIT_TAG},)
IMAGE_TAG=${GIT_TAG}
IMAGE_TRACK=stable
LDFLAGS += -X ${PACKAGE}.gitTag=${GIT_TAG}
else
IMAGE_TAG?=$(GIT_COMMIT)
IMAGE_TRACK=latest
endif

# Code build targets
.PHONY: vendor
vendor:
	go mod vendor

# Main Test Targets (without docker)
.PHONY: test
test:
	go test -race -coverprofile=$(OUT_DIR)/coverage.out ./...

