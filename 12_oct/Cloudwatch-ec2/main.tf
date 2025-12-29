provider "aws" {
  region = "eu-north-1"
}

resource "aws_iam_role" "cw_role" {
    name = "cw-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "cw_policy" {
  role = aws_iam_role.cw_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "cw_profile" {
  name = "cw-profile"
  role = aws_iam_role.cw_role.name
}

resource "aws_instance" "web" {
  ami = "ami-0b46816ffa1234887"
  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.cw_profile.name
  //add user data to install cloudwatch agent
  user_data = file("user_data.sh")
  tags = {
    Name = "cw-instance"
  }
}

#cloudwatch cpu alarm

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "HighCPUutilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm when EC2 CPU exceeds 70%"
  

  dimensions = {
    InstanceId = aws_instance.web.id
  }
}
