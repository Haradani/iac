#!/usr/bin/env bash
set -e

git clone https://github.com/mbeham/nodejs-demo-app.git /home/ubuntu/sample-node-app
sudo bash -e <<SCRIPT
export DEBIAN_FRONTEND=noninteractive

curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
apt-get install -y nodejs

cp /home/ubuntu/sample-node-app/contrib/hello.service /etc/systemd/system

systemctl enable hello

SCRIPT

cd /home/ubuntu/sample-node-app/
npm install