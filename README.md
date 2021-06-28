# Домашнее задание к занятию "3.7. Компьютерные сети, лекция 2"

1. На лекции мы обсудили, что манипулировать размером окна необходимо для эффективного наполнения приемного буфера участников TCP сессии (Flow Control). Подобная проблема в полной мере возникает в сетях с высоким RTT. Например, если вы захотите передать 500 Гб бэкап из региона Юга-Восточной Азии на Восточное побережье США. [Здесь](https://www.cloudping.co/grid) вы можете увидеть и 200 и 400 мс вполне реального RTT. Подсчитайте, какого размера нужно окно TCP чтобы наполнить 1 Гбит/с канал при 300 мс RTT (берем простую ситуацию без потери пакетов). Можно воспользоваться готовым [калькулятором](https://www.switch.ch/network/tools/tcp_throughput/). Ознакомиться с [формулами](https://en.wikipedia.org/wiki/TCP_tuning), по которым работает калькулятор можно, например, на Wiki.  
Window size должен быть более 37,5 Мбайт
1. Во сколько раз упадет пропускная способность канала, если будет 1% потерь пакетов при передаче?  
Пропускная способность упадет примерно в 1000 раз.
1. Какая  максимальная реальная скорость передачи данных достижима при линке 100 Мбит/с? Вопрос про TCP payload, то есть цифры, которые вы реально увидите в операционной системе в тестах или в браузере при скачивании файлов. Повлияет ли размер фрейма на это?
Теоретически максимальная пропускная способность будет 100*1460/1518= 96 Мбит/с, т.е. она зависит от соотношения полезной нагрузки и размера фрейма. При маленьких значениях полезной нагрузки и соответственно маленьком размере фрейма, фактическая пропускная способность будет вообще порядка 10 Мбит/с.
1. Что на самом деле происходит, когда вы открываете сайт? :)
На прошлой лекции был приведен сокращенный вариант ответа на этот вопрос. Теперь вы знаете намного больше, в частности про IP адресацию, DNS и т.д.
Опишите максимально подробно насколько вы это можете сделать, что происходит, когда вы делаете запрос `curl -I http://netology.ru` с вашей рабочей станции. Предположим, что arp кеш очищен, в локальном DNS нет закешированных записей.
   1. Выполняется broadcast arp запрос, шлюз отвечает.
   1. Через шлюз (с его MAC адресом на уровне фрейма ethernet) отправляется запрос на DNS сервер.
   1. Получение ip адреса сайта у DNS сервера 
   1. TCP соединение с нужным ip, three-way handshake
   1. http запрос опускается на уровень TCP, потом IP, потом data link, доходит до http://netology.ru
   1. Ответ на запрос тем же путем приходит обратно, ОС показывает его в командной строке.
1. Сколько и каких итеративных запросов будет сделано при резолве домена `www.google.co.uk`?
Запрос к root, потом к TDP dns1.nic.uk, потом к ns1.google.com, всего 3 запроса.
1. Сколько доступно для назначения хостам адресов в подсети `/25`? А в подсети с маской `255.248.0.0`. Постарайтесь потренироваться в ручных вычислениях чтобы немного набить руку, не пользоваться калькулятором сразу.  
В подсети с маской /25 доступно 128 адресов.  2^19=524 288 в подсети с маской 255.248.0.0
1. В какой подсети больше адресов, в `/23` или `/24`?  
В /23 будет в два раза больше адресов, 512 вместо 256.
1. Получится ли разделить диапазон `10.0.0.0/8` на 128 подсетей по 131070 адресов в каждой? Какая маска будет у таких подсетей?  
Получится, маска будет /23, или 255.255.254.0


 
 ---

### Как оформить ДЗ?

Домашнее задание выполните в файле readme.md в github репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

Также вы можете выполнить задание в [Google Docs](https://docs.google.com/document/u/0/?tgif=d) и отправить в личном кабинете на проверку ссылку на ваш документ.
Название файла Google Docs должно содержать номер лекции и фамилию студента. Пример названия: "1.1. Введение в DevOps — Сусанна Алиева"
Перед тем как выслать ссылку, убедитесь, что ее содержимое не является приватным (открыто на комментирование всем, у кого есть ссылка). 
Если необходимо прикрепить дополнительные ссылки, просто добавьте их в свой Google Docs.

Любые вопросы по решению задач задавайте в чате Slack.

---
