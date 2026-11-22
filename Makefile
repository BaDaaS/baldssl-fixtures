# Deterministic archive of the fixtures, for a release. Needs GNU tar.
# A failing stage of the pipe must fail the recipe, not leave an empty
# archive: the pipeline sets pipefail itself (.SHELLFLAGS needs make 3.82).
SHELL := /bin/bash
TAG ?= $(shell git describe --tags --exact-match 2>/dev/null)
NAME = baldssl-fixtures-$(TAG)
TAR ?= tar

.PHONY: help
help: ## Ask for help!
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; \
		{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: archive
archive: ## Build dist/baldssl-fixtures-<TAG>.tar.gz and its SHA-256
	@test -n "$(TAG)" || { echo "TAG is not set"; exit 1; }
	rm -rf dist && mkdir -p dist
	set -o pipefail; git ls-files -z -- cases.txt cavp certs ecdsa golden keys | \
		$(TAR) --null --files-from=- --sort=name --mtime=@0 \
		--owner=0 --group=0 --numeric-owner --format=gnu \
		--transform 's,^,$(NAME)/,' -cf - | gzip -n -9 \
		> dist/$(NAME).tar.gz
	cd dist && sha256sum $(NAME).tar.gz > $(NAME).tar.gz.sha256
	cat dist/$(NAME).tar.gz.sha256

.PHONY: clean
clean: ## Remove dist/
	rm -rf dist
