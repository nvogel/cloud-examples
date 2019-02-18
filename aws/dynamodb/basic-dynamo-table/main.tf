provider "aws" {
  region = "eu-west-1"
}

locals {
  namespace = "nvgl"
  stage     = "test"
}

module "nvgl_test_product_catalog_label" {
  source    = "../../vendor/terraform-terraform-label"
  namespace = "${local.namespace}"
  stage     = "${local.stage}"
  name      = "ProductCatalog"
}

resource "aws_dynamodb_table" "ProductCatalog" {
  name           = "${module.nvgl_test_product_catalog_label.id}"
  hash_key       = "Id"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "Id"
    type = "N"
  }

  tags = "${module.nvgl_test_product_catalog_label.tags}"
}

module "nvgl_test_forum_label" {
  source    = "../../vendor/terraform-terraform-label"
  namespace = "${local.namespace}"
  stage     = "${local.stage}"
  name      = "Forum"
}

resource "aws_dynamodb_table" "Forum" {
  name           = "${module.nvgl_test_forum_label.id}"
  hash_key       = "Name"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "Name"
    type = "S"
  }

  tags = "${module.nvgl_test_forum_label.tags}"
}

module "nvgl_test_thread_label" {
  source    = "../../vendor/terraform-terraform-label"
  namespace = "${local.namespace}"
  stage     = "${local.stage}"
  name      = "Thread"
}

resource "aws_dynamodb_table" "Thread" {
  name      = "${module.nvgl_test_thread_label.id}"
  hash_key  = "ForumName"
  range_key = "Subject"

  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "ForumName"
    type = "S"
  }

  attribute {
    name = "Subject"
    type = "S"
  }

  tags = "${module.nvgl_test_thread_label.tags}"
}

module "nvgl_test_reply_label" {
  source    = "../../vendor/terraform-terraform-label"
  namespace = "${local.namespace}"
  stage     = "${local.stage}"
  name      = "Reply"
}

resource "aws_dynamodb_table" "Reply" {
  name      = "${module.nvgl_test_reply_label.id}"
  hash_key  = "Id"
  range_key = "ReplyDateTime"

  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "Id"
    type = "S"
  }

  attribute {
    name = "ReplyDateTime"
    type = "S"
  }

  attribute {
    name = "PostedBy"
    type = "S"
  }

  attribute {
    name = "Message"
    type = "S"
  }

  global_secondary_index {
    name            = "PostedBy-Message-Index"
    hash_key        = "PostedBy"
    range_key       = "Message"
    write_capacity  = 5
    read_capacity   = 5
    projection_type = "ALL"
  }

  tags = "${module.nvgl_test_reply_label.tags}"
}
