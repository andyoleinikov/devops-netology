# Домашнее задание к занятию "3.4. Операционные системы, лекция 2"

1. На лекции мы познакомились с [node_exporter](https://github.com/prometheus/node_exporter/releases). В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой [unit-файл](https://www.freedesktop.org/software/systemd/man/systemd.service.html) для node_exporter:

    * поместите его в автозагрузку,
    * предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на `systemctl cat cron`),
    * удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.  

vagrant@vagrant:~$ systemctl cat node-exporter
 /etc/systemd/system/node-exporter.service  
[Unit]  
Description=service for node_exporter  
Documentation=none  

[Service]  
EnvironmentFile=-/etc/default/node_exporter  
ExecStart=/home/vagrant/node_exporter-1.1.2.linux-amd64/node_exporter $EXTRA_NODE_OPTS  
IgnoreSIGPIPE=false  
KillMode=process  
Restart=on-failure  

[Install]
WantedBy=multi-user.target  

vagrant@vagrant:~$ systemctl status node-exporter  
● node-exporter.service - service for node_exporter  
     Loaded: loaded (/etc/systemd/system/node-exporter.service; enabled; vendor preset: enabled)  
     Active: active (running) since Sat 2021-06-12 20:28:07 UTC; 16h ago  
   Main PID: 611 (node_exporter)  
      Tasks: 5 (limit: 1073)  
     Memory: 14.3M  
     CGroup: /system.slice/node-exporter.service  
             └─611 /home/vagrant/node_exporter-1.1.2.linux-amd64/node_exporter  

1. Ознакомьтесь с опциями node_exporter и выводом `/metrics` по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.  
node_cpu_seconds_total Seconds the CPUs spent in each mode  
   node_filesystem_avail_bytes Filesystem space available to non-root users in bytes  
   node_filesystem_device_error Whether an error occurred while getting statistics for the given device  
   node_filesystem_free_bytes Filesystem free space in bytes  
   node_disk_io_time_weighted_seconds_total The weighted # of seconds spent doing I/Os  
   node_memory_MemTotal_bytes Memory information field MemTotal_bytes  
node_memory_MemAvailable_bytes Memory information field MemAvailable_bytes  
   node_memory_MemFree_bytes Memory information field MemFree_bytes  
   node_network_receive_bytes_total Network device statistic receive_bytes  
   node_network_receive_errs_total Network device statistic receive_errs
   
1. Установите в свою виртуальную машину [Netdata](https://github.com/netdata/netdata). Воспользуйтесь [готовыми пакетами](https://packagecloud.io/netdata/netdata/install) для установки (`sudo apt install -y netdata`). После успешной установки:
    * в конфигурационном файле `/etc/netdata/netdata.conf` в секции [web] замените значение с localhost на `bind to = 0.0.0.0`,
    * добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте `vagrant reload`:

    ```bash
    config.vm.network "forwarded_port", guest: 19999, host: 19999
    ```

    После успешной перезагрузки в браузере *на своем ПК* (не в виртуальной машине) вы должны суметь зайти на `localhost:19999`. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.  
Выполнено успешно, веб интерфейс доступен с хоста.

1. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?  
   Можно  
   vagrant@vagrant:/etc/sysctl.d$ dmesg -T | grep virtual  
[Fri Jun 11 17:38:41 2021] CPU MTRRs all blank - virtualized system.  
[Fri Jun 11 17:38:41 2021] Booting paravirtualized kernel on KVM  
[Fri Jun 11 17:38:45 2021] systemd[1]: Detected virtualization oracle.
1. Как настроен sysctl `fs.nr_open` на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?  
   fs.nr_open = 1048576 данный параметр отвечает за то, сколько файловых дескрипторов может открыть процесс.  
vagrant@vagrant:/$ ulimit -n  
1024 - сколько фактически файлов может открыть процесс, запущенный из shell.
1. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в данном задании под root (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т.д.  
   root@vagrant:/etc/netdata# nsenter --target 2136 --pid --mount  
root@vagrant:/# ps aux  
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND  
root           1  0.0  0.0   8076   596 pts/2    S+   13:27   0:00 sleep 1h  
root           2  0.7  0.3   9836  3940 pts/0    S    13:29   0:00 -bash  
root          11  0.0  0.3  11492  3384 pts/0    R+   13:29   0:00 ps aux  
1. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (**это важно, поведение в других ОС не проверялось**). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?  
   Это форк-бомба, которая пораждает процессы, пока не будет достигнут их лимит. cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-5.scope, т.е. PID controler в cgroups заблокировал дальнейшее исполнение форк-бомбы. В версиях Linux с systemd за этот механизм работы отвечает systemd и его часть cgroups. Также существует инструмент ulimit, но для систем с systemd он не актуален. По умолчанию для пользователя доступно 33% от максимального системного количество задач(в моем случае от kernel.threads-max = 7158). Для текущего пользователя можно поменять это значение например командой systemctl [--runtime] set-property user-<uid>.slice TasksMax=<value>.

 
 ---

### Как оформить ДЗ?

Домашнее задание выполните в файле readme.md в github репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

Также вы можете выполнить задание в [Google Docs](https://docs.google.com/document/u/0/?tgif=d) и отправить в личном кабинете на проверку ссылку на ваш документ.
Название файла Google Docs должно содержать номер лекции и фамилию студента. Пример названия: "1.1. Введение в DevOps — Сусанна Алиева"
Перед тем как выслать ссылку, убедитесь, что ее содержимое не является приватным (открыто на комментирование всем, у кого есть ссылка). 
Если необходимо прикрепить дополнительные ссылки, просто добавьте их в свой Google Docs.

Любые вопросы по решению задач задавайте в чате Slack.

---
