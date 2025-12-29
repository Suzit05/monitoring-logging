output "bucket_name" {
  value = aws_s3_bucket.cw_bucket
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.s3_4xx_alarm
}