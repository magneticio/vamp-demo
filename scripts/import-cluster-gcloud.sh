#!/bin/sh

export VAMP_ENDPOINT=$(terraform output vamp_endpoint)
export VAMP_IP_NAME=$(terraform output vamp_ip_name)
export VAMP_IP_ADDRESS=$(terraform output vamp_ip_address)
export VGA_IP_NAME=$(terraform output vga_ip_name)
export VGA_IP_ADDRESS=$(terraform output vga_ip_address)