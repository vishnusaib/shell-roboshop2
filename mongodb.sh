#!/bin/bash

source ./common
app_name=mongodb
# check the user has root priveleges or not
check_root

# validate functions takes input as exit status, what command they tried to install

cp mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing Mongodb Server"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing Mongodb conf file for remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restart Mongod"