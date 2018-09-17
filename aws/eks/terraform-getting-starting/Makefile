help: ## Print help (default target)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install tools
	curl -o /usr/local/bin/kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/kubectl
	curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator
	chmod +x /usr/local/bin/kubectl
	chmod +x /usr/local/bin/aws-iam-authenticator
	test -f ~/.ssh/id_rsa || ssh-keygen -t rsa -N ""

allow_worker_join: ## The EKS service does not provide a cluster-level API parameter or resource to automatically configure the underlying Kubernetes cluster to allow worker nodes to join the cluster via AWS IAM role authentication.
	terraform output config_map_aws_auth  | kubectl apply -f -

kube_config: ## Generate kubeconfig configuration
	mkdir -p ~/.kube
	terraform output kubeconfig > ~/.kube/config

create: install ## create all the ressources needed
	terraform init
	terraform apply

apply: ## terraform apply auto approve short cut
	terraform apply -auto-approve

destroy: ## destroy all terraform ressources and kube config
	terraform destroy
	rm -f ~/.kube/config

nuke: ## destroy all things created (even your private key) !!!
	terraform destroy
	rm -f ~/.kube/config
	rm -f /usr/local/bin/aws-iam-authenticator
	rm -f /usr/local/bin/kubectl
	rm -f ~/.ssh/id_rsa
	rm -f ~/.ssh/id_rsa.pub

run: ## run
	kubectl run --image=nvgl/echo:0.0.3 echo

info: ## get info
	echo "Get public ip of the workers"
	aws ec2 describe-instances --region us-west-2 --query "Reservations[].Instances[].PublicIpAddress"

.PHONY: help create destroy
