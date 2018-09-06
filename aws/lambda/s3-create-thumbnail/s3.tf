# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "nvglsource" {
  bucket = "nvglsource"
  force_destroy = true
  acl    = "private"

  tags {
    Name        = "nvglsource"
  }
}

resource "aws_s3_bucket" "nvglsourceresized" {
  bucket = "nvglsourceresized"
  force_destroy = true
  acl    = "private"

  tags {
    Name        = "nvglsourceresized"
  }
}


resource "aws_s3_bucket_object" "happyface" {
  key                    = "HappyFace.jpg"
  bucket                 = "${aws_s3_bucket.nvglsource.id}"
  source                 = "HappyFace.jpg"
}
