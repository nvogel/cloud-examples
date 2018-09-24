help: ## Print help (default target)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## build and package code
	mkdir -p src/build
	mkdir -p src/deploy
	docker run --rm  -v "${PWD}/src":/var/task lambci/lambda:build-python2.7 /usr/local/bin/pip install -r requirements.txt -t build
	cp src/*.py src/build
	cd src/build && zip -r ../deploy/LambdaFunction.zip *

clean: ## clean build directory
	rm -rf src/build
	rm -rf  src/deploy

create: build ## create all the ressources needed
	terraform init
	terraform apply

destroy: ## destroy all the ressources and clean the logs
	terraform destroy
	aws logs  delete-log-group --log-group-name '/aws/lambda/LambdaFunction' --region us-west-2

logs: ## show cloud watch log
	aws logs filter-log-events --log-group-name "/aws/lambda/LambdaFunction" --region us-west-2

test: ## tests
	./tests/run.sh


.PHONY: build clean help
