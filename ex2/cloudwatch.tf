# ===========================
# Cloud watch
# ===========================
# resource "aws_cloudwatch_metric_alarm" "recovery" {
#   alarm_name         = "ex-recovery-a"
#   namespace          = "AWS/EC2"
#   evaluation_periods = 2
#   period             = 60
# 
#   alarm_actions = ["arn:aws:automate:ap-northeast-1:ec2:recover"]
# 
#   statistic           = "Minimum"
#   comparison_operator = "GreaterThanThreshold"
#   threshold           = 0.0
#   metric_name         = "StatusCheckFailed_System"
# 
#   dimensions = {
#     InstanceId = aws_instance.web.id
#   }
# 
#   depends_on = [aws_instance.web]
# }