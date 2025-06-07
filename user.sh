#!/bin/bash

source ./common.sh
app_name=user

check_root
# check the user has root priveleges or not

app_setup

nodejs_setup

systemd_setup
print_time