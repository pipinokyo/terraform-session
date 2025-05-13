#!/bin/bash

# Update system and install Apache
sudo dnf update -y
sudo dnf install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Create HTML page with environment info
cat <<EOF > /var/www/html/index.html
<html>
  <head>
    <title>Welcome</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        text-align: center;
        margin-top: 100px;
        background-color: #f0f8ff;
      }
      h1 {
        color: #2e8b57;
      }
    </style>
  </head>
  <body>
    <h1>${env} Environment Instance is Running!</h1>
    <p>Hostname: $(hostname)</p>
    <p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
  </body>
</html>
EOF

# Set proper permissions
sudo chown apache:apache /var/www/html/index.html
sudo systemctl restart httpd