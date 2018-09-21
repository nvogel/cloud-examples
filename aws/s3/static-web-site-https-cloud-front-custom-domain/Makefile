help: ## Print help (default target)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

tools: ## Install toops
	which yum && yum install -f httpie bind-utils

create: ## create all the ressources needed
	terraform init
	terraform apply

apply: ## terraform apply auto approve short cut
	terraform apply -auto-approve

destroy: ## destroy all terraform ressources and kube config
	terraform destroy

get_ns_delegation: ## print the NS entries that be be added in the master zone for dns delegation
	terraform output zone_ns

test_bucket_website: ## test bucket website directly without cloud front
	curl -v $(terraform output website_endpoint)

test_cloud_front_domain_https: ## test wesite via the cloud front domain and https
	curl -v "https://$(terraform output cloud_front_domain)" -v


test_cloud_front_domain_http: ## test wesite via the cloud front domain and https
	curl "http://$(terraform output cloud_front_domain)" -v

.PHONY: help create apply destroy test_bucket_website test_cloud_front_domain_https test_cloud_front_domain_http
