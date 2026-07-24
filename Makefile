.PHONY: fmt validate init test test-unit test-integration docs lint security-scan check-all

fmt:
	terraform fmt -recursive

# Note: standalone `terraform validate` is not supported for modules that declare
# `configuration_aliases` in required_providers — aliased providers must be supplied
# by a root caller. Configuration correctness is validated via `make test-unit`,
# which runs the full module with mock providers.
validate: init
	terraform validate

init:
	terraform init -backend=false

test: test-unit test-integration

test-unit: init
	terraform test -test-directory=tests/unit

test-integration: init
	terraform test -test-directory=tests/integration

docs:
	terraform-docs .
	for dir in examples/*/; do terraform-docs "$$dir"; done

lint:
	terraform fmt -check -recursive

security-scan:
	trivy config --config .trivy.yaml .

check-all: fmt docs lint security-scan test-unit
