resource "aws_s3_bucket" "examplebucket" {
  bucket = "nvgl-sse-256"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

}

resource "aws_s3_bucket_object" "examplebucket_object" {
  key                    = "someobject"
  bucket                 = "${aws_s3_bucket.examplebucket.id}"
  source                 = "files/index.html"
  storage_class          = "STANDARD_IA"
}


resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "nvgl-sse-kms"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.mykey.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_object" "examplebucket_object_kms" {
  key                    = "someobject"
  bucket                 = "${aws_s3_bucket.mybucket.id}"
  source                 = "files/index.html"
  storage_class          = "STANDARD_IA"
}
