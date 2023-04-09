#!/bin/bash

if [[ $EUID > 0 ]]
  then echo "Run this script as root"
  exit
fi

BRIDGE="br0"
TAP="tap0"
INTERFACE="eth0"

iptables -t nat -D POSTROUTING -o $INTERFACE -j MASQUERADE
iptables -D FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -D FORWARD -i $TAP -o $INTERFACE -j ACCEPT

echo "Removing master of $TAP"
ip link set $TAP nomaster

echo "Setting $TAP down"
ip link set down dev $TAP

echo "Deleting $TAP"
ip tuntap del $TAP

#echo "Removing master of $INTERFACE"
#ip link set $INTERFACE nomaster

echo "Setting $BRIDGE down"
ip link set down dev $BRIDGE

echo "Deleting $BRIDGE"
ip link del $BRIDGE

echo "Setting $INTERFACE up"
ip link set up dev $INTERFACE

killall qemu-system-aarch64
