#!/bin/bash

echo "=== Electric Bill Calculator ==="

# Utility Warehouse

day_rate_p=38.685
night_rate_p=5.201
standing_charge_p=52.625

# Convert to pounds (keep high precision internally)
day_rate=$(echo "scale=6; $day_rate_p / 100" | bc)
night_rate=$(echo "scale=6; $night_rate_p / 100" | bc)
standing_charge=$(echo "scale=6; $standing_charge_p / 100" | bc)

# Get usage and number of days
read -p "Enter number of kWh used during the day: " day_usage
read -p "Enter number of kWh used during the night: " night_usage
read -p "Enter number of days standing charge: " num_days

# Calculate costs (IMPORTANT: set scale here too)
day_cost=$(echo "scale=6; $day_rate * $day_usage" | bc)
night_cost=$(echo "scale=6; $night_rate * $night_usage" | bc)
standing_cost=$(echo "scale=6; $standing_charge * $num_days" | bc)
total_cost=$(echo "scale=6; $day_cost + $night_cost + $standing_cost" | bc)

# Format to 2 decimal places for money display
printf "\n=== Bill Breakdown ===\n"
printf "Day rate (%sp)       : £%.2f\n" "$day_rate_p" "$day_cost"
printf "Night rate (%sp)     : £%.2f\n" "$night_rate_p" "$night_cost"
printf "Standing charge (%sp): £%.2f\n" "$standing_charge_p" "$standing_cost"
printf -- "-----------------------------\n"
printf "Total cost           : £%.2f\n" "$total_cost"
