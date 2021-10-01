# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
```text
devops> docker run -d --name mysql-db1 -e MYSQL_ROOT_PASSWORD=my-pass -v db-vol:/db mysql:8
10c3baa93971ea43bea78ef916c821f450e5bec8cac18cdb7d17063e5d9de0f9
devops> docker exec -ti mysql-db1 bash
```

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.  
root@10c3baa93971:/home# mysql -uroot --database=testdb -p < test_dump.sql  
Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
```text
mysql> \s
--------------
mysql  Ver 8.0.26 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          25
Current database:       testdb
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.26 MySQL Community Server - GPL
```
Подключитесь к восстановленной БД и получите список таблиц из этой БД.
```text
mysql> show tables;
+------------------+
| Tables_in_testdb |
+------------------+
| orders           |
+------------------+
1 row in set (0.00 sec)
```
**Приведите в ответе** количество записей с `price` > 300.
```text
mysql> select * from orders where price>300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)
```
В следующих заданиях мы будем продолжать работу с данным контейнером.

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"
```text
mysql> CREATE USER 'test'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test-pass';
Query OK, 0 rows affected (0.97 sec)

mysql> ALTER USER 'test'@'localhost' PASSWORD EXPIRE INTERVAL 180 DAY FAILED_LOGIN_ATTEMPTS 3 ATTRIBUTE '{"name": "James", "last_name": "Pretty"}';
Query OK, 0 rows affected (0.50 sec)
```

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
```text
mysql> GRANT SELECT ON test_db.* TO 'test'@'localhost';
Query OK, 0 rows affected, 1 warning (0.41 sec)
```
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.
```text
mysql> select * from information_schema.user_attributes where user="test";
+------+-----------+------------------------------------------+
| USER | HOST      | ATTRIBUTE                                |
+------+-----------+------------------------------------------+
| test | localhost | {"name": "James", "last_name": "Pretty"} |
+------+-----------+------------------------------------------+
1 row in set (0.00 sec)
```
## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
```
mysql> select table_name, engine from information_schema.tables where table_schema="testdb";
+------------+--------+
| TABLE_NAME | ENGINE |
+------------+--------+
| orders     | InnoDB |
+------------+--------+
1 row in set (0.00 sec)
```
Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`
```text
mysql> alter table orders engine = innodb;
Query OK, 0 rows affected (0.53 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> select * from orders where title != "test" and price between 101 and 302;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
3 rows in set (0.00 sec)

mysql> alter table orders engine = myisam;
Query OK, 5 rows affected (0.22 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> select * from orders where title != "test" and price between 101 and 302;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
3 rows in set (0.00 sec)

mysql> show profiles;
+----------+------------+--------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                |
+----------+------------+--------------------------------------------------------------------------------------+                                                  |
|       15 | 0.52864350 | alter table orders engine = innodb                                                   |
|       16 | 0.00055575 | select * from orders where title != "test" and price between 101 and 302             |
|       17 | 0.22107125 | alter table orders engine = myisam                                                   |
|       18 | 0.00073225 | select * from orders where title != "test" and price between 101 and 302             |
+----------+------------+--------------------------------------------------------------------------------------+
15 rows in set, 1 warning (0.00 sec)
```

## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.
```text
root@10c3baa93971:/etc/mysql# nano my.cnf
root@10c3baa93971:/etc/mysql# cat my.cnf
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

#
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL
default_storage_engine = InnoDB
innodb_flush_method = O_DSYNC
innodb_file_per_table = 1
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 614M
innodb_log_file_size = 100M

# Custom config should go here
!includedir /etc/mysql/conf.d/
root@10c3baa93971:/etc/mysql#
```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
