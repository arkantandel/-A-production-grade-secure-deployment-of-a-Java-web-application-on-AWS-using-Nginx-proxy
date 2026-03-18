#!/bin/bash
# ============================================================
#  setup_backend.sh
#  Automates the full backend EC2 setup:
#   - Java 11 installation
#   - MySQL Server setup + schema creation
#   - Apache Tomcat 9 installation
#   - MySQL Connector deployment
#   - student.war deployment
#   - Tomcat systemd service creation
#
#  Usage:
#    scp -i "Project-1.pem" setup_backend.sh student.war mysql-connector.jar ubuntu@<IP>:~/
#    ssh -i "Project-1.pem" ubuntu@<IP>
#    sudo bash setup_backend.sh
# ============================================================

set -e

echo "=============================================="
echo " STEP 1: Update System"
echo "=============================================="
sudo apt-get update -y && sudo apt-get upgrade -y

echo "=============================================="
echo " STEP 2: Install Java 11"
echo "=============================================="
sudo apt-get install -y openjdk-11-jdk
java -version

echo "=============================================="
echo " STEP 3: Install MySQL Server"
echo "=============================================="
sudo apt-get install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql

echo "=============================================="
echo " STEP 4: Create Database and Table"
echo "=============================================="
sudo mysql -u root << 'EOF'
CREATE DATABASE IF NOT EXISTS studentapp;
CREATE USER IF NOT EXISTS 'studentuser'@'localhost' IDENTIFIED BY 'Student@1234';
GRANT ALL PRIVILEGES ON studentapp.* TO 'studentuser'@'localhost';
FLUSH PRIVILEGES;
USE studentapp;
CREATE TABLE IF NOT EXISTS students (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    address       VARCHAR(200),
    age           INT,
    qualification VARCHAR(100),
    percentage    DECIMAL(5,2),
    year          INT,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SELECT 'Database ready!' AS Status;
EOF

echo "=============================================="
echo " STEP 5: Install Apache Tomcat 9"
echo "=============================================="
cd /opt
sudo wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.82/bin/apache-tomcat-9.0.82.tar.gz
sudo tar -xzf apache-tomcat-9.0.82.tar.gz
sudo mv apache-tomcat-9.0.82 tomcat9
sudo chmod -R 755 /opt/tomcat9
sudo chmod +x /opt/tomcat9/bin/*.sh

echo "=============================================="
echo " STEP 6: Deploy App & MySQL Connector"
echo "=============================================="
sudo cp ~/mysql-connector.jar /opt/tomcat9/lib/
sudo cp ~/student.war /opt/tomcat9/webapps/student.war

echo "=============================================="
echo " STEP 7: Create Tomcat Systemd Service"
echo "=============================================="
sudo tee /etc/systemd/system/tomcat.service > /dev/null << 'EOF'
[Unit]
Description=Apache Tomcat 9
After=network.target mysql.service

[Service]
Type=forking
User=root
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="CATALINA_HOME=/opt/tomcat9"
Environment="CATALINA_BASE=/opt/tomcat9"
Environment="CATALINA_PID=/opt/tomcat9/temp/tomcat.pid"
ExecStart=/opt/tomcat9/bin/startup.sh
ExecStop=/opt/tomcat9/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

sleep 8
echo ""
echo "=============================================="
echo " ✅ Backend Setup Complete!"
echo "=============================================="
echo " Tomcat: http://localhost:8080/student"
echo " MySQL DB: studentapp | User: studentuser"
echo "=============================================="
