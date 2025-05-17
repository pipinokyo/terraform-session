locals {
  full_name = "${var.provider_name}-${var.region}-rtype-${var.business_unit}-${var.tier}-${var.project}-${var.env}"
  short_name = substr("${var.project}-${var.env}-${var.business_unit}", 0, 24)
  
  common_tags = {
    Environment    = var.env
    Project_name   = var.project
    Business_unit  = var.business_unit
    Team           = var.team
    Owner          = var.owner
    Managed_by     = var.managed_by
    Market         = "us"
    Name           = local.full_name
  }
}