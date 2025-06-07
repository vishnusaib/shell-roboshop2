#!/bin/bash

source ./common.sh
app_name=redis

# check the user has root priveleges or not
check_root


dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "old redis is disabled"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Redis 7 is enabled"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Redis is installed"

sed -i 's/127.0.0.0/0.0.0.0/g' -i 's/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Edited redis.conf to accept remote connections"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "redis is enable"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "redis is started"

print_time