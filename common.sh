color=\\e[35m
no_color=\\e[0m

systemd_setup() {
    echo -e ${color}Restart ${component} service${no_color}
    systemctl daemon-reload &>>/tmp/roboshop.log
    systemctl enable ${component} &>>/tmp/roboshop.log
    systemctl restart ${component} &>>/tmp/roboshop.log
    echo Status - $?
}

app_prereq() {
  echo -e ${color}Copy systemd service file${no_color}
  cp ${component}.service /etc/systemd/system/${component}.service &>>/tmp/roboshop.log
  echo Status - $?

  echo -e ${color}Add RoboShop User${no_color}
  id roboshop &>>/tmp/roboshop.log
  if [ $? -eq 1 ]; then
  useradd roboshop &>>/tmp/roboshop.log
  fi
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
}

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

  app_prereq

  cd /app
  echo -e ${color}Install NodeJS dependencies${no_color}
  npm install &>>/tmp/roboshop.log
  echo Status - $?

  systemd_setup
}


python_setup() {
  echo -e ${color}Install Python${no_color}
  dnf install python3 gcc python3-devel -y  &>>/tmp/roboshop.log
  echo Status - $?

  app_prereq

  cd /app

  echo -e ${color}Install Python dependencies${no_color}
  pip3 install -r requirements.txt &>>/tmp/roboshop.log
  echo Status - $?

  systemd_setup
}

java_setup() {
  echo -e ${color}Install Maven${no_color}
  dnf install maven -y &>>/tmp/roboshop.log
  echo Status - $?

  app_prereq

  cd /app
  echo -e ${color}Download Java Dependencies and Compile code${no_color}
  mvn clean package &>>/tmp/roboshop.log
  mv target/${component}-1.0.jar ${component}.jar &>>/tmp/roboshop.log
  echo Status - $?

  systemd_setup
}

