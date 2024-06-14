#!/bin/bash

envsubst < /etc/squid/squid.conf.template > /etc/squid/squid.conf

# Start squid
/usr/sbin/squid -f /etc/squid/squid.conf
