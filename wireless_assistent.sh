#!/bin/bash

check_speaker() {
    aplay -l 2>/dev/null | grep -q "JBL"
}

# Ждём первое подключение
while ! check_speaker; do
    echo "Ожидаем колонку JBL..."
    sleep 2
done

echo "Колонка JBL подключена, запускаем приложение"
/home/unitree/anaconda3/envs/assistent/bin/python /home/unitree/voise_assisent/main.py &
APP_PID=$!

# Даём Python время на инициализацию
sleep 3

# Мониторинг
while true; do
    sleep 2
    
    if ! check_speaker; then
        echo "Колонка JBL потеряна!"
        
        # Убиваем приложение
        kill -9 $APP_PID 2>/dev/null
        wait $APP_PID 2>/dev/null
        
        # Ждём возвращения колонки
        while ! check_speaker; do
            echo "Ожидаем переподключение колонки JBL..."
            sleep 2
        done
        
        echo "Колонка JBL вернулась"
        
        # ВАЖНО: даём ALSA время на инициализацию
        sleep 3
        
        # Перезапускаем
        /home/unitree/anaconda3/envs/assistent/bin/python /home/unitree/voise_assisent/main.py &
        APP_PID=$!
        
        # Даём Python время на инициализацию
        sleep 3
    fi
done
