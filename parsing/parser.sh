#!/bin/bash

# Путь к лог-файлу nginx
NGINX_LOG="/var/log/nginx/access.log"

# Время проверки (в секундах)
CHECK_INTERVAL=120
UNBLOCK_INTERVAL=600

# Временные файлы для хранения заблокированных IP и текущих запросов
CURRENT_IPS="/tmp/current_ips.txt"
BLOCKED_IPS="/tmp/blocked_ips.txt"

# Функция для блокировки IP
block_ip() {
    local ip=$1
    iptables -A INPUT -s $ip -j DROP
    echo "$ip $(date +%s)" >> $BLOCKED_IPS
    echo "Blocked IP: $ip"
}

# Функция для разблокировки IP
unblock_ip() {
    local ip=$1
    iptables -D INPUT -s $ip -j DROP
    sed -i "/$ip/d" $BLOCKED_IPS
    echo "Unblocked IP: $ip"
}

# Парсим лог nginx за последние 2 минуты
parse_log() {
    tail -n 1000 $NGINX_LOG | grep "$(date --date='2 minutes ago' '+%d/%b/%Y:%H:%M')" > $CURRENT_IPS
    tail -n 1000 $NGINX_LOG | grep "$(date '+%d/%b/%Y:%H:%M')" >> $CURRENT_IPS
}

# Проверяем IP на количество запросов
check_ips() {
    cat $CURRENT_IPS | awk '{print $1}' | sort | uniq -c | while read count ip; do
        if [ $count -gt 10 ]; then
            if ! grep -q $ip $BLOCKED_IPS; then
                block_ip $ip
            fi
        fi
    done
}

# Разблокировка IP, если не было запросов за последние 10 минут
unblock_ips() {
    local current_time=$(date +%s)
    while read ip timestamp; do
        if (( current_time - timestamp > UNBLOCK_INTERVAL )); then
            unblock_ip $ip
        fi
    done < $BLOCKED_IPS
}

# Основной цикл скрипта
while true; do
    parse_log
    check_ips
    unblock_ips
    sleep $CHECK_INTERVAL
done