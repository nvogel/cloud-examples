# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "static_site" {
  bucket        = "nvglwebsite"
  force_destroy = true
  acl           = "public-read"

  # configure an Amazon S3 bucket for website hosting
  # The website is then available at the AWS Region-specific website endpoint of the bucket
  # which is in one of the following formats :
  #     <bucket-name>.s3-website-<AWS-region>.amazonaws.com
  #     <bucket-name>.s3-website.<AWS-region>.amazonaws.com
  #     https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteEndpoints.html
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

resource "aws_s3_bucket_object" "static_site" {
  key          = "index.html"
  bucket       = "${aws_s3_bucket.static_site.id}"
  source       = "files/index.html"
  content_type = "text/html"
}

# Amazon CloudFront is a web service that speeds up distribution of your static and dynamic web content.
# CloudFront delivers your content through a worldwide network of data centers called edge locations.
# When a user requests content that you're serving with CloudFront, the user is routed to the edge location that provides the lowest latency (time delay)
# So that content is delivered with the best possible performance
resource "aws_cloudfront_distribution" "main" {

  # Where cloudfront get the files to distribute
  origin {
    # This value lets you distinguish multiple origins in the same distribution from one another.
    # The description for each origin must be unique within the distribution
    origin_id = "static_website"

    # The domain name for your origin - the Amazon S3 bucket, web server, .... from which you want CloudFront to get your web content
    #
    # When you are using a s3 bucket , you have two differents type of buckets possible:
    #   -  an amazon s3 bucket
    #   -  an amazon s3 Buckets Configured as Website Endpoints
    #
    # If you set up your bucket to be configured as a website endpoint, enter the Amazon S3 static website hosting endpoint for the bucket.
    #
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistS3AndCustomOrigins.html
    domain_name = "${aws_s3_bucket.static_site.website_endpoint}"

    # If you use the CloudFront API to create your distribution with an Amazon S3 bucket that is configured as a website endpoint,
    # you must configure it by using CustomOriginConfig, even though the website is hosted in an Amazon S3 bucket
    custom_origin_config {
        origin_protocol_policy = "http-only"
        http_port = "80"
        https_port = "443"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  # One of the purposes of using CloudFront is to reduce the number of requests that your origin server must respond to directly.
  # This reduces the load on your origin server and also reduces latency because more objects are served from CloudFront edge locations, which are closer to your users.
  # The more requests that CloudFront is able to serve from edge caches as a proportion of all requests (that is, the greater the cache hit ratio), the fewer viewer requests that CloudFront needs to forward to your origin to get the latest version or a unique version of an object.

  # The default cache behavior only allows a path pattern of * (forward all requests to the origin specified by Origin).

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["HEAD", "GET"]

    # The value of ID for the origin that you want CloudFront to route requests to when a request matches the path pattern either for a cache behavior or for the default cache behavior.
    target_origin_id = "static_website"

    # If you want CloudFront to allow viewers to access your web content using either HTTP or HTTPS, specify HTTP and HTTPS. If you want CloudFront to redirect all HTTP requests to HTTPS, specify Redirect HTTP to HTTPS. If you want CloudFront to require HTTPS, specify HTTPS Only
    # One of allow-all, https-only, or redirect-to-https. [required]
    viewer_protocol_policy = "redirect-to-https"

    # The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an Cache-Control max-age or Expires header. Defaults to 1 day.
    default_ttl = 300

    # The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated. Only effective in the presence of Cache-Control max-age, Cache-Control s-maxage, and Expires headers
    max_ttl = 0

    # The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated. Defaults to 0 seconds.
    min_ttl = 0

    # Select whether you want CloudFront to include all user cookies in the request URLs that it forwards to your origin (All), only selected cookies (Whitelist), or no cookies (None)
    # Select which query string parameters you want CloudFront to forward to the origin (all or none) and which parameters you want CloudFront to base caching on
    forwarded_values {
        cookies {
            forward = "all"
        }
        query_string = true
    }
  }

  # The restriction configuration for this distribution [required]
  restrictions {
      geo_restriction {
        restriction_type = "none"
      }
  }

  # The SSL configuration for this distribution
  viewer_certificate {
      # Choose this option if you want your users to use HTTPS or HTTP to access your content with the CloudFront domain name (such as https://d111111abcdef8.cloudfront.net/logo.jpg)
      cloudfront_default_certificate = true
  }

  # Whether the distribution is enabled to accept end user requests for conten
  enabled = true

  # The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL.
  default_root_object = "index.html"

  tags {
    Owner = "Me"
  }
}
