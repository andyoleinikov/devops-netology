# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.  
docker volume create db-vol
docker volume create backup-vol
docker run -d --name my-db -v db-vol:/db -v backup-vol:/backup -e POSTGRES_PASSWORD=password -e PGDATA=/db/pgdata -p 5432:5432 postgres:12

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db  
CREATE DATABASE test_db  
CREATE USER "test-admin-user"  
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)  
CREATE TABLE orders  (id SERIAL PRIMARY KEY,  name VARCHAR(20), price INT);  
CREATE TABLE clients  (id SERIAL PRIMARY KEY,  surname VARCHAR(20), country VARCHAR(20), orders_id INT REFERENCES orders(id));
CREATE INDEX country ON clients (country)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db  
GRANT ALL ON orders, clients TO test-admin-user;
- создайте пользователя test-simple-user  
CREATE USER 'test-simple-user'
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db  
GRANT SELECT, INSERT, UPDATE, DELETE ON orders, clients TO "test-simple-user";

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,  
select datname from pg_database  
postgres  
test_db  
template1  
template0  
- описание таблиц (describe)
```text
root@25d39fec72e9:/# psql -U postgres -W
Password:
psql (12.8 (Debian 12.8-1.pgdg100+1))
Type "help" for help.

postgres=# \d orders
                                   Table "public.orders"
 Column |         Type          | Collation | Nullable |              Default
--------+-----------------------+-----------+----------+------------------------------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass)
 name   | character varying(20) |           |          |
 price  | integer               |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_orders_id_fkey" FOREIGN KEY (orders_id) REFERENCES orders(id)

postgres=#
postgres=# \d clients
                                     Table "public.clients"
  Column   |         Type          | Collation | Nullable |               Default
-----------+-----------------------+-----------+----------+-------------------------------------
 id        | integer               |           | not null | nextval('clients_id_seq'::regclass)
 surname   | character varying(20) |           |          |
 country   | character varying(20) |           |          |
 orders_id | integer               |           |          |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "country" btree (country)
Foreign-key constraints:
    "clients_orders_id_fkey" FOREIGN KEY (orders_id) REFERENCES orders(id)
```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
```text
SELECT grantee, table_name, privilege_type
FROM information_schema.table_privileges
WHERE table_name IN (SELECT table_name FROM information_schema. tables WHERE table_type='BASE TABLE' AND table_schema='public')
```
- список пользователей с правами над таблицами test_db  
```text
postgres	orders	INSERT
postgres	orders	SELECT
postgres	orders	UPDATE
postgres	orders	DELETE
postgres	orders	TRUNCATE
postgres	orders	REFERENCES
postgres	orders	TRIGGER
postgres	clients	INSERT
postgres	clients	SELECT
postgres	clients	UPDATE
postgres	clients	DELETE
postgres	clients	TRUNCATE
postgres	clients	REFERENCES
postgres	clients	TRIGGER
test-admin-user	orders	INSERT
test-admin-user	orders	SELECT
test-admin-user	orders	UPDATE
test-admin-user	orders	DELETE
test-admin-user	orders	TRUNCATE
test-admin-user	orders	REFERENCES
test-admin-user	orders	TRIGGER
test-admin-user	clients	INSERT
test-admin-user	clients	SELECT
test-admin-user	clients	UPDATE
test-admin-user	clients	DELETE
test-admin-user	clients	TRUNCATE
test-admin-user	clients	REFERENCES
test-admin-user	clients	TRIGGER
test-simple-user	orders	INSERT
test-simple-user	orders	SELECT
test-simple-user	orders	UPDATE
test-simple-user	orders	DELETE
test-simple-user	clients	INSERT
test-simple-user	clients	SELECT
test-simple-user	clients	UPDATE
test-simple-user	clients	DELETE
```
## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
INSERT INTO orders VALUES (1, 'Шоколад', 10)
INSERT INTO clients (surname, country) VALUES ('Петров Петр Петрович', 'Canada')
- вычислите количество записей для каждой таблицы 

- приведите в ответе:
    - запросы 
SELECT COUNT(*) FROM orders
SELECT COUNT(*) FROM clients
    - результаты их выполнения.
5
5
## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.
```text
update clients set orders_id = sub.id from (select id from orders where orders.name = 'Книга') as sub where clients.surname = 'Иванов Иван Иванович';  
update clients set orders_id = sub.id from (select id from orders where orders.name = 'Монитор') as sub where clients.surname = 'Петров Петр Петрович';  
update clients set orders_id = sub.id from (select id from orders where orders.name = 'Гитара') as sub where clients.surname = 'Иоганн Себастьян Бах';  
```
Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
```text
select * from clients where orders_id is not null
1	Иванов Иван Иванович	USA	3
2	Петров Петр Петрович	Canada	4
3	Иоганн Себастьян Бах	Japan	5
```
Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).  
explain select * from clients where orders_id is not null  
Приведите получившийся результат и объясните что значат полученные значения.  
Seq Scan on clients  (cost=0.00..1.05 rows=5 width=124)
  Filter: (orders_id IS NOT NULL)  
Выполняется последовательный обход таблицы, фильтруются строки, orders_id не равен нулю, т.е. клиент что-то заказал.


## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).  


Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.  
docker run -d --name my-db2 -v backup-vol:/backup -e POSTGRES_PASSWORD=password postgres:12

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 
```text
root@25d39fec72e9:/# pg_dump -U postgres test_db > /backup/db.dump

docker run -d --name my-db2 -v backup-vol:/backup -e POSTGRES_PASSWORD=password postgres:12
psql -U postgres postgres < /backup/db.dump
postgres=# select * from clients;
 id |       surname        | country | orders_id
----+----------------------+---------+-----------
  4 | Ронни Джеймс Дио     | Russia  |
  5 | Ritchie Blackmore    | Russia  |
  1 | Иванов Иван Иванович | USA     |         3
  2 | Петров Петр Петрович | Canada  |         4
  3 | Иоганн Себастьян Бах | Japan   |         5
(5 rows)
```
---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
