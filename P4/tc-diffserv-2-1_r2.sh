#!/bin/sh

PC3_IP="12.188.0.30/32"

tc qdisc add dev eth0 ingress handle ffff:

# Flujo 5: máximo 400kbit con ráfaga 10k para el tráfico dirigido a pc6, marcado con calidad AF31. Si se supera este ancho de banda, pasa al flujo 6.

tc filter add dev eth0 parent ffff: \
	protocol ip prio 4 u32 \
	match ip src $PC3_IP \
	police rate 400kbit burst 10k continue flowid :5
	
# Flujo 6: máximo de 300kbit y ráfaga 10k para el tráfico dirigido a pc6, marcado con calidad AF21. Si se supera este ancho de banda, pasa al flujo 7.

tc filter add dev eth0 parent ffff: \
	protocol ip prio 5 u32 \
	match ip src $PC3_IP \
	police rate 300kbit burst 10k continue flowid :6

# Flujo 7: máximo 100kbit con ráfaga 10k, marcado con calidad AF11. Si se supera este ancho de banda, el tráfico será descartado definitivamente en r2.

tc filter add dev eth0 parent ffff: \
	protocol ip prio 6 u32 \
	match ip src $PC3_IP \
	police rate 100kbit burst 10k drop flowid :7
	
# Crear disciplina de cola de salida DSMARK
	
tc qdisc add dev eth1 root handle 1:0 dsmark indices 8

tc class change dev eth1 classid 1:5 dsmark mask 0x3 value 0x68
tc class change dev eth1 classid 1:6 dsmark mask 0x3 value 0x48
tc class change dev eth1 classid 1:7 dsmark mask 0x3 value 0x28

tc filter add dev eth1 parent 1:0 protocol ip prio 1 \
	handle 5 tcindex classid 1:5
	
tc filter add dev eth1 parent 1:0 protocol ip prio 1 \
	handle 6 tcindex classid 1:6
	
tc filter add dev eth1 parent 1:0 protocol ip prio 1 \
	handle 7 tcindex classid 1:7


