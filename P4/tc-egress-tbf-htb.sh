#!/bin/sh

INTERFACE="eth1"
PC1_IP="11.188.0.10/32"
PC2_IP="11.188.0.20/32"

tc qdisc add dev $INTERFACE root handle 1:0 htb

tc class add dev $INTERFACE parent 1:0 classid 1:1 htb rate 1.2mbit

tc class add dev $INTERFACE parent 1:1 classid 1:2 htb rate 700kbit ceil 700kbit
tc class add dev $INTERFACE parent 1:1 classid 1:3 htb rate 500kbit ceil 500kbit

tc filter add dev $INTERFACE parent 1:0 protocol ip prio 1 u32 \
	match ip src $PC1_IP \
	flowid 1:2

tc filter add dev $INTERFACE parent 1:0 protocol ip prio 1 u32 \
	match ip src $PC2_IP \
	flowid 1:3
