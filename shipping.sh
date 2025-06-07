#!/bin/bash

source ./common.sh
app_name=shipping

# check the user has root priveleges or not
check_root

echo "Please enter root password"
read -s MySQL_Root_Password

app_setup
maven_setup
systemd_setup

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL"

mysql -h mysql.vishnuv8.fun -u root -p$MySQL_Root_Password -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.vishnuv8.fun -uroot -p$MySQL_Root_Password < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.vishnuv8.fun -uroot -p$MySQL_Root_Password < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h mysql.vishnuv8.fun -uroot -p$MySQL_Root_Password < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Loading Data in MySQL"
else
    echo "Data is already loaded in MySQL"
fi

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restarting Shipping"

print_time