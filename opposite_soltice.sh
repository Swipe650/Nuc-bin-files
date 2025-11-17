#!/bin/bash

echo "🌞  Opposite Date Calculator (Winter Solstice)"
echo "📅  Enter a date in UK format (DD/MM/YYYY or DD/MM/YY):"
read INPUT_DATE
echo ""

# Validate basic format
if [[ ! "$INPUT_DATE" =~ ^[0-9]{1,2}/[0-9]{1,2}/([0-9]{2}|[0-9]{4})$ ]]; then
    echo "❌ Invalid format. Please use DD/MM/YYYY."
    exit 1
fi

# Extract date parts
DAY=$(echo "$INPUT_DATE" | cut -d'/' -f1)
MONTH=$(echo "$INPUT_DATE" | cut -d'/' -f2)
YEAR=$(echo "$INPUT_DATE" | cut -d'/' -f3)

# Normalize 2-digit year
if [[ ${#YEAR} -eq 2 ]]; then
    YEAR="20$YEAR"
fi

# Convert input to timestamp (also validates date)
if ! DATE_TS=$(date -d "$YEAR-$MONTH-$DAY" +%s 2>/dev/null); then
    echo "❌ Invalid date entered."
    exit 1
fi

# Winter solstice timestamp (21 Dec)
SOLSTICE_TS=$(date -d "$YEAR-12-21" +%s)

# Difference in days
DIFF_DAYS=$(( (DATE_TS - SOLSTICE_TS) / 86400 ))

# Opposite date timestamp
OPPOSITE_TS=$(( SOLSTICE_TS - (DATE_TS - SOLSTICE_TS) ))

# Convert back to readable UK date
OPPOSITE_DATE=$(date -d "@$OPPOSITE_TS" +"%d/%m/%Y")

# Output results
#echo "------------------------------------------"
echo "📥  Input date:        $INPUT_DATE"
echo "❄️  Winter Solstice:   21/12/$YEAR"
echo "📏  Days from solstice: $DIFF_DAYS"
echo "🔄  Opposite date:     $OPPOSITE_DATE"
#echo "------------------------------------------"
# echo "🌙  Calculation complete!"
