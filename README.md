# pymongo-api

## Как запустить

Перейти в директорию с проектом

```shell
cd sharding-repl-cache
```

Запускаем mongodb, redis и приложение

```shell
docker compose up -d
```

Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

## Как проверить

Откройте в браузере http://localhost:8000

[Ссылка на схему](https://raw.githubusercontent.com/d-dmitriev/architecture-sprint-2/sprint_2/sprint_2.drawio)
