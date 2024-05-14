# MinIO Docker Compose Project

## Установка и настройка проекта

- Установить утилиту **make**:

```bash
sudo apt install -y make
```

- Выполните команды:

```bash
git clone https://github.com/wmsamolet/minio.git
cd ./minio
cp -n .env.example .env
```

- Отредактируйте файл **.env**

- Для автоматической установки docker-проекта выполните команды:

```bash
make install
```

- Запустите docker-проект

```bash
make start
```

## Полезные команды для управления прокетом (см. Makefile):

Запуск **bash-оболочки** внутри **php-контейнера**:
```bash
make bash
```

Запуск:
```bash
make start
```

Остановка:
```bash
make stop
```

Перезапуск:
```bash
make restart
```

Инициализация (**composer install**, **./init**, **./yii migrate/up**, и.т.д.):
```bash
make init
```

Удаление:
```bash
make uninstall
```

Переустановка:
```bash
make reinstall
```
