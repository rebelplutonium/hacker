#!/bin/sh

echo emory.merryman+$(cat /dev/urandom | tr -dc "A-DG-HS-TX-Y3-9" | fold -w 8 | head -n 1)@gmail.com