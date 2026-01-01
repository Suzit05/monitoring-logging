provider "aws" {
  region = "eu-north-1"
}

#random suffix to make bucket name unique
resource "random_id" "suffix" {
  byte_length = 4
}

#create s3 bucket
resource "aws_s3_bucket" "cw_bucket" {
  bucket = "sz-aws-bucket-05-${random_id.suffix.hex}" #unique
  force_destroy = true
  tags = {
    Name = "cw_bucket"
  }
}



#cloudwatch alarm
resource "aws_cloudwatch_metric_alarm" "s3_4xx_alarm" {
  alarm_name          = "s3-4xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1 #number of times to check and trigger
  metric_name         = "4xxErrors" #valid cloud watch metric name
  namespace           = "AWS/S3" #official namespace for s3
  period              = 300 #5min
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when there is one or more 4xx errors in 5min" 
  dimensions = {
    BucketName = aws_s3_bucket.cw_bucket.bucket
    StorageType= "AllStorageTypes"
  }
}


