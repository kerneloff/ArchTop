#!/bin/bash
# drunk_mouse.sh

echo "Mouse stability compromised..."
original_sens=$(hyprctl getoption input:sensitivity | grep float | awk '{print $2}')

# Плавное изменение чувствительности
for i in {1..20}; do
    sens=$(echo "scale=2; $original_sens * (0.5 + 0.1 * $i * sin($i))" | bc)
    hyprctl keyword input:sensitivity "$sens"
    sleep 0.5
done

# Случайные рывки мыши
(
    while true; do
        sleep $((2 + RANDOM % 5))
        hyprctl keyword input:sensitivity "$((RANDOM % 30 + 5)).$((RANDOM % 10))"
        sleep 0.3
        hyprctl keyword input:sensitivity "$original_sens"
    done
) &

# Через 2 минуты возвращаем нормально
sleep 120
pkill -f "drunk_mouse.sh"
hyprctl keyword input:sensitivity "$original_sens"
echo "Mouse stability restored!"
