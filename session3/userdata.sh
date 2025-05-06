#!/bin/bash

sudo dnf update -y
sudo dnf install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

cat <<EOF > /var/www/html/index.html
<html>
  <body>
    <h1>Session-2 homework is complete!</h1>
    <p>Public IP of this server: $PUBLIC_IP</p>
  </body>
</html>
EOF