Развертывание веб-сервисов на линух сервере (Debian) в автоматическом режиме, в лучших традициях DevOps.

1. Необходимо установить дистрибутив Debian на физическую или виртуальную машину, без гуя, только SSH сервер и стандартные системные утилиты.
2. Авторизоваться под рутом.
3. Настроить доступ в интернет.
4. Скачать скрипт: wget https://github.com/rj21dev/born2beroot/blob/master/deploy.sh
5. Отредактировать переменные (имена, пароли): vi deploy.sh
6. Запустить скрипт: sh deploy.sh
7. ВУАЛЯ!

После перезагрузки по локальному IP сервера будут доступны: сайт на SMC WordPress, phpMyAdmin, ftp доступ. Открыты порты 21, 22, 80