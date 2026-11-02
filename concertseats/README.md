# L68 – Concert Ticket Counter

**Student:** JUNED ANSARI | **Roll:** F23 | **Division:** G | **Enrollment:** 24004501210017

## Problem
Build a seat-booking counter for a college concert with seat map, categories and revenue.

## Who will use it
Event teams selling tickets at the desk.

## Folder structure
- main.sh – menu (run with ./main.sh)
- lib/functions.sh – all functions
- data/ – data files
- reports/ – reports created by the script
- backups/ – tar.gz backups
- logs/ – activity.log and cron.log

## Features
1. Show the seat map (booked seats marked X)
2. Book a seat if it is free
3. Cancel a booking
4. Show revenue by category using bc
5. Show a SOLD OUT message when all seats are booked

## How to run
    cd ~/linux_project/concertseats
    ./main.sh
    ./main.sh --help

## Crontab task
Every hour, save the booked-seat count to reports/sales_log.txt

    0 * * * * /bin/bash $HOME/linux_project/concertseats/main.sh --cron >> $HOME/linux_project/concertseats/logs/cron.log 2>&1

## Commands used
arrays, for loop, case, sed -i, bc, printf

## What I learned

- Learned how to use Bash functions and loops.
- Practiced reading and updating CSV data using Linux commands.
- Implemented seat booking, cancellation and revenue calculation.
- Learned to create backups using tar.gz.
- Used cron to schedule an hourly sales log.
