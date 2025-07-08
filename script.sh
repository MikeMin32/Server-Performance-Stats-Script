#!/bin/bash
echo "------------------------------------------- "
echo
echo "System Monitoring Script"
echo "By @MikeMin"
echo
echo

top -n 1 -b > toplog.txt
df -h > disklog.txt
cat /etc/os-release > oslog.txt


os=`grep "PRETTY_NAME=" oslog.txt | awk -F'"' '{print $2}'`
echo "OS: $os"

uptime=`grep "top - " toplog.txt | awk '{print $5}'`
echo "Uptime: ${uptime::-1}"

users=`grep "top - " toplog.txt | awk -F',' '{for(i=1;i<=NF;i++) if($i ~ /user/) print $i}' | awk '{print $1}'`
echo "Users: $users"




cpu_idle=`grep "%Cpu" toplog.txt | awk -F',' '{for(i=1;i<=NF;i++) if($i ~ /id/) print $i}' | awk '{print $1}'`
cpu_idle_clean=$(echo $cpu_idle | tr -d ' ')
cpu_usage=$(echo "100 - $cpu_idle_clean" | bc)



mem_total=`grep "MiB Mem :" toplog.txt | awk -F',' '{for(i=1;i<=NF;i++) if($i ~ /total/) print $i}' | awk '{print $4}'`
mem_total_clean=$(echo $mem_total | tr -d ' ')

mem_free=`grep "MiB Mem :" toplog.txt | awk -F',' '{for(i=1;i<=NF;i++) if($i ~ /free/) print $i}' | awk '{print $1}'`

mem_used=`grep "MiB Mem :" toplog.txt | awk -F',' '{for(i=1;i<=NF;i++) if($i ~ /used/) print $i}' | awk '{print $1}'`
mem_used_clean=$(echo $mem_used | tr -d ' ')

mem_p=$(echo "$mem_total_clean / 100" | bc)
mem_used_p=$(echo "$mem_used_clean / $mem_p" | bc)


echo " "
cpu_res="   CPU || Used: $cpu_usage% | Idle: $cpu_idle%"
echo $cpu_res


echo " "
mem_res="   Memory || Used: $mem_used Mb - $mem_used_p% | Free: $mem_free Mb | Total: $mem_total Mb"
echo $mem_res

echo " "

disk_used=`grep "/$" disklog.txt | awk '{print$ 3}'`
disk_free=`grep "/$" disklog.txt | awk '{print$ 4}'`
disk_size=`grep "/$" disklog.txt | awk '{print$ 2}'`
disk_used_p=`grep "/$" disklog.txt | awk '{print $5}'`

disk_res="   Disk || Used: $disk_used - $disk_used_p | Free: $disk_free | Size: $disk_size"

echo $disk_res
echo " "
echo "Top processes by CPU usage: "
echo
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 8
echo " "
echo "Top processes by Memory usage: "
echo
ps -eo pid,comm,%mem --sort=-%mem | head -n 8
echo 
echo "------------------------------------------- "


