# resource "aws_sqs_queue" "count_queue" {
#   count = length(var.names)
#   name  = element(var.names, count.index)
# }