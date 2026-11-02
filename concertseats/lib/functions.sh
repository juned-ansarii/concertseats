#!/bin/bash
# lib/functions.sh – all functions for Concert Ticket Counter
DATA="data/seats.txt"

LOG="logs/activity.log"

# write one line to the activity log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $*" >> "$LOG"
}

# check the data file / folder exists before using it
check_data() {
    if [ ! -e "$DATA" ]; then
        echo "Data not found: $DATA"
        return 1
    fi
}

show_help() {
    echo "Usage: ./main.sh            -> open the menu"
    echo "       ./main.sh --help     -> show this help"
    echo "       ./main.sh --backup   -> backup data/ now"
    echo "       ./main.sh --cron     -> run the scheduled (crontab) task"
}

view_data() {
    check_data || return
    if [ -d "$DATA" ]; then ls -l "$DATA"; else cat -n "$DATA" | more; fi
}

do_backup() {
    f="backups/data_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$f" data/
    echo "Backup saved: $f ($(du -h "$f" | cut -f1))"
    log "backup created $f"
}

view_log() {
    if [ -f "$LOG" ]; then tail -n 15 "$LOG"; else echo "No activity yet."; fi
}

# ------------------------------------------------------------
# FEATURE 1: Show the seat map (booked seats marked X)
# Commands you can use: arrays, for loop, case, sed -i, bc, printf
# --------------------------------------------
feature_1() {
    echo "== Show the seat map (booked seats marked X) =="
    check_data || return

    printf "%-10s %-10s %-10s\n" "SEAT" "CATEGORY" "STATUS"
    while IFS=, read -r seat category status; do
        [ "$seat" = "seat" ] && continue

        if [ "$status" = "booked" ]; then
            mark="X"
        else
            mark="O"
        fi

        printf "%-10s %-10s %-10s\n" "$seat" "$category" "$mark"
    done < "$DATA"

    log "Seat map viewed"
}
# ------------------------------------------------------------
# FEATURE 2: Book a seat if it is free
# Commands you can use: arrays, for loop, case, sed -i, bc, printf
# ------------------------------------------------------------
feature_2() {
    echo "== Book a seat =="
    check_data || return

    read -p "Enter seat ID to book: " key

    if ! grep -q "^${key}," "$DATA"; then
        echo "Seat not found."
        return
    fi

    status=$(grep "^${key}," "$DATA" | cut -d, -f3)

    if [ "$status" = "booked" ]; then
        echo "Sorry, this seat is already booked."
        return
    fi

    sed -i "/^${key},/s/free$/booked/" "$DATA"
    echo "Seat $key booked successfully."
    log "Seat $key booked"
}

# ------------------------------------------------------------
# FEATURE 3: Cancel a booking
# Commands you can use: arrays, for loop, case, sed -i, bc, printf
# -----------------------------------------------------------
feature_3() {
    echo "== Cancel a booking =="
    check_data || return

    read -p "Enter seat ID to cancel: " key

    if ! grep -q "^${key}," "$DATA"; then
        echo "Seat not found."
        return
    fi

    status=$(grep "^${key}," "$DATA" | cut -d, -f3)

    if [ "$status" = "free" ]; then
        echo "This seat is not booked."
        return
    fi

    sed -i "/^${key},/s/booked$/free/" "$DATA"
    echo "Booking for seat $key cancelled successfully."
    log "Booking cancelled for seat $key"
}
feature_3() {
    echo "== Cancel a booking =="
    check_data || return

    read -p "Enter seat ID to cancel: " key

    if ! grep -q "^${key}," "$DATA"; then
        echo "Seat not found."
        return
    fi

    status=$(grep "^${key}," "$DATA" | cut -d, -f3)

    if [ "$status" = "free" ]; then
        echo "This seat is not booked."
        return
    fi

    sed -i "/^${key},/s/booked$/free/" "$DATA"
    echo "Booking for seat $key cancelled successfully."
    log "Booking cancelled for seat $key"
}
# ------------------------------------------------------------
# FEATURE 4: Show revenue by category using bc
# Commands you can use: arrays, for loop, case, sed -i, bc, printf
# ------------------------------------------------------------
feature_4() {
    echo "== Revenue by category =="
    check_data || return

    GOLD_PRICE=1500
    SILVER_PRICE=1000
    BRONZE_PRICE=500

    for category in GOLD SILVER BRONZE; do
        count=$(awk -F, -v cat="$category" \
            'NR>1 && $2==cat && $3=="booked" {n++} END {print n+0}' "$DATA")

        case "$category" in
            GOLD) price=$GOLD_PRICE ;;
            SILVER) price=$SILVER_PRICE ;;
            BRONZE) price=$BRONZE_PRICE ;;
        esac

        revenue=$(echo "$count * $price" | bc)
        printf "%-10s Tickets: %-3s Revenue: Rs. %s\n" \
            "$category" "$count" "$revenue"
    done

    log "Revenue by category calculated"
}

# ------------------------------------------------------------
# FEATURE 5: Show a SOLD OUT message when all seats are booked
# Commands you can use: arrays, for loop, case, sed -i, bc, printf
# ----------------------------------------------------------
feature_5() {
    echo "== Check seat availability =="
    check_data || return

    total=$(awk -F, 'NR>1 {n++} END {print n+0}' "$DATA")
    booked=$(awk -F, 'NR>1 && $3=="booked" {n++} END {print n+0}' "$DATA")
    free=$((total - booked))

    echo "Total seats: $total"
    echo "Booked seats: $booked"
    echo "Available seats: $free"

    if [ "$total" -gt 0 ] && [ "$free" -eq 0 ]; then
        echo "SOLD OUT! All seats are booked."
    else
        echo "Seats are still available."
    fi

    log "Seat availability checked"
}

# ------------------------------------------------------------
# CRON TASK: Every hour, save the booked-seat count to reports/sales_log.txt
# Runs when crontab calls:  ./main.sh --cron
# ------------------------------------------------------------
cron_task() {
    check_data || return

    mkdir -p reports

    total=$(awk -F, 'NR>1 {n++} END {print n+0}' "$DATA")
    booked=$(awk -F, 'NR>1 && $3=="booked" {n++} END {print n+0}' "$DATA")
    available=$((total - booked))

    echo "$(date '+%Y-%m-%d %H:%M:%S') | Total: $total | Booked: $booked | Available: $available" >> reports/sales_log.txt

    log "Cron task executed: $booked seats booked"
    echo "Sales log updated: reports/sales_log.txt"
    echo "Total: $total | Booked: $booked | Available: $available"
}
