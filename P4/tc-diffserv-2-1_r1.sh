#!/bin/sh

PC1_IP="11.188.0.10/32"
PC2_IP="11.188.0.20/32"

tc qdisc add dev eth0 ingress handle ffff:

# Flujo 1: máximo 1.2mbit con ráfaga 10k para el tráfico dirigido a pc4, marcado con calidad EF. Si se supera este ancho de banda, pasa al flujo 2.

tc filter add dev eth0 parent ffff: \
	protocol ip prio 4 u32 \
	match ip src $PC1_IP \
	police rate 1.2mbit burst 10k continue flowid :1
	
# Flujo 2: máximo de 600kbt y ráfaga 10k, marcado con calidad AF31. Si se supera este ancho de banda, el tráfico será descartao definitivamente en r1

tc filter add dev eth0 parent ffff: \
	protocol ip prio 5 u32 \
	match ip src $PC1_IP \
	police rate 600kbit burst 10k drop flowid :2

# Flujo 3: máximo 300kbit con ráfaga 10k para el tráfico dirigido a pc5, marcado con calidad AF21. Si se supera este ancho de banda, pasa al flujo 4.

tc filter add dev eth0 parent ffff: \
	protocol ip prio 4 u32 \
	match ip src $PC2_IP \
	police rate 300kbit burst 10k continue flowid :3
	
# Flujo 4: máximo de 400kbit y ráfaga 10k, marcado con calidad AF11. Si se supera este ancho de banda, el tráfico será descartao definitivamente en r1

tc filter add dev eth0 parent ffff: \
	protocol ip prio 5 u32 \
	match ip src $PC2_IP \
	police rate 400kbit burst 10k drop flowid :4
	
# Crear disciplina de cola de salida DSMARK
	
tc qdisc add dev eth1 root handle 1:0 dsmark indices 8

tc class change dev eth1 classid 1:1 dsmark mask 0x3 value 0xb8
tc class change dev eth1 classid 1:2 dsmark mask 0x3 value 0x68
tc class change dev eth1 classid 1:3 dsmark mask 0x3 value 0x48
tc class change dev eth1 classid 1:4 dsmark mask 0x3 value 0x28

tc filter add dev eth1 parent 1:0 protocol ip prio 1 \
	handle 1 tcindex classid 1:1
	
tc filter add dev eth1 parent 1:0 protocol ip prio 1 \
	handle 2 tcindex classid 1:2
	
tc filter add dev eth1 parent 1:0 protocol ip prio 1 \
	handle 3 tcindex classid 1:3

tc filter add dev eth1 parent 1:0 protocol ip prio 1 \
	handle 4 tcindex classid 1:4


