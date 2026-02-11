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


dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "disabling nodejs module"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "enabling nodejs 20 module"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "installing nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "adding roboshop user"

else
    echo -e "$Y roboshop user already exists, skipping user creation $N" | tee -a $LOGS_FILE
fi  

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    mkdir /app &>>$LOGS_FILE
    VALIDATE $? "creating application directory"

    curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOGS_FILE
    VALIDATE $? "downloading user code"
else
    echo -e "$Y roboshop application directory already exists, skipping application directory creation $N" | tee -a $LOGS_FILE
fi  

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOGS_FILE
VALIDATE $? "downloading user code"
if [ ! -s /tmp/user.zip ]; then
    echo -e "$R Empty zip file, download failed $N" | tee -a $LOGS_FILE
    exit 1
fi

cd /app &>>$LOGS_FILE
VALIDATE $? "navigating to application directory"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "cleaning application directory"


unzip /tmp/user.zip &>>$LOGS_FILE
VALIDATE $? "extracting user code" 

npm install &>>$LOGS_FILE
VALIDATE $? "installing user dependencies"

cp "$SCRIPT_DIR/user.service" /etc/systemd/system/user.service &>>$LOGS_FILE
VALIDATE $? "copying user systemd service file"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "reloading systemd daemon"

systemctl enable user &>>$LOGS_FILE
VALIDATE $? "enabling user service"

systemctl start user &>>$LOGS_FILE
VALIDATE $? "starting user service"

