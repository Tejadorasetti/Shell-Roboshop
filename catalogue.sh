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

mkdir /app &>>$LOGS_FILE
VALIDATE $? "creating application directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
VALIDATE $? "downloading catalogue code"



