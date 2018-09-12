resource "aws_api_gateway_rest_api" "DynamoDBOperations" {
    name        = "DynamoDBOperations"
    description = "This is my API for demonstration purposes"
}


resource "aws_api_gateway_resource" "DynamoDBOperations" {
    rest_api_id = "${aws_api_gateway_rest_api.DynamoDBOperations.id}"
    parent_id   = "${aws_api_gateway_rest_api.DynamoDBOperations.root_resource_id}"
    path_part   = "DynamoDBManager"
}


# We specify NONE for the --authorization-type parameter, which means that unauthenticated requests for this method are supported.
resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.DynamoDBOperations.id}"
  resource_id   = "${aws_api_gateway_resource.DynamoDBOperations.id}"
  http_method   = "POST"
  authorization = "NONE"
  # api_key_required = true
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id             = "${aws_api_gateway_rest_api.DynamoDBOperations.id}"
  resource_id             = "${aws_api_gateway_resource.DynamoDBOperations.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  status_code = "200"
  response_models  {
		"application/json" =  "Empty"
	}
}


# Link the method to the lambda function
# integration_http_method is used to communicate with the lamda function
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.DynamoDBOperations.id}"
  resource_id             = "${aws_api_gateway_resource.DynamoDBOperations.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/${aws_lambda_function.test_lambda.arn}/invocations"
}


resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = "${aws_api_gateway_rest_api.DynamoDBOperations.id}"
  resource_id = "${aws_api_gateway_resource.DynamoDBOperations.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"
  response_templates {
		"application/json" =  ""
	}
}


# Deployment
resource "aws_api_gateway_deployment" "DynamoDBOperationsDeployment" {
  depends_on = ["aws_api_gateway_integration.integration"]

  rest_api_id = "${aws_api_gateway_rest_api.DynamoDBOperations.id}"
  stage_name  = "prod"

}
