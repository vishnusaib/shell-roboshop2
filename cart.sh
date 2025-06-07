#!/bin/bash

source ./common.sh
app_name=cart
# check the user has root priveleges or not
check_root
app_setup

nodejs_setup

systemd_setup
print_time