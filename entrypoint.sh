#!/bin/sh

# Setup TZ
echo "Setup timezone"
cp /usr/share/zoneinfo/${TZ:=Europe/Moscow} /etc/localtime
echo ${TZ} > /etc/timezone

if [[ -n ${LETSENCRYPT} ]]; then
    # Make dirs
    mkdir -p /etc/nginx/ssl
    mkdir -p ${ACME_LOCATION:=/etc/letsencrypt/acme}

    # Generate dhparams.pem
    echo "Generate dhparm"
    if [ ! -f /etc/nginx/ssl/dhparams.pem ]; then
        openssl dhparam -dsaparam -out /etc/nginx/ssl/dhparams.pem 2048
        chmod 600 /etc/nginx/ssl/dhparams.pem
    fi

    # Get certs
    if [[ -z ${LE_FQDN} ]]; then
        echo "Env LE_FQDN must be defined!"
        exit 1
    fi
    if [[ -z ${LE_EMAIL} ]]; then
        echo "Env LE_EMAIL must be defined!"
        exit 1
    fi

    echo "Get certificates"
    certbot certonly -n --agree-tos --standalone --email "${LE_EMAIL}" -d "${LE_FQDN}"

    # Start updater and nginx
    (
     sleep 5 #give nginx time to start
     echo "Start letsencrypt updater"
     while :
     do
        echo "Update certificates"
        certbot renew --webroot -w "${ACME_LOCATION}"
        nginx -s reload
        sleep 7d
     done
    ) & nginx -g "daemon off;"
else
    nginx -g "daemon off;"
fi