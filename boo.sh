#!/bin/bash
# drunk_mouse.sh

# Проверяем что в Hyprland
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo "Error: Not running in Hyprland!"
    echo "Run this from a Hyprland session."
    exit 1
fi

echo "Activating drunk mouse mode for 2 minutes..."
echo "Press Ctrl+C to stop early"

# Сохраняем оригинальные настройки
original_sens=$(hyprctl getoption input:sensitivity | grep float | awk '{print $2}' 2>/dev/null || echo "1.0")
original_accel=$(hyprctl getoption input:force_no_accel | grep int | awk '{print $2}' 2>/dev/null || echo "0")

# Функция восстановления
cleanup() {
    echo -e "\nRestoring mouse settings..."
    hyprctl keyword input:sensitivity "$original_sens" 2>/dev/null
    hyprctl keyword input:force_no_accel "$original_accel" 2>/dev/null
    hyprctl keyword input:scroll_factor 1.0 2>/dev/null
    echo "Mouse is sober again!"
    exit 0
}

trap cleanup INT TERM EXIT

# Основной цикл
end_time=$((SECONDS + 120))
while [ $SECONDS -lt $end_time ]; do
    # Случайная чувствительность (0.1 - 3.0)
    sens=$(echo "scale=2; 0.1 + 2.9 * $RANDOM / 32767" | bc)
    hyprctl keyword input:sensitivity "$sens" 2>/dev/null
    
    # Случайное ускорение вкл/выкл
    accel=$((RANDOM % 2))
    hyprctl keyword input:force_no_accel "$accel" 2>/dev/null
    
    # Случайный фактор прокрутки
    scroll=$(echo "scale=2; 0.5 + 2.5 * $RANDOM / 32767" | bc)
    hyprctl keyword input:scroll_factor "$scroll" 2>/dev/null
    
    # Пауза между изменениями (0.1 - 0.5 сек)
    sleep $(echo "scale=2; 0.1 + 0.4 * $RANDOM / 32767" | bc)
done

cleanup
