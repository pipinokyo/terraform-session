resource "aws_sqs_queue" "main" {
  name = replace(local.name, "rtype", "sqs")
  tags = merge(local.common_tags, { Name = replace(local.name, "rtype", "sqs") })
}
