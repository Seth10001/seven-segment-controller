PROJECT_ROOT  := $(shell git rev-parse --show-toplevel)
GIT_DIR       := $(shell git rev-parse --git-dir)
RELATIVE_PATH := $(shell pwd | sed -e "s:^${PROJECT_ROOT}/*::g")


.PHONY: default
default:

.PHONY: hooks
hooks:
	ln -s "../../${RELATIVE_PATH}/post-checkout.sh" "${GIT_DIR}/hooks/post-checkout"

.PHONY: clean
clean:
	rm "${GIT_DIR}/hooks/post-checkout"
