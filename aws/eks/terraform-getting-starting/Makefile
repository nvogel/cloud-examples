help: ## Print help (default target)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install tools
	curl -o /usr/local/bin/kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/darwin/amd64/kubectl
	curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/darwin/amd64/aws-iam-authenticator
	chmod +x /usr/local/bin/kubectl
	chmod +x /usr/local/bin/aws-iam-authenticator

allow_worker_join: ## The EKS service does not provide a cluster-level API parameter or resource to automatically configure the underlying Kubernetes cluster to allow worker nodes to join the cluster via AWS IAM role authentication.
	terraform output config_map_aws_auth  | kubectl apply -f -

kube_config: ## Generate kubeconfig configuration
	mkdir -p var/kube
	terraform output kubeconfig > var/kube/config

create: install ## create all the ressources needed
	terraform init
	terraform apply

auto-scaler: ## deploy the cluster auto scaler
	kubectl apply -f workloads/cluster-autoscaler/cluster-autoscaler-eks.yaml

test-auto-scaler: ## test the auto-scaler
	kubectl apply -f workloads/cluster-autoscaler/nginx.yaml

apply: ## terraform apply auto approve short cut
	terraform apply -auto-approve

nuke: ## destroy all things created
	terraform destroy
	rm -f ./var

run: ## run
	kubectl run --image=nvgl/echo:0.0.3 echo

info: ## get info
	echo "Get public ip of the workers"
	aws ec2 describe-instances --region us-west-2 --query "Reservations[].Instances[].PublicIpAddress"

.PHONY: help create destroy install allow_worker_join kube_config run info auto-scaler
