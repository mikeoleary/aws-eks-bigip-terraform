#!/bin/bash

#wait for big-ip
sleep 120

#admin config
tmsh modify auth user admin { password ${password} }
tmsh modify auth user admin shell bash
tmsh modify sys global-settings gui-setup disabled

tmsh save sys config
#create partition for CIS to manage
tmsh create auth partition kubernetes

#create VLANs and self ips
tmsh create net vlan external interfaces add { 1.1 }
tmsh create net vlan internal interfaces add { 1.2 }
tmsh create net self ${ext_self_ip}/24 vlan external
tmsh create net self ${int_self_ip}/24 vlan internal

#create route for all 10.x networks via internal VLAN
tmsh create net route 10.0.0.0/8 gw 10.0.2.1