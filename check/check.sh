#!/bin/bash

# Функция для проверки состояния HTTP сервера
check_http_status() {
    local url="$1"
    local response_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")

    # Проверяем код ответа HTTP
    if [ "$response_code" -ge 200 ] && [ "$response_code" -lt 400 ]; then
        echo "сервак итц ол райд - code #0"
        return 0  # Ок
    elif [ "$response_code" -ge 400 ] && [ "$response_code" -lt 500 ]; then
        echo "сервак больше жив чем мертв  - code #1"
        return 1  # Warning
    elif [ "$response_code" -ge 500 ]; then
        echo "АХТУНГ!!!  - code #2"
        return 2  # Critical
    else
        echo "хз хз хз  - code #2"
        return 2  # Critical, если состояние не определено
    fi
}

# Проверяем аргументы командной строки
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

# Вызываем функцию и передаем URL в качестве аргумента
check_http_status "$1"

# Возвращаем код выхода функции
exit $?
