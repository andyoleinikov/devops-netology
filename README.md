# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательные задания

1. Есть скрипт:
	```python
    #!/usr/bin/env python3
	a = 1
	b = '2'
	c = a + b
	```
	* Какое значение будет присвоено переменной c?  
	Никакое, будет ошибка.	  
	* Как получить для переменной c значение 12?  
	  c = str(a) + b
	* Как получить для переменной c значение 3?  
	c = a + int(b)

1. Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

	```python
    #!/usr/bin/env python3

    import os

	bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
	result_os = os.popen(' && '.join(bash_command)).read()
    is_change = False
	for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(prepare_result)
            break

	```

	```python
	#!/usr/bin/env python3/usr/bin/env python3
	import os
	target_dir = "/netology/sysadm-homeworks"
	bash_command = [f"cd ~{target_dir}", "git status"]
	result_os = os.popen(' && '.join(bash_command)).read()
	print("target directory: " + os.getcwd() + target_dir)
	for result in result_os.split('\n'):
	  if result.find('modified') != -1:
		prepare_result = result.replace('\tmodified:   ', '')
		print(prepare_result)
	```
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

	```python
	#!/usr/bin/env python3/usr/bin/env python3
	import os
	import sys
	import subprocess

	def show_changed_files(target_dir):
	  bash_command = [f'cd {target_dir}', 'git status']
	  result_sp = subprocess.Popen(' && '.join(bash_command), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	  if result_sp.stderr.read().decode('utf-8').find('not a git repository') != -1:
	    sys.exit('Specified path is not a git repository')
	  for result in result_sp.stdout.read().decode('utf-8').split('\n'):
	    if result.find('modified') != -1:
	      prepare_result = result.replace('\tmodified:   ', '')
	      print(prepare_result)

	if len(sys.argv) < 2:
	  target_dir = '.'
	  print("target directory: " + os.getcwd())
	else:
	  target_dir = sys.argv[1]
	  print("target directory: " + target_dir)
	if not os.path.isdir(target_dir):
	  sys.exit('Specified path is not a directory')

	show_changed_files(target_dir)
	```

1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: drive.google.com, mail.google.com, google.com.

	```python
	#!/usr/bin/env python3/usr/bin/env python3
import socket
import time

def get_host_ips(name):
    try:
        host_ips = socket.gethostbyname_ex(name)[2]
    except Exception as e:
        return False
    return host_ips

def show_ips(name, host_ips):
    print('{} - {}'.format(name, ', '.join(host_ips)))

def show_error(name, host_ips, prev_ips):
    print('[ERROR] {} IP mismatch: {} {}'.format(name, ', '.join(host_ips), ', '.join(prev_ips)))


def check_ips(host_ips, prev_ips):
    if set(host_ips) == set(prev_ips):
        return True
    else:
        return False


names = ['drive.google.com', 'mail.google.com', 'google.com', 'kek.kek', 'yandex.ru']
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
        else:
            show_error(name, host_ips,prev_ips[name])
        prev_ips[name] = host_ips
    time.sleep(5)
	
	```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так получилось, что мы очень часто вносим правки в конфигурацию своей системы прямо на сервере. Но так как вся наша команда разработки держит файлы конфигурации в github и пользуется gitflow, то нам приходится каждый раз переносить архив с нашими изменениями с сервера на наш локальный компьютер, формировать новую ветку, коммитить в неё изменения, создавать pull request (PR) и только после выполнения Merge мы наконец можем официально подтвердить, что новая конфигурация применена. Мы хотим максимально автоматизировать всю цепочку действий. Для этого нам нужно написать скрипт, который будет в директории с локальным репозиторием обращаться по API к github, создавать PR для вливания текущей выбранной ветки в master с сообщением, которое мы вписываем в первый параметр при обращении к py-файлу (сообщение не может быть пустым). При желании, можно добавить к указанному функционалу создание новой ветки, commit и push в неё изменений конфигурации. С директорией локального репозитория можно делать всё, что угодно. Также, принимаем во внимание, что Merge Conflict у нас отсутствуют и их точно не будет при push, как в свою ветку, так и при слиянии в master. Важно получить конечный результат с созданным PR, в котором применяются наши изменения. 


---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
