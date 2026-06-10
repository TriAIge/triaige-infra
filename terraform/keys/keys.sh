#!/bin/bash

keysPath="$(pwd)"

publicKeyPath="$keysPath/key-ec2-public-triaige.pem"
privateKeyPath="$keysPath/key-ec2-private-triaige.pem"

ssh-keygen -t rsa -b 2048 -m PEM -f "$publicKeyPath" -N ""
ssh-keygen -t rsa -b 2048 -m PEM -f "$privateKeyPath" -N ""

chmod 400 "$publicKeyPath"
chmod 400 "$privateKeyPath"
