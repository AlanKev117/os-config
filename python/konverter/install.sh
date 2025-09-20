#!/bin/bash

set -e

SERVICE_DIR=$(pwd)
ENV_DIR=env
SERVICE_FILE_NAME=konverter.service
NGINX_SERVICE_FILE=konverter
INTERNAL_PORT=5000

if [ -d "${SERVICE_DIR}/${ENV_DIR}" ]
then
    echo "Virtual env exists, dependencies should be there too..."
else
    echo "Virtual env missing, dependencies will be installed..."
    python3 -m venv ${ENV_DIR}
    source ${ENV_DIR}/bin/activate
    pip3 install -r requirements.txt
fi

echo "Creating systemd service..."
sed "s|{SERVICE_DIR}|${SERVICE_DIR}|g" ${SERVICE_FILE_NAME}.template > ./${SERVICE_FILE_NAME}
sed -i "s|{ENV_DIR}|${ENV_DIR}|" ./${SERVICE_FILE_NAME}
sed -i "s|{PORT}|${INTERNAL_PORT}|" ./${SERVICE_FILE_NAME}

echo "Creating/updating systemd service..."
sudo mv ./${SERVICE_FILE_NAME} /etc/systemd/system/${SERVICE_FILE_NAME}
sudo systemctl daemon-reload

if systemctl list-units --full -all | grep -Fq "${SERVICE_FILE_NAME}"
then
    sudo systemctl restart ${SERVICE_FILE_NAME}
    echo "Service ${SERVICE_FILE_NAME} udpated!"
else
    sudo systemctl enable ${SERVICE_FILE_NAME}
    sudo systemctl start ${SERVICE_FILE_NAME}
    echo "Service ${SERVICE_FILE_NAME} created!"
fi

echo "Generating NGINX service..."
sed "s|{PORT}|${INTERNAL_PORT}|g" ${NGINX_SERVICE_FILE}.template > ./${NGINX_SERVICE_FILE}
sudo mv ./${NGINX_SERVICE_FILE} /etc/nginx/sites-available/${NGINX_SERVICE_FILE}
if [ -L "/etc/nginx/sites-enabled/${NGINX_SERVICE_FILE}" ]
then
    echo "Symbolic link to NGINX service exists!"
else
    echo "Symbolic link to NGINX service created!"
    sudo ln -s /etc/nginx/sites-available/${NGINX_SERVICE_FILE} /etc/nginx/sites-enabled/
fi

echo "Starting/restarting NGINX service..."
sudo nginx -t
sudo systemctl restart nginx