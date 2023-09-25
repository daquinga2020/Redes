#!/bin/sh

INTERFACE="eth0"
PC1_IP="11.188.0.10/32"
PC2_IP="11.188.0.20/32"

# Verificar si ya existe una disciplina de cola en la interfaz
if tc qdisc show dev $INTERFACE | grep -q "ingress"; then
    # Si existe, eliminarla
    tc qdisc del dev $INTERFACE ingress
fi

tc qdisc add dev $INTERFACE ingress handle ffff:

# Agregar el filtro para el flujo 1. Restringir el flujo 1 a 1mbit/s y 10k de cubeta con TBF
tc filter add dev $INTERFACE parent ffff: protocol ip prio 4 u32 match ip src $PC1_IP police rate 1mbit burst 10k drop flowid :1

# Agregar el filtro para el flujo 2. Restringir el flujo 2 a 2mbit/s y 10k de cubeta
tc filter add dev $INTERFACE parent ffff: protocol ip prio 5 u32 match ip src $PC2_IP police rate 2mbit burst 10k drop flowid :2
