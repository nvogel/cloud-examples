provider "aws" {
  region = "eu-west-1"
}

provider "http" {}

data "aws_ami" "amazon-linux-2" {
 most_recent = true


 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*-x86_64-ebs"]
 }


  filter {
      name   = "architecture"
      values = ["x86_64"]
  }

  filter {
      name   = "root-device-type"
      values = ["ebs"]
  }

}


resource "aws_security_group" "ssh" {
  name        = "allow_ssh"
  description = "Allow ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.workstation-external-cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "t2.micro"
  key_name = "nvogel"
  security_groups = ["${aws_security_group.ssh.name}"]
  iam_instance_profile = "${aws_iam_instance_profile.event.name}"

  tags = {
    Name = "Test-sns"
  }
}


resource "aws_iam_instance_profile" "event" {
  name = "event"
  role = "${aws_iam_role.event.name}"
}

resource "aws_iam_role" "event" {
  name = "event"
  path = "/"

assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "event" {
  name        = "event_policy"
  path        = "/"
  description = "event policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
      "Effect": "Allow",
      "Action" : [
        "events:PutEvents"
      ],
      "Resource" : "*"
  }]
}
EOF
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = ["${aws_iam_role.event.name}"]
  policy_arn = "${aws_iam_policy.event.arn}"
}

resource "aws_cloudwatch_event_rule" "build" {
  name        = "build-custom-event"
  description = "Build Custom Event"

  event_pattern = <<PATTERN
{
  "source": [
    "com.ami.builder"
  ],
  "detail-type": [
    "AmiBuilder"
  ],
  "detail": {
    "AmiStatus": [ "Created" ]
  }
}
PATTERN
}

resource "aws_sns_topic" "ami_build_notification" {
  name = "build-notification"
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = "${aws_cloudwatch_event_rule.build.name}"
  target_id = "SendToSNS"
  arn       = "${aws_sns_topic.ami_build_notification.arn}"
}


resource "aws_sns_topic_policy" "default" {
  arn    = "${aws_sns_topic.ami_build_notification.arn}"
  policy = "${data.aws_iam_policy_document.sns_topic_policy.json}"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = ["${aws_sns_topic.ami_build_notification.arn}"]
  }
}
