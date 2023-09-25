#!/bin/sh

# Se crea la disciplina de cola ingress para rellenar el campo tc_index
tc qdisc add dev eth2 root handle 1:0 dsmark indices 8 set_tc_index

tc filter add dev eth2 parent 1:0 protocol ip prio 1 \
	tcindex mask 0xfc shift 2
	
tc qdisc add dev eth2 parent 1:0 handle 2:0 htb

tc class add dev eth2 parent 2:0 classid 2:1 htb rate 2.4Mbit

#Modificacion poner 2.4Mbit en los ceil
# Interfaz ETH2
tc class add dev eth2 parent 2:1 classid 2:10 htb rate 1Mbit ceil 1Mbit # Flujo EF
tc class add dev eth2 parent 2:1 classid 2:11 htb rate 500kbit ceil 2.4Mbit # Flujo AF31
tc class add dev eth2 parent 2:1 classid 2:12 htb rate 400kbit ceil 2.4Mbit # Flujo AF21
tc class add dev eth2 parent 2:1 classid 2:13 htb rate 200kbit ceil 2.4Mbit # Flujo AF11

# ETH2 Trafico EF=> DS=0xb8 => DSCP=0x2e
tc filter add dev eth2 parent 2:0 protocol ip prio 1 \
handle 0x2e tcindex classid 2:10

# ETH2 Trafico AF31=> DS=0x68 => DSCP=0x1a
tc filter add dev eth2 parent 2:0 protocol ip prio 1 \
handle 0x1a tcindex classid 2:11

# ETH2 Trafico AF21=> DS=0x48 => DSCP=0x12
tc filter add dev eth2 parent 2:0 protocol ip prio 1 \
handle 0x12 tcindex classid 2:12

# ETH2 Trafico AF11=> DS=0x28 =00101000 => DSCP=001010=0x0a
tc filter add dev eth2 parent 2:0 protocol ip prio 1 \
handle 0x0a tcindex classid 2:13

