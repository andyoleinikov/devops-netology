# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"

## Обязательные задания

1. Мы выгрузили JSON, который получили через API запрос к нашему сервису:
	```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
	```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

2. В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. Формат записи YAML по одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.  


    ```python
    #!/usr/bin/env python3/usr/bin/env python3
    import socket
    import time
    import json
    import yaml

    def get_host_ips(name):
        try:
            host_ips = socket.gethostbyname_ex(name)[2]
        except Exception as e:
            return False
        return host_ips

    def show_ips(name, host_ips):
        print('{} - {}'.format(name, ', '.join(host_ips)))

    def save_ips(name, host_ips):
        data_single_service = {name: ', '.join(host_ips)}
        with open(f"{name}.json", "w") as jsonfile:
          jsonfile.write(json.dumps(data_single_service))
        with open(f"{name}.yml", "w") as yamlfile:
          yaml.dump([data_single_service], yamlfile, default_flow_style=False)

    def show_error(name, host_ips, prev_ips):
        print('[ERROR] {} IP mismatch: {} {}'.format(name, ', '.join(host_ips), ', '.join(prev_ips)))


    def check_ips(host_ips, prev_ips):
        if set(host_ips) == set(prev_ips):
            return True
        else:
            return False


    names = ['drive.google.com', 'mail.google.com', 'google.com']
    prev_ips = {}

    while True:

        for name in names:
            host_ips = get_host_ips(name)
            if not host_ips:
                print('{} service unavailable'.format(name))
                continue
            if name not in prev_ips.keys():
                prev_ips[name] = host_ips
            if check_ips(host_ips, prev_ips[name]):
                show_ips(name, host_ips)
                save_ips(name, host_ips)
            else:
                show_error(name, host_ips,prev_ips[name])
                save_ips(name, host_ips)
            prev_ips[name] = host_ips
        data_all = []
        for name in prev_ips.keys():
          data_all.append({name: ', '.join(prev_ips[name])})
        with open("all.json", "w") as jsonfile:
          jsonfile.write(json.dumps(data_all))
        with open("all.yml", "w") as yamlfile:
          yaml.dump(data_all, yamlfile, default_flow_style=False)
        time.sleep(5)
    ```
В задании неочевидно надо ли сохранять все адреса в один файл или каждый в свой, поэтому сохраняется оба варианта.  

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
   * Принимать на вход имя файла
   * Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
   * Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
   * Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
   * При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
   * Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

---

### Как сдавать задания

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---