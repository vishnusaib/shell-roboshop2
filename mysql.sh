#!/bin/bash
source ./common.sh
app_name=mysql
# check the user has root priveleges or not
check_root

echo "Please enter root password"
read -s MYSQL_ROOT_PASSWORD

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "mysql server in installing"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling Mysql"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Start MySQL"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
VALIDATE $? "Setting up MySQL root password"

print_time