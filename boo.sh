#!/bin/bash
# drunk_mouse_working.sh

if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo "Error: Run this in Hyprland!"
    exit 1
fi

echo "Activating drunk mouse mode for 2 minutes..."
echo "Press Ctrl+C to stop"

original_sens=$(hyprctl getoption input:sensitivity 2>/dev/null | grep float | awk '{print $2}' || echo "1.0")

cleanup() {
    echo -e "\nRestoring mouse sensitivity..."
    hyprctl keyword input:sensitivity "$original_sens" 2>/dev/null
    echo "Mouse is sober!"
    exit 0
}

trap cleanup INT TERM

end_time=$(( $(date +%s) + 120 ))

while [ $(date +%s) -lt $end_time ]; do
    # Простая случайная чувствительность от 0.1 до 3.0
    sens_num=$(( RANDOM % 30 + 1 ))  # 1-30
    sens=$(echo "$sens_num / 10" | awk '{printf "%.1f", $1}')  # 0.1-3.0
    
    hyprctl keyword input:sensitivity "$sens" 2>/dev/null
    
    # Случайное время сна 0.1-1.0 секунд
    sleep_time=$(( RANDOM % 10 + 1 ))
    sleep "0.$sleep_time"
done

cleanup
