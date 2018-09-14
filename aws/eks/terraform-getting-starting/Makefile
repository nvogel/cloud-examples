help: ## Print help (default target)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install tools
	curl -o /usr/local/bin/kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/kubectl
	curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator
	chmod +x /usr/local/bin/kubectl
	chmod +x /usr/local/bin/aws-iam-authenticator

generate_keypair: ## generate keypair
	ssh-keygen

allow_worker_join: ## The EKS service does not provide a cluster-level API parameter or resource to automatically configure the underlying Kubernetes cluster to allow worker nodes to join the cluster via AWS IAM role authentication.
	terraform output config_map_aws_auth  | kubectl apply -f -

kube_config: ## Generate kubeconfig configuration
	mkdir ~/.kube
	terraform output kubeconfig > ~/.kube/kubeconfig

create: ## create all the ressources needed
	terraform init
	terraform apply

destroy: ## destroy all the ressources and clean the logs
	terraform destroy
	rm ~/.kube/config

.PHONY: help create destroy
