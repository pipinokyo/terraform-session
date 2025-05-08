resource "aws_sqs_queue" "main" {
  name = replace(local.name, "rtype", "sqs")
  tags = local.common_tags
}
