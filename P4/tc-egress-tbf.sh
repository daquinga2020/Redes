#!/bin/sh

INTERFACE="eth1"

tc qdisc add dev $INTERFACE root handle 1: tbf rate 1.5mbit burst 10k latency 10ms
