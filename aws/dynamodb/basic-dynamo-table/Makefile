help: ## Print help (default target)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

create: ## create all the ressources needed
	terraform init
	terraform apply

apply: ## terraform apply auto approve short cut
	terraform apply -auto-approve

deploy: fmt lint apply ## format, lint and apply

fmt: ## format
	terraform fmt

lint: ## lint
	tflint

destroy: ## destroy all terraform ressources and kube config
	terraform destroy

data: ## Load data in dynamodb tables
	aws dynamodb batch-write-item --request-items file://data/ProductCatalog.json
	aws dynamodb batch-write-item --request-items file://data/Forum.json
	aws dynamodb batch-write-item --request-items file://data/Thread.json
	aws dynamodb batch-write-item --request-items file://data/Reply.json


.PHONY: help create apply deploy fmt lint destroy data
