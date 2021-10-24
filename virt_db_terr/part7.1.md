# Домашнее задание к занятию "7.1. Инфраструктура как код"

## Задача 1. Выбор инструментов. 
 
### Легенда
 
Через час совещание на котором менеджер расскажет о новом проекте. Начать работу над которым надо 
будет уже сегодня. 
На данный момент известно, что это будет сервис, который ваша компания будет предоставлять внешним заказчикам.
Первое время, скорее всего, будет один внешний клиент, со временем внешних клиентов станет больше.

Так же по разговорам в компании есть вероятность, что техническое задание еще не четкое, что приведет к большому
количеству небольших релизов, тестирований интеграций, откатов, доработок, то есть скучно не будет.  
   
Вам, как девопс инженеру, будет необходимо принять решение об инструментах для организации инфраструктуры.
На данный момент в вашей компании уже используются следующие инструменты: 
- остатки Сloud Formation, 
- некоторые образы сделаны при помощи Packer,
- год назад начали активно использовать Terraform, 
- разработчики привыкли использовать Docker, 
- уже есть большая база Kubernetes конфигураций, 
- для автоматизации процессов используется Teamcity, 
- также есть совсем немного Ansible скриптов, 
- и ряд bash скриптов для упрощения рутинных задач.  

Для этого в рамках совещания надо будет выяснить подробности о проекте, что бы в итоге определиться с инструментами:

1. Какой тип инфраструктуры будем использовать для этого проекта: изменяемый или не изменяемый? Уточняем на совещании, на сколько точное ТЗ, если достаточно то принимаем не изменяемый подход.
1. Будет ли центральный сервер для управления инфраструктурой? Можно обойтись без центрального сервера.
1. Будут ли агенты на серверах? Нет
1. Будут ли использованы средства для управления конфигурацией или инициализации ресурсов? Да
 
В связи с тем, что проект стартует уже сегодня, в рамках совещания надо будет определиться со всеми этими вопросами.

### В результате задачи необходимо

1. Ответить на четыре вопроса представленных в разделе "Легенда". 
Примем, что инфраструктура будет неизменяемой.
1. Какие инструменты из уже используемых вы хотели бы использовать для нового проекта? 
Для DEV, TST, PROD окружения использовать неизменяемую инфраструктуру на основе Terraform для выделения ресурсов, Packer для подготовки образов, Kubernetes для оркестрации Docker-контейнеров
На совещании уточнить необходимость Sandbox окружения, для обкатки совсем сырых гипотез, там можно оставить docker и скрипты.
1. Хотите ли рассмотреть возможность внедрения новых инструментов для этого проекта? 
Можно рассмотреть например GItlab для контроля версий и CI.

Если для ответа на эти вопросы недостаточно информации, то напишите какие моменты уточните на совещании.


## Задача 2. Установка терраформ. 

Официальный сайт: https://www.terraform.io/

Установите терраформ при помощи менеджера пакетов используемого в вашей операционной системе.
В виде результата этой задачи приложите вывод команды `terraform --version`.
```text
root@d289344ad02e:/# apt install terraform
Reading package lists... Done
Building dependency tree
Reading state information... Done
Fetched 32.7 MB in 3s (9690 kB/s)
debconf: delaying package configuration, since apt-utils is not installed
Selecting previously unselected package terraform.
(Reading database ... 10890 files and directories currently installed.)
Preparing to unpack .../terraform_1.0.9_amd64.deb ...
Unpacking terraform (1.0.9) ...
Setting up terraform (1.0.9) ...
root@d289344ad02e:/# terraform --version
Terraform v1.0.9
on linux_amd64
```
## Задача 3. Поддержка легаси кода. 

В какой-то момент вы обновили терраформ до новой версии, например с 0.12 до 0.13. 
А код одного из проектов настолько устарел, что не может работать с версией 0.13. 
В связи с этим необходимо сделать так, чтобы вы могли одновременно использовать последнюю версию терраформа установленную при помощи
штатного менеджера пакетов и устаревшую версию 0.12. 

В виде результата этой задачи приложите вывод `--version` двух версий терраформа доступных на вашем компьютере 
или виртуальной машине.
```text
root@d289344ad02e:/usr/local/sbin# mv terraform terraform12
root@d289344ad02e:/usr/local/sbin# terraform --version
Terraform v1.0.9
on linux_amd64
root@d289344ad02e:/usr/local/sbin# terraform12 --version
Terraform v0.12.30

Your version of Terraform is out of date! The latest version
```
---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---