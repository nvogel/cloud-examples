help: ## Print help (default target)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## build and package code
	mkdir -p CreateThumbnail/build
	mkdir -p CreateThumbnail/deploy
	docker run --rm  -v "${PWD}/CreateThumbnail":/var/task lambci/lambda:build-python2.7 /usr/local/bin/pip install -r requirements.txt -t build
	cp CreateThumbnail/*.py CreateThumbnail/build
	cd CreateThumbnail/build && zip -r ../deploy/CreateThumbnail.zip *

clean: ## clean build directory
	rm -rf CreateThumbnail/build
	rm -rf  CreateThumbnail/deploy

create: build ## create all the ressources needed
	terraform init
	terraform apply

destroy: ## destroy all the ressources and clean the logs
	terraform destroy
	aws logs  delete-log-group --log-group-name '/aws/lambda/CreateThumbnail' --region us-west-2

test: ## invoke the lamda function via the s3 trigger
	terraform taint aws_s3_bucket_object.happyface
	terraform apply -auto-approve

logs: ## show cloud watch log
	aws logs describe-log-groups --region us-west-2
	aws logs filter-log-events --log-group-name "/aws/lambda/CreateThumbnail" --region us-west-2


.PHONY: build clean help
