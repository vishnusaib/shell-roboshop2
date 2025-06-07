#!/bin/bash

source ./common.sh
app_name=rabbitmq
check_root

echo "Please enter rabbitmq password to setup"
read -s RABBIT_PASSWD

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "rabbitmq code downloading"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing Rabbit server"

systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting rabbitmq"

rabbitmqctl add_user roboshop $RABBIT_PASSWD &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE

print_time