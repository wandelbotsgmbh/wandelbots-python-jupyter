#!/bin/bash
sudo envsubst '${BASE_PATH}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
sudo nginx