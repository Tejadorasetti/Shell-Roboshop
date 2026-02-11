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

dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "disabling redis module"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "enabling redis 7 module"

dnf install redis -y &>>$LOGS_FILE
VALIDATE $? "installing redis"

USERID=$(id -u)

if [ "$USERID" -ne 0 ]; then
  echo "Please run this script as root (sudo)."
  exit 1
fi

CONF="/etc/redis/redis.conf"

# Take backup
cp "$CONF" "${CONF}.bak.$(date +%F-%H%M%S)"

# Change bind address 127.0.0.1 -> 0.0.0.0
sed -i 's/^bind 127\.0\.0\.1/bind 0.0.0.0/' "$CONF"

# Change protected-mode yes -> no
sed -i 's/^protected-mode yes/protected-mode no/' "$CONF"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "reloading systemd daemon"

systemctl restart redis &>>$LOGS_FILE
VALIDATE $? "restarting redis service"

systemctl enable redis &>>$LOGS_FILE
VALIDATE $? "enabling redis service"

systemctl start redis &>>$LOGS_FILE
VALIDATE $? "starting redis service"

