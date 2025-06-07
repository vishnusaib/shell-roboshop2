#!/bin/bash


START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# check the user has root priveleges or not
check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1 #give other than 0 upto 127
    else
        echo "You are running with root access" | tee -a $LOG_FILE
    fi
}

app_setup(){   
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "System User Roboshop created"
    else
        echo -e "System user Roboshop is already created... $Y Skipping $N"
    fi

    mkdir -p /app
    VALIDATE $? "Creating an app dir"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name"

    cd /app
    rm -rf /app/*
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Unzip $app_name code"
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disable NodeJS"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enable NodeJS Version 20"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Install NodeJS"

    npm install &>>$LOG_FILE
    VALIDATE $? "Install npm"
}
maven_setup(){   
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing maven"

    mvn clean package &>>$LOG_FILE
    VALIDATE $? "Packaging mvn application"

    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "moving remaining jar file"
}
python3_setup(){
    dnf install python3 gcc python3-devel -y
    VALIDATE $? "Installing python3"

    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing Python"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "copy $app_name code"

    systemctl daemon-reload &>>$LOG_FILE
    systemctl enable $app_name &>>$LOG_FILE
    systemctl start $app_name
    VALIDATE $? "Start $app_name"
}
# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "Script executed successfully, $Y Time taken: $TOTAL_TIME seconds $N"
}