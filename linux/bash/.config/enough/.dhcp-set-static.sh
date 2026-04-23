# Configure static DHCP with nmcli
set-static-dhcp () {
    CONNECTION=$1
    ADDRESS=$2
    DNS=${3:-8.8.8.8 8.8.4.4}
    GATEWAY=${4:-192.168.1.254}

    sudo nmcli connection modify ${CONNECTION} ipv4.addresses ${ADDRESS}
    sudo nmcli connection modify ${CONNECTION} ipv4.dns "${DNS}"
    sudo nmcli connection modify ${CONNECTION} ipv4.gateway ${GATEWAY}
    sudo nmcli connection modify ${CONNECTION} ipv4.method manual

    echo "Successfully configured static DHCP for connection ${CONNECTION}!"
    echo "Reboot to make the changes effective."
}
