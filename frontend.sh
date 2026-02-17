#! bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/Shell-Roboshop"
SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=mongodb.learn-devops.cloud


if [ $USERID -ne 0 ]; then
    echo -e "$R please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1

fi    

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then

        echo -e "$2....$R failure $N"   | tee -a $LOGS_FILE
        exit 1

    else 
        echo -e "$2....$G Success $N"    | tee -a $LOGS_FILE
    fi

}

dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "disabling nginx module"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATE $? "enabling nginx 1.24 module"

dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOGS_FILE
VALIDATE $? "enabling nginx service"

systemctl start nginx  &>>$LOGS_FILE
VALIDATE $? "starting nginx service"

rm -rf /usr/share/nginx/html/* &>>$LOGS_FILE
VALIDATE $? "cleaning nginx default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
VALIDATE $? "downloading frontend code"

cd /usr/share/nginx/html &>>$LOGS_FILE
VALIDATE $? "navigating to nginx html directory"

unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "extracting frontend code"

rm -rf /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "removing default nginx configuration"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "copying nginx configuration file"

systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "restarting nginx service"


