#!/bin/bash

sudo dnf update -y
sudo dnf install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

cat <<EOF > /var/www/html/index.html
<html>
  <body>
    <h1> ${environment}instance is running!</h1>
    <p>Public IP of ${environment} instance: PUBLIC_IP</p>
  </body>
</html>
EOF



