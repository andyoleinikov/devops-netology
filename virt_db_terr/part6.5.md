# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
```text
FROM centos:7

RUN yum update -y && \
    yum install -y wget && \
    yum install -y perl-Digest-SHA 

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.0-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.0-linux-x86_64.tar.gz.sha512 && \
    shasum -a 512 -c elasticsearch-7.15.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-7.15.0-linux-x86_64.tar.gz

RUN groupadd elasticsearch && \
    useradd -g elasticsearch elasticsearch
    
RUN mkdir /var/lib/logs && \
    chown elasticsearch:elasticsearch /var/lib/logs && \
    mkdir /var/lib/data && \
    chown elasticsearch:elasticsearch /var/lib/data && \
    chown -R elasticsearch:elasticsearch /elasticsearch-7.15.0/

RUN mkdir /elasticsearch-7.15.0//snapshots &&\
    chown elasticsearch:elasticsearch /elasticsearch-7.15.0/snapshots
 
COPY elasticsearch.yml elasticsearch-7.15.0/config

USER elasticsearch
CMD ["/usr/sbin/init"]
CMD ["/elasticsearch-7.15.0/bin/elasticsearch"]
```
- ссылку на образ в репозитории dockerhub
  https://hub.docker.com/repository/docker/andyoleinikov/elastic
- ответ `elasticsearch` на запрос пути `/` в json виде
```text
[elasticsearch@e290a1d51b9f /]$ curl -X GET "0.0.0.0:9200/?pretty"
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "E0MG9-4jSZ2Hij9V9YTOTA",
  "version" : {
    "number" : "7.15.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "79d65f6e357953a5b3cbcc5e2c7c21073d89aa29",
    "build_date" : "2021-09-16T03:05:29.143308416Z",
    "build_snapshot" : false,
    "lucene_version" : "8.9.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```
Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |
```text
[elasticsearch@e290a1d51b9f /]$ curl -X PUT localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-1"}[elasticsearch@e290a1d51b9f /]$ curl -X PUT localhost:92"number_of_shards": 2,  "number_of_replicas": 1 }}'settings": {
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-2"}[elasticsearch@e290a1d51b9f /]$ curl -X PUT localhost:92"number_of_shards": 4,  "number_of_replicas": 2 }}'settings": {
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-3"}
```
Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
```text
[elasticsearch@e290a1d51b9f /]$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases DX0ouMdaRpOHWN6fx6x0bA   1   0         41            0     40.2mb         40.2mb
green  open   ind-1            -Tv5_hzTTQKlkX9y9Q0JkA   1   0          0            0       208b           208b
yellow open   ind-3            AU4jBjWpTY2Sb6xzZxJjMQ   4   2          0            0       208b           208b
yellow open   ind-2            is4l1FsjQ2KSRsFruUnDZQ   2   1          0            0       416b           416b
[elasticsearch@e290a1d51b9f /]$ curl -X GET 'http://localhost:9200/_cluster/health/ind-1?pretty'
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
[elasticsearch@e290a1d51b9f /]$ curl -X GET 'http://localhost:9200/_cluster/health/ind-2?pretty'
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
[elasticsearch@e290a1d51b9f /]$ curl -X GET 'http://localhost:9200/_cluster/health/ind-3?pretty'
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 4,
  "active_shards" : 4,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 8,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```

Получите состояние кластера `elasticsearch`, используя API.
```text
[elasticsearch@e290a1d51b9f /]$ curl -XGET localhost:9200/_cluster/health/?pretty=true
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
Потому что у части индексов отсутствуют реплики.


Удалите все индексы.
```text
[elasticsearch@e290a1d51b9f /]$ curl -X DELETE 'http://localhost:9200/ind-1?pretty'
{
  "acknowledged" : true
}
[elasticsearch@e290a1d51b9f /]$ curl -X DELETE 'http://localhost:9200/ind-2?pretty'
{
  "acknowledged" : true
}
[elasticsearch@e290a1d51b9f /]$ curl -X DELETE 'http://localhost:9200/ind-3?pretty'
{
  "acknowledged" : true
}
```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.
```text
[elasticsearch@876742ceffc0 snapshots]$ curl -XPOST localhost:9200/_snapshot/netology_backup?pretty -H 'Content-Type: application/json' -d'{"type": "fs", "settings": { "location":"/elasticsearch-7.15.0/snapshots" }}'
{
  "acknowledged" : true
}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.
```text
[elasticsearch@876742ceffc0 snapshots]$ curl -X PUT localhost:9200/test -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test"}[

[elasticsearch@876742ceffc0 snapshots]$ curl -X GET "localhost:9200/_cat/indices"
green open .geoip_databases bK6jygPvSZaOiVHB4c51uA 1 0 41 0 40.1mb 40.1mb
green open test             V5HIJFRLTHy5_daVDdEeEQ 1 0  0 0   208b   208b
```
[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.
```text
[elasticsearch@876742ceffc0 snapshots]$ curl -X PUT "localhost:9200/_snapshot/netology_backup/snapshot_1?wait_for_completion=true&pretty"
{
  "snapshot" : {
    "snapshot" : "snapshot_1",
    "uuid" : "aJmjhBp_T-GXDXoitxplnQ",
    "repository" : "netology_backup",
    "version_id" : 7150099,
    "version" : "7.15.0",
    "indices" : [
      ".geoip_databases",
      "test"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2021-10-10T15:50:03.037Z",
    "start_time_in_millis" : 1633881003037,
    "end_time" : "2021-10-10T15:50:04.639Z",
    "end_time_in_millis" : 1633881004639,
    "duration_in_millis" : 1602,
    "failures" : [ ],
    "shards" : {
      "total" : 2,
      "failed" : 0,
      "successful" : 2
    },
    "feature_states" : [
      {
        "feature_name" : "geoip",
        "indices" : [
          ".geoip_databases"
        ]
      }
    ]
  }
}
```

**Приведите в ответе** список файлов в директории со `snapshot`ами.
```text
[elasticsearch@876742ceffc0 snapshots]$ ls -lha
total 56K
drwxr-xr-x 1 elasticsearch elasticsearch 4.0K Oct 10 15:50 .
drwxr-xr-x 1 elasticsearch elasticsearch 4.0K Oct 10 13:27 ..
-rw-r--r-- 1 elasticsearch elasticsearch  828 Oct 10 15:50 index-0
-rw-r--r-- 1 elasticsearch elasticsearch    8 Oct 10 15:50 index.latest
drwxr-xr-x 4 elasticsearch elasticsearch 4.0K Oct 10 15:50 indices
-rw-r--r-- 1 elasticsearch elasticsearch  27K Oct 10 15:50 meta-aJmjhBp_T-GXDXoitxplnQ.dat
-rw-r--r-- 1 elasticsearch elasticsearch  437 Oct 10 15:50 snap-aJmjhBp_T-GXDXoitxplnQ.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.
```text
[elasticsearch@876742ceffc0 snapshots]$ curl -X GET "localhost:9200/_cat/indices"
green open .geoip_databases bK6jygPvSZaOiVHB4c51uA 1 0 41 0 40.1mb 40.1mb
green open test2            0RVMwaMNTOi7F22HKTUwbA 1 0  0 0   208b   208b
```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.
```text
[elasticsearch@876742ceffc0 snapshots]$ curl -X POST localhost:9200/_snapshot/netology_backup/snapshot_1/_restore?pretty
 -H 'Content-Type: application/json' -d'{"include_global_state":true}'
{
  "accepted" : true
}

[elasticsearch@876742ceffc0 snapshots]$ curl -X GET "localhost:9200/_cat/indices"
green open .geoip_databases e1X2C-vXRke7awcDUgwr5g 1 0 41 0 40.1mb 40.1mb
green open test2            0RVMwaMNTOi7F22HKTUwbA 1 0  0 0   208b   208b
green open test             X-lKhOJlSy6ixCLubW2jjw 1 0  0 0   208b   208b
```
Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
