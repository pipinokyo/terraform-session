#!/bin/bash
sudo dnf install -y curl || sudo yum install -y curl
# Update system and install Apache
sudo dnf update -y
sudo dnf install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Get instance metadata
INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo "No public IP")
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

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
      .info-box {
        margin: 20px auto;
        padding: 15px;
        border: 1px solid #ddd;
        width: 60%;
        background-color: white;
        box-shadow: 0 0 10px rgba(0,0,0,0.1);
      }
    </style>
  </head>
  <body>
    <h1>${env} Environment Instance</h1>
    
    <div class="info-box">
      <h2>Instance Information</h2>
      <p><strong>Private IP:</strong> $INSTANCE_IP</p>
      <p><strong>Public IP:</strong> $PUBLIC_IP</p>
      <p><strong>Availability Zone:</strong> $AZ</p>
      <p><strong>Hostname:</strong> $(hostname)</p>
    </div>
  </body>
</html>
EOF

# Set proper permissions
sudo chown apache:apache /var/www/html/index.html
sudo systemctl restart httpd