locals {
  queue_names = [for i in range(1, 3) : "queue-${i}"]
}

