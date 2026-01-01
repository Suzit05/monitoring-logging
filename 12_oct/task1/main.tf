provider "aws" {
  region = "eu-north-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "cw_bucket" {
  bucket = "sz-bucket05-${random_id.suffix.hex}"
  force_destroy = true
  tags = {
    Name = "cloudwatch-s3-bucket"
  }
}
 #enable bucket level metrics - which not requre any longer now


#create cloudwatch alarm for bucket size

resource "aws_cloudwatch_metric_alarm" "s3_bucket_size_alarm" {
  alarm_name = "S3-Bucket-size-alarm"
  metric_name = "BucketSizeBytes"
  namespace = "AWS/S3"
  statistic = "Average"
  period = 300 #5min
  evaluation_periods = 1
  threshold = 102400000
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_description = "trigger when size exceed than 100 mb"
  dimensions = {
    BucketName = aws_s3_bucket.cw_bucket.bucket
    StorageType = "StandardStorage"
  }
  alarm_actions = [] #optional for further
}

#outputs

output "s3_bucket_name" {
  value = aws_s3_bucket.cw_bucket.bucket
}