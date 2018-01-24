#!/bin/bash

set -e

if ! command -v ansible >/dev/null; then
  become apt-get update

  become add-apt-repository -y ppa:ansible/ansible
  become apt-get update
  become apt-get install -y ansible
fi
