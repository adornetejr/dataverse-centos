#!/bin/bash
# SERVICE FIREWALLD RESTART
systemctl enable firewalld
systemctl start firewalld
# FIREWALLD PORTS
firewall-cmd --permanent --add-port=25/tcp
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --add-port=8181/tcp
firewall-cmd --permanent --add-port=4848/tcp
firewall-cmd --permanent --add-port=8983/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=8009/tcp
firewall-cmd --reload
systemctl restart firewalld
# FIREWALLD STATUS
systemctl status firewalld