.PHONY: help
help: ## Print help (default target)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: apply
apply: ## terraform apply
	terraform init
	terraform apply

.PHONY: nuke
nuke: destroy clean ## destroy all things created
	echo "Nuke done"

.PHONY: destroy
destroy: ## destroy all things created
	terraform destroy

.PHONY: clean
clean: ## cleqn all things created
	rm -f terraform.tfstate.backup
	rm -f terraform.tfstate
	rm -f ./var

.PHONY: fmt
fmt: ## format
	terraform fmt

.PHONY: lint
lint: ## lint
	tflint

.PHONY: output
output: ## output
	terraform output
