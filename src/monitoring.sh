#/usr/bin/env bash

# printf don't newline 

arch=$(uname -a)

lastcpu_idx=$(lscpu -p | tail -1 | cut -d',' -f1)
cpus=$((lastcpu_idx + 1))

vcpus=$cpus


get_table_cell() {
  local table=$1
  local ui_row=$2
  local ui_col=$3
  $table | awk -v row="$2" -v col="$3" 'NR==row{print $col}'
}

kb_to_gb() {
  local kb=$1
  echo "scale=2; $kb / 1048576" | bc
}

percent() {
  local part=$1
  local total=$2
  echo "scale=2; $part / $total * 100" | bc
}

get_gb() {
  local table=$1
  local row=$2
  local col=$3
  local kb=$(get_table_cell "$table" $row $col)
  kb_to_gb $kb
}

get_usage() {
  local table=$1 row=$2 total_col=$3 used_col=$4
  used_gb=$(get_gb "$table" $row $used_col)
  total_gb=$(get_gb "$table" $row $total_col)
}


get_usage "free" 2 2 3
mem_msg="$used_gb/$total_gb GB ($(percent $used_gb $total_gb)%)"

get_usage "df /" 2 2 3
disk_percent=$(get_table_cell "df /" 2 5)
disk_msg="$used_gb/$total_gb GB ($disk_percent)"

last_boot="$(uptime -s | cut -d':' -f1-2)"

if lsblk -o TYPE | grep -q lvm; then
  lvm_usage="yes"
else
  lvm_usage="no"
fi

ip=$(hostname -I | awk '{print $1}')
mac=$(ip link | awk '/ether/{print $2}')

coms_w_sud=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

wall "
	#Architecture: $arch
	#Physical CPUs: $cpus
	#vCPUs: $vcpus
	#Memory Usage: $mem_msg
	#Disk Usage: $disk_msg
	#Last boot: $last_boot
	#LVM use: $lvm_usage
	#Connections TCP: $(ss -t | grep -c ESTAB) ESTABLISHED
	#User log: $(who | wc -l)
	#Network: $ip ($mac)
	#Sudo: $coms_w_sud cmd"
