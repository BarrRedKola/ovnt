#!/bin/sh

source config

best_server=""
min=10000

for i in $(ls  $VPN_ROOT|grep -i "${VPN_COUNTRY}"|grep udp)
do
  server=${i##*/}
  server=${server%.udp1194.ovpn}
  echo -n "Min RTT to $server:  "
  tmp_current_min=$(ping -c3 $server 2>/dev/null)
  success=$(echo $?)
  current_min=$(echo $tmp_current_min|awk -F "=" '{print $NF}'|cut -d '/' -f 1|awk '{print $1}')
  if [ $success -eq 0 ]
  then
    echo $current_min
    c=$(echo "$min > $current_min" |bc -l)
    if [ $c -eq 1 ]
    then
      min=$current_min
      best_server=$i
    fi
  else
    echo "CANNOT BE REACHED"
  fi
done

echo "Best server with a min RTT ${min} is:  ${best_server}"
echo $best_server > last_best_server

