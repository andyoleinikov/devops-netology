# Домашнее задание к занятию "3.8. Компьютерные сети, лекция 3"

1. ipvs. Если при запросе на VIP сделать подряд несколько запросов (например, `for i in {1..50}; do curl -I -s 172.28.128.200>/dev/null; done `), ответы будут получены почти мгновенно. Тем не менее, в выводе `ipvsadm -Ln` еще некоторое время будут висеть активные `InActConn`. Почему так происходит?  
Потому что соединения пропадут только после http timeout.

1. На лекции мы познакомились отдельно с ipvs и отдельно с keepalived. Воспользовавшись этими знаниями, совместите технологии вместе (VIP должен подниматься демоном keepalived). Приложите конфигурационные файлы, которые у вас получились, и продемонстрируйте работу получившейся конструкции. Используйте для директора отдельный хост, не совмещая его с риалом! Подобная схема возможна, но выходит за рамки рассмотренного на лекции.  
Vagrantfile:  
boxes = {  
  'netology1' => '10',  
  'netology2' => '60',  
  'netology3' => '90',  
  'netology4' => '44',  
  'netology5' => '55',  
}   
    ```bash  
        keepalived.conf: 
        vrrp_instance VI_1 {
            state MASTER
            interface eth1
            virtual_router_id 33
            priority 99 / 22
            advert_int 1
            authentication {
                auth_type PASS
                auth_pass netology_secret
            }
            virtual_ipaddress {
                172.28.128.210/24 dev eth1
            }
        }
        
        virtual_server 172.28.128.210 80 {
            delay_loop 6
            lb_algo rr
            lb_kind DR
            protocol TCP
        
            real_server 172.28.128.44 80 {
                TCP_CHECK {
                        connect_timeout 10
                }
            }
            real_server 172.28.128.55 80 {
                TCP_CHECK {
                        connect_timeout 10
                }
            }
        }
        vagrant@netology1:~$ for i in {1..50}; do curl -I -s 172.28.128.210>/dev/null; done
        vagrant@netology2:/etc/keepalived$ sudo ipvsadm -Ln
        IP Virtual Server version 1.2.1 (size=4096)
        Prot LocalAddress:Port Scheduler Flags
          -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
        TCP  172.28.128.210:80 rr
          -> 172.28.128.44:80             Route   1      0          25
          -> 172.28.128.55:80             Route   1      0          26
        vagrant@netology2:/etc/keepalived$ sudo systemctl stop keepalived
        vagrant@netology1:~$ for i in {1..50}; do curl -I -s 172.28.128.210>/dev/null; done
        vagrant@netology3:/etc/keepalived$ sudo ipvsadm -Ln
        IP Virtual Server version 1.2.1 (size=4096)
        Prot LocalAddress:Port Scheduler Flags
          -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
        TCP  172.28.128.210:80 rr
          -> 172.28.128.44:80             Route   1      0          25
          -> 172.28.128.55:80             Route   1      0          26
    ```
1. В лекции мы использовали только 1 VIP адрес для балансировки. У такого подхода несколько отрицательных моментов, один из которых – невозможность активного использования нескольких хостов (1 адрес может только переехать с master на standby). Подумайте, сколько адресов оптимально использовать, если мы хотим без какой-либо деградации выдерживать потерю 1 из 3 хостов при входящем трафике 1.5 Гбит/с и физических линках хостов в 1 Гбит/с? Предполагается, что мы хотим задействовать 3 балансировщика в активном режиме (то есть не 2 адреса на 3 хоста, один из которых в обычное время простаивает).  
Чтобы в активном режиме работало 3 хоста одновременно надо 3 адреса.

 ---

### Как оформить ДЗ?

Домашнее задание выполните в файле readme.md в github репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

Также вы можете выполнить задание в [Google Docs](https://docs.google.com/document/u/0/?tgif=d) и отправить в личном кабинете на проверку ссылку на ваш документ.
Название файла Google Docs должно содержать номер лекции и фамилию студента. Пример названия: "1.1. Введение в DevOps — Сусанна Алиева"
Перед тем как выслать ссылку, убедитесь, что ее содержимое не является приватным (открыто на комментирование всем, у кого есть ссылка). 
Если необходимо прикрепить дополнительные ссылки, просто добавьте их в свой Google Docs.

Любые вопросы по решению задач задавайте в чате Slack.

---

vrrp_script chk_nginx {
 script "systemctl status nginx"
 interval 2 }
vrrp_instance VI_1 {
 state MASTER
 interface eth1
 virtual_router_id 33
 priority 100 / 50
 advert_int 1
 authentication {
 auth_type PASS
 auth_pass netology_secret
 }
 virtual_ipaddress {
 172.28.128.210/24 dev eth1
 }
 track_script {
 chk_nginx
 }

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 33
    priority 99
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass netology_secret
    }
    virtual_ipaddress {
        172.28.128.210/24 dev eth1
    }
}

virtual_server 172.28.128.210 80 {
    delay_loop 6
    lb_algo rr
    lb_kind DR
    protocol TCP

    real_server 172.28.128.44 80 {
        TCP_CHECK {
                connect_timeout 10
        }
    }
    real_server 172.28.128.55 80 {
        TCP_CHECK {
                connect_timeout 10
        }
    }
}