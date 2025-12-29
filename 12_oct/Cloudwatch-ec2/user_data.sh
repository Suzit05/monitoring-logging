#!/bin/bash
set -e



# Install CloudWatch Agent
yum install -y amazon-cloudwatch-agent



# CloudWatch Agent config (LOGS ONLY)
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/ec2/cw-instance/messages",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name": "/ec2/cw-instance/secure",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF
  

