# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "website" {
  bucket        = "nvglwebsite"
  force_destroy = true
  acl           = "public-read"

  website {
        index_document = "index.html"
  }

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[{
     "Sid":"PublicReadForGetBucketObjects",
     "Effect":"Allow",
     "Principal": "*",
     "Action":["s3:GetObject"],
     "Resource":["arn:aws:s3:::nvglwebsite/*"]
     }
   ]
}
EOF

  tags {
    Name        = "web_site"
  }
}

resource "aws_s3_bucket_object" "website" {
  key          = "index.html"
  bucket       = "${aws_s3_bucket.website.id}"
  source       = "files/index.html"
  content_type = "text/html"
}
