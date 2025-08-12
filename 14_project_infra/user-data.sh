#!/bin/bash
# This script is executed when a new VM instance is created in the scale set
# It sets up a web server with PHP and displays instance metadata

# Update package list to get latest package information
apt-get update -y

# Install Apache web server, PHP, and related packages
# - apache2: Web server
# - php: PHP interpreter
# - php-curl: PHP extension for making HTTP requests
# - libapache2-mod-php: Apache module for PHP
# - php-mysql: PHP extension for MySQL database connectivity
# - jq: Command-line JSON processor for parsing JSON data
apt-get install -y apache2 php php-curl libapache2-mod-php php-mysql jq

# Configure firewall to allow Apache web traffic (HTTP and HTTPS)
ufw allow 'Apache Full'

# Add azureuser to the azureuser group (ensures proper permissions)
usermod -a -G azureuser azureuser

# Create the web root directory if it doesn't exist
mkdir -p /var/www/html

# Change ownership of the entire /var/www directory to azureuser
chown -R azureuser:azureuser /var/www

# Set directory permissions to 2775 (rwxrwxr-x) with setgid bit
# This ensures new files inherit the group ownership
chmod 2775 /var/www

# Recursively set all directories in /var/www to 2775 permissions
find /var/www -type d -exec chmod 2775 {} \;

# Recursively set all files in /var/www to 0664 permissions (rw-rw-r--)
find /var/www -type f -exec chmod 0664 {} \;

# Change to the web root directory
cd /var/www/html

# Fetch instance metadata from Azure's metadata service
# - -s: Silent mode (no progress bar)
# - -H Metadata:true: Required header for Azure metadata service
# - --noproxy "*": Don't use proxy for this request
# - 169.254.169.254: Azure's metadata service IP address
# - jq: Format the JSON response nicely
# - > index.html: Save the formatted metadata to index.html
curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq > index.html

# Add HTML <pre> tag at the beginning of index.html for proper formatting
sed -i '1i<pre>' index.html

# Add closing </pre> tag at the end of index.html
sed -i '$a</pre>' index.html

# Download a sample PHP application from GitHub
# - -O: Save with original filename (index.php)
# This provides a basic PHP application for demonstration
curl https://raw.githubusercontent.com/Azure/vm-scale-sets/master/terraform/terraform-tutorial/app/index.php -O