help: ## Print help (default target)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

create: ## create all the ressources needed
	terraform init
	terraform apply

plan: ## plan
	terraform plan

apply: ## terraform apply auto approve short cut
	terraform apply -auto-approve

deploy: fmt lint apply ## format, lint and apply

fmt: ## format
	terraform fmt

lint: ## lint
	tflint

destroy: ## destroy all terraform ressources
	terraform destroy

.PHONY: help create apply deploy fmt lint destroy
