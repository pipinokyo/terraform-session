locals {
  full_name = "${var.provider_name}-${var.region}-rtype-${var.business_unit}-${var.tier}-${var.project}-${var.env}"     # Creates a long, descriptive name
  short_name = substr("${var.project}-${var.env}-${var.business_unit}", 0, 24)                                          # Shorter name for resources             
  
  common_tags = {
    Environment    = var.env                        # Environment tag (dev/staging/prod)
    Project_name   = var.project                    # Project identifier (homework7)  
    Business_unit  = var.business_unit              # Team/department (orders)  
    Team           = var.team                       # Team name (DevOps)   
    Owner          = var.owner                      # Tags by owner. Email (cuneyt.omer@gmail.com)
    Managed_by     = var.managed_by                 # Infrastructure tool (terraform) 
    Market         = "us"                           # Hardcoded region tag
    Name           = local.full_name                # Tags by full name
  }
}