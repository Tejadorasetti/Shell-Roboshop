#! bin/bash/

USERID=$(id -u)
LOGS_FOLDER="/var/log/Shell-Roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$R please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1

fi    

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then

        echo -e " $2 ....$R failure $N"   | tee -a $LOGS_FILE
        exit 1

    else 
        echo -e "$2....$G Success $N"    | tee -a $LOGS_FILE
    fi

}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "copying mongo repo file"

dnf install mongodb-org -y &>>$LOGS_FILE 
VALIDATE $? "installing mongodb Server"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "enabling mongodb service"

systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "starting mongodb service"

sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOGS_FILE
VALIDATE $? "allowing remote connection to mongodb"

systemctl restart mongod &>>$LOGS_FILE
VALIDATE $? "restarting mongodb service"