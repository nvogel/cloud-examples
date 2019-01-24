data "template_file" "aws_config_require_tags" {
  template = "${file("${path.module}/config-policies/require-tags.tpl")}"
  count    = "${length(var.tags)}"

  vars {
    json = "${jsonencode(var.tags[count.index])}"
  }

}

// require-tags is limited to 6 tags so we can for example create several rules
resource "aws_config_config_rule" "require-tags" {
  name             = "require-tags-${count.index}"
  count            = "${length(var.tags)}"

  description      = "Checks whether your resources have the tags that you specify"
  input_parameters = "${data.template_file.aws_config_require_tags.*.rendered[count.index]}"

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  depends_on = ["aws_config_configuration_recorder.foo"]
}
