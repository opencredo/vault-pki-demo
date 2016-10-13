#!/bin/bash
cd /etc/myca
openssl ca -config openssl.my.cnf -days 3650 -notext -md sha512 -in vault.csr -out certs/vault.crt -extensions v3_intermediate_ca -policy policy_anything