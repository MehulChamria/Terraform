#!/bin/bash
apt-get -y update
apt-get -y install apache2
systemctl start apache2