#!/usr/bin/env bash

sudo mkdir /media/fasthdd
sudo dd if=/dev/zero of=/media/fasthdd/aux-swapfile-1.img bs=1024 count=8
sudo chmod 600 /media/fasthdd/aux-swapfile-1.img
sudo chown root $_
sudo mkswap $_
sudo echo "$_ swap swap sw 0 0" >> /etc/fstab
sudo swapon /media/fasthdd/aux-swapfile-1.img
