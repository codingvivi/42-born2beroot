#/usr/bin/env bash
PS4=$'\n+ '
set -x
head -n 2 /etc/os-release

sestatus

ss -tunlp

firewall-cmd --list-services

firewall-cmd --list-ports

firewall-cmd --state
