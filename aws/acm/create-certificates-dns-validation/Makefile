help: ## Print help (default target)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

create: ## create all the ressources needed
	terraform init
	terraform apply

apply: ## terraform apply auto approve short cut
	terraform apply -auto-approve

destroy: ## destroy all terraform ressources and kube config
	terraform destroy

test: ## List certificates
	 aws acm list-certificates --region us-west-2


.PHONY: help create apply destroy test
