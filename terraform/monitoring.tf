resource "aws_sns_topic" "triage_alarms" {
  name = "triaige-cloudwatch-alarms"

  tags = {
    Name        = "triaige-cloudwatch-alarms"
    Project     = "triaige"
    Component   = "monitoring"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "triage_alarm_email" {
  topic_arn = aws_sns_topic.triage_alarms.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "mysql_disk_usage_high" {
  alarm_name          = "triaige-mysql-disk-usage-high"
  alarm_description   = "Alerta quando o disco do banco ultrapassa 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [aws_sns_topic.triage_alarms.arn]

  dimensions = {
    path     = "/var/lib/mysql"
    instance = "triaige-ec2-mysql"
  }
}

resource "aws_cloudwatch_metric_alarm" "mysql_cpu_high" {
  alarm_name          = "triaige-mysql-cpu-high"
  alarm_description   = "Alerta quando a CPU da EC2 do banco excede 85% por 10 minutos"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 85
  alarm_actions       = [aws_sns_topic.triage_alarms.arn]

  dimensions = {
    InstanceId = module.ec2.mysql_instance_id
  }
}
