
 #/usr/bin/env bash
PS4=$'\n+ '
set -x

# check for graphics
rpm -qa | grep -iE "xorg|wayland"

#check structure
lsblk

# check if encrypted
cryptsetup status luks-74eea0d3-8300-4a53-9df7-a66301776844

# sel status
sestatus

check_string() {                                                                                                                                                      
local mode=$1                                                                                                                                                     
local result=$2                                                                                                                                                   
                                                                                                                                                                  
if [ "$mode" = "is" ]; then                                                                                                                                       
  [ -n "$result" ] && echo -e "\e[32mOK!\e[0m" || echo -e "\e[31mERROR!\e[0m"
elif [ "$mode" = "absent" ]; then                                                                                                                                 
  [ -z "$result" ] && echo -e "\e[32mOK!\e[0m" || echo -e "\e[31mERROR!\e[0m"
fi                                                                                                                                                                
}


cat /etc/selinux/config | grep -E "SELINUX=enforcing"

# show blocked
aureport -a

# check sockets
ss -tlnp | grep 4242

# check right security label
semanage port -l | grep ssh_port_t | grep 4242

#check if firewall is up
firewall-cmd --state

# check if port is open
firewall-cmd --query-port=4242/tcp   

# check for hostname
hostname | grep lrain42
#check for entries
cat /etc/hosts | grep lrain42

# check for policies to be present
chage -l lrain | grep -i "minimum" | grep 2
chage -l lrain | grep -i "maximum" | grep 30
chage -l lrain | grep -i "expires" | grep 7

grep -E "^[[:space:]]*PASS_MAX_DAYS[[:space:]]+30" /etc/login.defs
grep -E "^[[:space:]]*PASS_MIN_DAYS[[:space:]]+2" /etc/login.defs                                                                                         
grep -E "^[[:space:]]*PASS_WARN_AGE[[:space:]]+7" /etc/login.defs    

echo "Aa1\!bcd" | pwscore 2>&1 | grep -i "shorter"
echo "aa1\!bcdefgh" | pwscore 2>&1 | grep -i "upper"
echo "AA1\!BCDEFGH" | pwscore 2>&1 | grep -i "lower"                                                                                                       
echo "Aa\!bcdefghij" | pwscore 2>&1 | grep -i "digit"                                                                                                      
echo "Aa1\!bccccde" | pwscore 2>&1 | grep -i "same"
echo "Aa1\!lrainxyz" | pwscore lrain 2>&1 | grep -i "user"

grep -E "^[[:space:]]*difok[[:space:]]*=[[:space:]]*7" /etc/security/pwquality.conf
grep -E "^[[:space:]]*enforce_for_root" /etc/security/pwquality.conf


sudo -V | grep -i "override" | grep "\$PATH"
sudo -V | grep -i "Number of tries" | grep 3
sudo -V | grep -v "Sorry, try again." | grep -i "Incorrect password message"
sudo -V | grep -i "log file" | grep "/var/log/sudo/"
sudo -V | grep -i "Only" | grep -i "allow" | grep -i "tty"

crontab -l | grep "monitoring.sh"  | grep -F "*/10 * * * *"


