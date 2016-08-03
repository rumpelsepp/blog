#!/bin/bash

mydate=$(date +"%Y-%m-%d")
mytime=$(date +"%I-%M-%S")

ipsUP="${mydate}_${mytime}_nmap_ips_UP"
ipList="${mydate}_${mytime}_iplist"
ipsDetails="${mydate}_${mytime}_nmap_ips_details"

# inputs
iprange="10.80.105.0"
ipsubnet="24"

#echo $ipsUP
#echo $ipList
#echo $ipsDetails

echo "scanning ip networks"
echo "scanning iprange: ${iprange}/${ipsubnet}"
echo ""
echo ""

echo -n "starting nmap scan for IPs up ... "
nmap -vv -sn "${iprange}/${ipsubnet}" | grep -B 1 up >> "$ipsUP"
echo "done"

echo -n "creating IP list ... "
grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' "$ipsUP" >> "$ipList"
echo "done"

echo -n "found hosts: "
wc -l "$ipList"
echo ""

#
# this part should be parallized to make things faster
#
echo "starting detail nmap scan ... "
while IFS='' read -r line || [[ -n "$line" ]]; do
#	echo "Text read from file: $line"
	echo "analysing IP: $line"
	nmap -vv -A -Pn "$line" >> "${ipsDetails}_${line}"
done < "$ipList"
echo "done"
