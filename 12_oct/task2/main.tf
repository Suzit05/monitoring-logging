provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "myec2" {
  instance_type = "t3.micro"
  ami = "ami-0b46816ffa1234887"
  tags = {
    Name = "ec2-web"
  }
}

resource "aws_sns_topic" "alarm_topic" {
  name = "Ec2-alarm-topic"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol = "email"
  endpoint = "sujeet05kp@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "HighCPUutilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120 #2min
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when EC2 CPU exceeds 80%"

  dimensions = {
    InstanceId = aws_instance.myec2.id
  }
  alarm_actions = [aws_sns_topic.alarm_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "net_alarm" {
  alarm_name          = "ec2-high-network-out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Sum"
  threshold           = 50000000 #50mb
  alarm_description   = "high network outband traffic" 

  dimensions = {
    InstanceId = aws_instance.myec2.id
  }
  alarm_actions = [aws_sns_topic.alarm_topic.arn]
}