#!/usr/bin/env bash
set -e

sudo bash -e <<SCRIPT
export DEBIAN_FRONTEND=noninteractive

apt-get install -y nginx

SCRIPT