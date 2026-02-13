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

dnf install maven -y &>>$LOGS_FILE
VALIDATE $? "installing maven"

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

    curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGS_FILE
    VALIDATE $? "downloading shipping code"
 else
    echo -e "$Y roboshop application directory already exists, skipping application directory creation $N" | tee -a $LOGS_FILE
fi

cd /app &>>$LOGS_FILE
VALIDATE $? "navigating to application directory"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "cleaning application directory"

unzip /tmp/shipping.zip &>>$LOGS_FILE
VALIDATE $? "extracting shipping code" 

cd /app &>>$LOGS_FILE
VALIDATE $? "navigating to application directory"

mvn clean package  &>>$LOGS_FILE
VALIDATE $? "building shipping code"

mv target/shipping-1.0.jar shipping.jar &>>$LOGS_FILE
VALIDATE $? "building shipping code"

cp "$SCRIPT_DIR/shipping.service" /etc/systemd/system/shipping.service &>>$LOGS_FILE
VALIDATE $? "copying shipping systemd service file"

dnf install mysql -y &>>$LOGS_FILE
VALIDATE $? "installing mysql client"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql

systemctl enable shipping &>>$LOGS_FILE
VALIDATE $? "enabling shipping service"

systemctl start shipping &>>$LOGS_FILE
VALIDATE $? "starting shipping service"

