source common.sh
component=shipping
java_setup

dnf install mysql -y

for sqlfile in schema app-user master-data; do
  mysql -h mysql-dev.rdevopsb87.online -uroot -pRoboShop@1 < /app/db/${sqlfile}.sql
done


