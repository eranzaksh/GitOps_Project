#! /bin/bash
apt update -y
apt install -y apache2
systemctl enable apache2
service apache start  
echo '<h1>Welcome to Apache - Leumi</h1>' > /var/www/html/index.html