resource "aws_s3_bucket" "static_site_bucket" {
  bucket = var.bucket_name
  acl    = "public-read"

  website {
    error_document = "error.html"
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_website_configuration" "static_site_bucket_website_config" {
  bucket = aws_s3_bucket.static_site_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "static_site_ip_allowlist" {
  bucket = aws_s3_bucket.static_site_bucket.bucket
  policy = jsonencode({
    Version = "2012-10-17" # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_version.html
    Id      = "Buckey_Policy_IP_Allow_List"
    Statement = [
      {
        Sid       = "IPAllow"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.static_site_bucket.arn,
          "${aws_s3_bucket.static_site_bucket.arn}/*",
        ]
        Condition = {
          NotIpAddress = {
            "aws:SourceIp" = local.ip_allow_list
          }
        }
      },
    ]
  })
}
