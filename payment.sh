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
MYSQL_HOST=mysql.learn-devops.cloud



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

dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATE $? "installing python3, gcc, and python3-devel packages"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "adding roboshop user"

else
    echo -e "$Y roboshop user already exists, skipping user creation $N" | tee -a $LOGS_FILE
fi  
if [ $? -ne 0 ]; then
    mkdir /app &>>$LOGS_FILE
    VALIDATE $? "creating application directory"

    curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOGS_FILE
    VALIDATE $? "downloading payment code"
 else
    echo -e "$Y roboshop application directory already exists, skipping application directory creation $N" | tee -a $LOGS_FILE
fi

cd /app &>>$LOGS_FILE
VALIDATE $? "navigating to application directory"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "cleaning application directory"

unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? "extracting payment code" 

cd/app &>>$LOGS_FILE
VALIDATE $? "navigating to application directory"

pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "installing payment dependencies"

cp "$SCRIPT_DIR/payment.service" /etc/systemd/system/payment.service &>>$LOGS_FILE
VALIDATE $? "copying payment systemd service file"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "reloading systemd daemon"

systemctl enable payment &>>$LOGS_FILE
VALIDATE $? "enabling payment service"

systemctl start payment &>>$LOGS_FILE
VALIDATE $? "starting payment service"

