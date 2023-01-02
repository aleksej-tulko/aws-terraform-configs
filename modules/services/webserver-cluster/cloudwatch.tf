# Cloudwatch metrics
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name = "${var.cluster_name}-high-cpu-utilization"
  namespace = "AWS/EC2"
  metric_name = "CPUUtilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.server.name
  }
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period = 300
  statistic = "Average"
  threshold = 90
  unit = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  count = format("%.2s", var.instance_type) == "t2" ? 1 : 0
  alarm_name = "${var.cluster_name}-low-cpu-credit-balance"
  namespace = "AWS/EC2"
  metric_name = "CPUCreditBalance"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.server.name
  }
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period = 300
  statistic = "Minimum"
  threshold = 10
  unit = "Count"
}