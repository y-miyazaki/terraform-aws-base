#!/bin/bash
#######################################
# Description: CSV processing utility functions for shell scripts
#
# Usage: source /path/to/scripts/lib/csv.sh
#######################################

#######################################
# csv_sort: Sort CSV data properly handling quoted fields
#
# Description:
#   Sorts CSV data with proper handling of quoted fields containing commas and newlines
#
# Arguments:
#   $1 - CSV data to sort
#
# Returns:
#   Sorted CSV data (to stdout)
#
# Usage:
#   sorted_data=$(csv_sort "$csv_data")
#
#######################################
function csv_sort {
    local input_data="$1"

    # For complex CSV data with quoted fields, use Python to sort properly
    if command -v python3 > /dev/null 2>&1; then
        printf "%b" "$input_data" | python3 -c "
import csv
import sys
from io import StringIO

# Read CSV data from stdin
csv_data = sys.stdin.read()
reader = csv.reader(StringIO(csv_data))
rows = list(reader)

# Sort by multiple columns: Region(4), SubCategory(1), SubSubCategory(2), Name(3)
# Columns are 0-indexed, so subtract 1 from 1-indexed sort keys
try:
    sorted_rows = sorted(rows, key=lambda row: (
        row[4] if len(row) > 4 else '',  # Region
        row[1] if len(row) > 1 else '',  # SubCategory
        row[2] if len(row) > 2 else '',  # SubSubCategory
        row[3] if len(row) > 3 else ''   # Name
    ))

    # Write sorted CSV to stdout
    writer = csv.writer(sys.stdout, quoting=csv.QUOTE_MINIMAL)
    for row in sorted_rows:
        writer.writerow(row)
except Exception as e:
    # Fallback: output unsorted if Python sorting fails
    sys.stdout.write(csv_data)
"
    else
        # Fallback to basic sort if Python is not available
        printf "%b" "$input_data" | sort -t, -k4,4 -k2,2 -k3,3 -k5,5
    fi
}

#######################################
# make_csv_safe: Make values CSV-safe by removing problematic characters
#
# Description:
#   Makes values safe for CSV output by handling special characters and quoting
#
# Arguments:
#   $1 - value to make CSV-safe
#
# Returns:
#   CSV-safe value with proper quoting and escaping (to stdout)
#
# Usage:
#   safe_value=$(make_csv_safe "value,with,commas")
#
#######################################
function make_csv_safe {
    local value=$1

    # Preserve newlines for better Excel/Numbers compatibility
    # Only remove carriage returns, keep newlines
    value=$(echo "$value" | tr -d '\r')

    # Convert tabs to spaces
    value=$(echo "$value" | tr '\t' ' ')

    # Compress multiple spaces to single space (but preserve newlines)
    # Use a more precise pattern that doesn't affect newlines
    value=$(echo "$value" | sed 's/[[:blank:]]\{2,\}/ /g' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')

    # If value contains commas, wrap in quotes and escape internal quotes
    if [[ "$value" == *","* ]]; then
        # Escape existing quotes by doubling them
        value=${value//\"/\"\"}
        value="\"$value\""
    elif [[ "$value" == *"\""* ]] || [[ "$value" == *$'\n'* ]] || [[ "$value" =~ ^[[:blank:]]*$ ]]; then
        # Escape existing quotes by doubling them
        value=${value//\"/\"\"}
        value="\"$value\""
    fi

    echo "$value"
}

#######################################
# CSV Value Normalization Functions
#######################################

#######################################
# normalize_csv_value: Normalize and quote a value for safe CSV output
#
# Description:
#   Normalizes and quotes a value for safe CSV output with proper escaping
#
# Arguments:
#   $1 - value to normalize
#
# Returns:
#   CSV-safe value, always quoted (to stdout)
#
# Usage:
#   quoted_value=$(normalize_csv_value "value with \"quotes\"")
#
#######################################
function normalize_csv_value {
    local value="$1"
    local default_value="${2:-""}"

    # Treat empty/null as empty string
    if [[ -z "$value" || "$value" == "null" ]]; then
        echo "$default_value"
        return
    fi

    # Quote if contains comma, quote, or newline
    if [[ "$value" == *","* || "$value" == *"\""* || "$value" == *$'\n'* ]]; then
        value="${value//\"/\"\"}"
        echo "\"$value\""
    else
        echo "$value"
    fi
}
