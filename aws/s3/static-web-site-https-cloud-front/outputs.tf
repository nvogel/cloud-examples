#
# Outputs
#


# bucket_regional_domain_name = nvglwebsite.s3.us-west-2.amazonaws.com
# domain = s3-website-us-west-2.amazonaws.com
# website_endpoint = nvglwebsite.s3-website-us-west-2.amazonaws.com


output "website_endpoint" {
  value = "${aws_s3_bucket.static_site.website_endpoint}"
}

output "website_domain" {
  value = "${aws_s3_bucket.static_site.website_domain}"
}

output "bucket_regional_domain_name" {
  value = "${aws_s3_bucket.static_site.bucket_regional_domain_name}"
}

output "cloud_front_domain" {
  value = "${aws_cloudfront_distribution.main.domain_name}"
}

output "cloud_front_status" {
  value = "${aws_cloudfront_distribution.main.status}"
}
