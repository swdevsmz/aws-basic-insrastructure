resource "aws_iam_role" "role_eventbridge_control_ec2" {
  name = "role-eventbridge-control-ec2"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
         "events.amazonaws.com"
         ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role_eventbridge_control_ec2" {
  role       = aws_iam_role.role_eventbridge_control_ec2.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

# resource "aws_cloudwatch_event_rule" "eventbridge_control_ec2_start" {
#   name        = "eventbridge-control-ec2-start"
#   is_enabled  = true

#   # 月～金の朝10:00に起動
#   schedule_expression = "cron(0 1 ? * MON-FRI *)"
# }

# resource "aws_cloudwatch_event_target" "eventbridge_control_ec2_start" {
#   target_id = "StartInstance"
#   rule      = aws_cloudwatch_event_rule.eventbridge_control_ec2_start.name
#   arn       = "arn:aws:ssm:ap-northeast-1::automation-definition/AWS-StartEC2Instance:$DEFAULT"
#   role_arn  = aws_iam_role.role_eventbridge_control_ec2.arn

#   input = <<EOF
# {
#   "InstanceId": ["i-0123456789abcde"]
# }
# EOF
# }

resource "aws_cloudwatch_event_rule" "eventbridge_control_ec2_stop" {
  name  = "eventbridge-control-ec2-stop"
  state = "ENABLED"

  # 月～金の夜19:00に止める
  schedule_expression = "cron(0 10 ? * * *)" # UTC
}

resource "aws_cloudwatch_event_target" "eventbridge_control_ec2_stop" {
  target_id = "StopInstance"
  rule      = aws_cloudwatch_event_rule.eventbridge_control_ec2_stop.name
  arn       = "arn:aws:ssm:ap-northeast-1::automation-definition/AWS-StopEC2Instance:$DEFAULT"
  role_arn  = aws_iam_role.role_eventbridge_control_ec2.arn

  input = <<EOF
{
  "InstanceId": ["${aws_instance.amazonlinux.id}"]
}
EOF
}