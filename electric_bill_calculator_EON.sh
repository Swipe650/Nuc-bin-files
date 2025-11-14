#!/bin/bash

echo "=== Monthly Electric Bill Calculator ==="

# E.On Next Reward v1
# Fixed rates (in pence)
day_rate_p=28.19
night_rate_p=10.92
standing_charge_p=63.62

#Utilty Warehouse
# day_rate_p=37.823
# night_rate_p=5.084
# standing_charge_p=50.362

# Convert to pounds
day_rate=$(echo "scale=4; $day_rate_p / 100" | bc)
night_rate=$(echo "scale=4; $night_rate_p / 100" | bc)
standing_charge=$(echo "scale=4; $standing_charge_p / 100" | bc)

# Get usage and number of days
read -p "Enter number of kWh used during the day: " day_usage
read -p "Enter number of kWh used during the night: " night_usage
read -p "Enter number of days in the current month: " num_days

# Calculate costs
day_cost=$(echo "$day_rate * $day_usage" | bc)
night_cost=$(echo "$night_rate * $night_usage" | bc)
standing_cost=$(echo "$standing_charge * $num_days" | bc)
total_cost=$(echo "$day_cost + $night_cost + $standing_cost" | bc)

# Display breakdown
echo ""
echo "=== Bill Breakdown ==="
echo "Day rate ($day_rate_p)         : £$day_cost"
echo "Night rate ($night_rate_p)       : £$night_cost"
echo "Standing charge ($standing_charge_p)  : £$standing_cost"
echo "-----------------------------"
echo "Total cost for month : £$total_cost"
