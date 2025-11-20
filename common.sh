color=\\e[35m
no_color=\\e[0m

nodejs_setup() {
  echo -e ${color}Disable default NodeJS${no_color}
  dnf module disable nodejs -y &>>/tmp/roboshop.log
  echo Status - $?

  echo -e ${color}Enable NodeJS 20${no_color}
  dnf module enable nodejs:20 -y &>>/tmp/roboshop.log
  echo Status - $?

  echo -e ${color}Install NodeJS${no_color}
  dnf install nodejs -y &>>/tmp/roboshop.log
  echo Status - $?

  echo -e ${color}Add RoboShop User${no_color}
  useradd roboshop &>>/tmp/roboshop.log
  echo Status - $?

  echo -e ${color}Copy systemd service file${no_color}
  cp ${component}.service /etc/systemd/system/${component}.service &>>/tmp/roboshop.log
  echo Status - $?

  echo -e ${color}Delete existing app content${no_color}
  rm -rf /app &>>/tmp/roboshop.log
  echo Status - $?

  echo -e ${color}Create app directory${no_color}
  mkdir /app &>>/tmp/roboshop.log
  echo Status - $?

  echo -e ${color}Download app code${no_color}
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip &>>/tmp/roboshop.log
  echo Status - $?
  cd /app

  echo -e ${color}Extract app code${no_color}
  unzip /tmp/${component}.zip &>>/tmp/roboshop.log
  echo Status - $?

  cd /app
  echo -e ${color}Install NodeJS dependencies${no_color}
  npm install &>>/tmp/roboshop.log
  echo Status - $?

  echo -e ${color}Restart ${component} service${no_color}
  systemctl daemon-reload &>>/tmp/roboshop.log
  systemctl enable ${component} &>>/tmp/roboshop.log
  systemctl restart ${component} &>>/tmp/roboshop.log
  echo Status - $?
}


