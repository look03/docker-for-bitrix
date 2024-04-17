## Установка программ
Перед тем как приступить к подготовке проекта требуется установить описанный ниже перечень программ.
- `Git` ([установка](https://git-scm.com/book/ru/v2/%D0%92%D0%B2%D0%B5%D0%B4%D0%B5%D0%BD%D0%B8%D0%B5-%D0%A3%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0-Git))
- `Docker` ([установка](https://docs.docker.com/engine/install/))
- `Docker-Compose` ([установка](https://docs.docker.com/compose/install/))

> Для правильной работы скриптов развертывания на `Windows` требуется установить `WSL 2` ([установка](https://docs.microsoft.com/ru-ru/windows/wsl/install)). `WSL 2` также потребуется при установки `Docker` и `Docker-Compose` на `Windows`.


Для корректной работы ElasticSearch при запуске проекта вводить каждый раз команду ([ссылка](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#_set_vm_max_map_count_to_at_least_262144)):
```shell
$ sudo sysctl -w vm.max_map_count=262144
```

После подготовки клонирования инфраструктуры проекта выполнить команду находясь в корне папки:
```shell
$ make init
```

Установочник для bitrix кладем в src/api