# Setup database

## Windows

- Download and run msi installer from [https://dev.mysql.com/downloads/installer/](https://dev.mysql.com/downloads/installer/)

## Linux

- Make sure mysql package is installed

```bash
sudo apt update
sudo apt upgrade -y

sudo apt install mysql-server -y

# Run if using wsl or docker
# sudo service mysql start
sudo systemctl start mysql
sudo mysql_secure_installation
```

- Log into mysql, create db, setup root and user passwords

```bash
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '<NEW_ROOT_PASSWORD>';
FLUSH PRIVILEGES;

CREATE DATABASE geography_board_game_db;

CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'mypassword';
GRANT ALL PRIVILEGES ON geography_board_game_db.* TO 'myuser'@'localhost';
FLUSH PRIVILEGES;
```

- Create db tables

```bash
node database/db_setup.js
```
