locals {
  name = "${var.provider_name}-${var.region}-rtype-${var.business_unit}-${var.tier}-${var.project}-${var.env}"
  
  common_tags = {
    Environment = var.env
    Project_name = var.project
    Business_unit = var.business_unit
    Team = var.team
    Owner = var.owner
    Managed_by = var.managed_by
  }
}
