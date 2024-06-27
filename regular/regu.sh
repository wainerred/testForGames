#!/bin/bash


# Импорт массива URL-адресов из файла urls.sh
source ./urls.sh

# Массив URL-адресов
#urls=(
   # "http://server.com/downloads/life_changing_plans.pdf"
   # "http://server.com/downl/life_changing_plans.doc"
   # "https://server-dot.com/root.pdf"
#)

# Регулярное выражение для захвата имен PDF файлов
pattern='[^/]+\.pdf'

# Цикл по URL-адресам
for url in "${urls[@]}"; do
    # Проверка и вывод имени PDF файла, если оно соответствует паттерну
    if [[ $url =~ $pattern ]]; then
        echo "${BASH_REMATCH[0]}"
    fi
done