#!/bin/bash
BRed='\033[1;31m'
BGreen='\033[1;32m'
BYellow='\033[1;33m'
Color_Off='\033[0m'

VERBOSE=0
[[ -n $1 && $1 = "-v" ]] && VERBOSE=1

verbose_out() {
    echo -ne "${BRed}Command: ${Color_Off}"
    echo "$1"
    echo -ne "${BRed}Output: ${Color_Off}"
    echo "$2"
    sleep 4
}

pretty_cmd_out() {
    printf "%-60s" "$1..."
    shift
    if CMDOUTPUT=$(eval "$*" 2>&1); then
        echo -e "[ ${BGreen}OK${Color_Off} ]"
        [ $VERBOSE -eq 1 ] && verbose_out "$*" "$CMDOUTPUT"
    else
        echo -e "[ ${BRed}FAILED${Color_Off} ]"
        verbose_out "$*" "$CMDOUTPUT"
        exit 1
    fi
}

pretty_cmd_out_pass() {
    printf "%-60s" "$1..."
    shift
    if CMDOUTPUT=$(eval "$*" 2>&1); then
        echo -e "[ ${BGreen}OK${Color_Off} ]"
        [ $VERBOSE -eq 1 ] && verbose_out "$*" "$CMDOUTPUT"
    else
        echo -e "[ ${BYellow}WARN${Color_Off} ]"
        verbose_out "$*" "$CMDOUTPUT"
    fi

}

cd /vagrant/demo
pretty_cmd_out "Starting vault" docker-compose up -d vault
pretty_cmd_out_pass "Creating vault pki mount" vault mount pki
pretty_cmd_out "Tuning vault pki mount" vault mount-tune -max-lease-ttl=87600h pki
pretty_cmd_out "Configuring vault pki mount" "vault mount-tune -max-lease-ttl=87600h pki && vault write pki/config/urls issuing_certificates='http://vault.pki-demo.info:8200/v1/pki/ca' crl_distribution_points='http://vault.pki-demo.info:8200/v1/pki/crl'"
pretty_cmd_out "Generating intermediate CA to be signed by root ca" "vault write -field=csr pki/intermediate/generate/internal common_name=vault.pki-demo.info alt_names=vault key_bits=4096 | tee /etc/myca/vault.csr"
echo "csr saved to /etc/myca/vault.csr. Hit enter once key is signed"
read
pretty_cmd_out "Uploading signed CA certificate" vault write pki/intermediate/set-signed certificate=@/etc/myca/certs/vault.crt
pretty_cmd_out "Setting up role for server certificates" vault write pki/roles/pki-demo allow_subdomains=true allowed_domains=pki-demo.info client_flag=false max_ttl=720h ttl=720h
pretty_cmd_out "Setting up role for VPN server certificates" vault write pki/roles/vpn-server allow_subdomains=true allowed_domains=pki-demo.info client_flag=false max_ttl=2160h ttl=2160h
pretty_cmd_out "Setting up role for VPN client certificates" vault write pki/roles/vpn-client allow_subdomains=false allow_bare_domains=true allowed_domains=pki-demo.info client_flag=true server_flag=false email_protection_flag=true max_ttl=2160h ttl=2160h
