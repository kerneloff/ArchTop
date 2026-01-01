#!/bin/bash
# drunk_mouse_fixed.sh

if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo "Error: Not running in Hyprland!"
    exit 1
fi

echo "Activating drunk mouse mode for 2 minutes..."
echo "Press Ctrl+C to stop early"

original_sens=$(hyprctl getoption input:sensitivity | grep float | awk '{print $2}' 2>/dev/null || echo "1.0")
original_accel=$(hyprctl getoption input:force_no_accel | grep int | awk '{print $2}' 2>/dev/null || echo "0")

cleanup() {
    echo -e "\nRestoring mouse settings..."
    hyprctl keyword input:sensitivity "$original_sens" 2>/dev/null
    hyprctl keyword input:force_no_accel "$original_accel" 2>/dev/null
    hyprctl keyword input:scroll_factor 1.0 2>/dev/null
    echo "Mouse is sober again!"
    exit 0
}

trap cleanup INT TERM EXIT

end_time=$((SECONDS + 120))
while [ $SECONDS -lt $end_time ]; do
    # Чувствительность 0.1-3.0 без bc
    sens=$(echo "0.1 + 2.9 * $RANDOM / 32767" | awk '{printf "%.2f", $1}')
    hyprctl keyword input:sensitivity "$sens" 2>/dev/null
    
    # Ускорение вкл/выкл
    accel=$((RANDOM % 2))
    hyprctl keyword input:force_no_accel "$accel" 2>/dev/null
    
    # Фактор прокрутки 0.5-3.0
    scroll=$(echo "0.5 + 2.5 * $RANDOM / 32767" | awk '{printf "%.2f", $1}')
    hyprctl keyword input:scroll_factor "$scroll" 2>/dev/null
    
    # Пауза 0.1-0.5 сек
    sleep_time=$(echo "0.1 + 0.4 * $RANDOM / 32767" | awk '{printf "%.2f", $1}')
    sleep "$sleep_time"
done

cleanup
