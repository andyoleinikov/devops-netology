# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.  
\devops> docker run -d --name new-db -v db-vol:/db -e POSTGRES_PASSWORD=password -p 5432:5432 postgres:13  
Подключитесь к БД PostgreSQL используя `psql`.  
root@8719a38420bf:/# psql -U postgres  
Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД \l
- подключения к БД \c
- вывода списка таблиц \dt
- вывода описания содержимого таблиц \d NAME
- выхода из psql \q

## Задача 2

Используя `psql` создайте БД `test_database`.  
CREATE database test_database;

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.  

root@8719a38420bf:/home# psql -U postgres test_database < test_dump.sql  

Перейдите в управляющую консоль `psql` внутри контейнера.  
root@8719a38420bf:/home# psql -U postgres  
 
Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
```text
postgres=# \c test_database;
test_database=# ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
```
Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.
```text
test_database=# select attname, avg_width from pg_stats where tablename='orders' order by avg_width;
 attname | avg_width
---------+-----------
 id      |         4
 price   |         4
 title   |        16
(3 rows)
```
## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.
```text
BEGIN TRANSACTION;

CREATE TABLE orders_1 (
	CHECK ( price > 499 )
) INHERITS (orders);

CREATE TABLE orders_2 (
	CHECK ( price <= 499 )
) INHERITS (orders);

INSERT INTO orders_1 (id, title, price)
SELECT id, title, price
from orders
where price > 499;

INSERT INTO orders_2 (id, title, price)
SELECT id, title, price
from orders
where price <= 499;

COMMIT;
```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?  
```text
CREATE TABLE orders (..) PARTITION BY RANGE (price);
CREATE TABLE orders_1 PARTITION OF orders FOR VALUES FROM (499) TO (MAXVALUE);
```
## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.  
pg_dump -U postgres -d test_database > /backup/backup.sql

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?  
В строке "title character varying(80) NOT NULL," добавил бы UNIQUE.
---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
