# #!/bin/bash


# rm -rf .terraform*
# read -p "Which environment do you want to choose: " ENV
# $echo ENV
# sed -i "s/_env_/$ENV/g" backend.tf

# echo "Environment is $ENV"

# terraform init 
# terraform apply -var-file="$ENV.tfvars"

# echo "Rolling back to  static string
# sed -i "s/$ENV/ENV/g" backend.tf

# echo "Environment is $ENV"