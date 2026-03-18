#!/bin/bash
# ============================================================
#  setup_proxy.sh
#  Automates the full Nginx reverse proxy setup:
#   - Nginx installation
#   - Reverse proxy config creation
#   - Site enabling and service restart
#
#  Before running:
#    Edit BACKEND_PRIVATE_IP below with your actual value
#
#  Usage:
#    scp -i "Project-1.pem" setup_proxy.sh ubuntu@<PROXY_IP>:~/
#    ssh -i "Project-1.pem" ubuntu@<PROXY_IP>
#    sudo bash setup_proxy.sh
# ============================================================

set -e

# ⚠️ CHANGE THIS to your Backend EC2 Private IP
BACKEND_PRIVATE_IP="172.31.31.161"

echo "=============================================="
echo " STEP 1: Update System & Install Nginx"
echo "=============================================="
sudo apt-get update -y
sudo apt-get install -y nginx
nginx -v

echo "=============================================="
echo " STEP 2: Configure Reverse Proxy"
echo "=============================================="
sudo rm -f /etc/nginx/sites-enabled/default

sudo tee /etc/nginx/sites-available/student-app > /dev/null << EOF
server {
    listen 80;
    server_name _;

    location /student {
        proxy_pass         http://${BACKEND_PRIVATE_IP}:8080/student;
        proxy_set_header   Host              \$host;
        proxy_set_header   X-Real-IP         \$remote_addr;
        proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 60s;
        proxy_read_timeout    60s;
    }

    location / {
        return 301 /student;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/student-app /etc/nginx/sites-enabled/

echo "=============================================="
echo " STEP 3: Test & Start Nginx"
echo "=============================================="
sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx
sudo systemctl status nginx --no-pager

echo ""
echo "=============================================="
echo " ✅ Proxy Setup Complete!"
echo "=============================================="
echo " App is live at: http://$(curl -s ifconfig.me)/student"
echo "=============================================="
