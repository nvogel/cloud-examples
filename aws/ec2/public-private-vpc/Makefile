help: ## Print help (default target)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

create: ## create all the ressources needed
	terraform init
	terraform apply

apply: ## terraform apply auto approve short cut
	terraform apply -auto-approve

destroy: ## destroy all terraform ressources and kube config
	terraform destroy

cf-create: ## create a stack with cloud formation
	aws cloudformation create-stack --stack-name lab1 --template-body file:///$(CURDIR)/cloud-formation.yaml

cf-update: ## update cloud formation stack
	aws cloudformation update-stack --stack-name lab1 --template-body file:///$(CURDIR)/cloud-formation.yaml

cf-delete: ## delete cloud formation stack
	aws cloudformation delete-stack --stack-name lab1

.PHONY: help create apply destroy
