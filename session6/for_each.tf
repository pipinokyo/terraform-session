resource "aws_sqs_queue" "for_each_queue" {
    for_each = var.for_each_names
    name     = each.value
}