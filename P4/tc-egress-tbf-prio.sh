#!/bin/sh

INTERFACE="eth1"

tc qdisc add dev $INTERFACE root handle 1: tbf rate 1.5mbit burst 10k latency 20s

tc qdisc add dev $INTERFACE parent 1:0 handle 10:0 prio

tc filter add dev $INTERFACE parent 10:0 prio 1 protocol ip u32 \
	match ip src 11.188.0.10/32 flowid 10:1

tc filter add dev $INTERFACE parent 10:0 prio 2 protocol ip u32 \
	match ip src 11.188.0.20/32 flowid 10:2

