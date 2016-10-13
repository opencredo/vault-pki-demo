#!/bin/bash
mkdir -m 0755 \
     /etc/myca \
     /etc/myca/private \
     /etc/myca/certs \
     /etc/myca/newcerts \
     /etc/myca/crl

cd /etc/myca
touch index.txt
echo '01' > serial
cp /vagrant/scripts/files/openssl.cnf ./openssl.my.cnf
chmod 0600 openssl.my.cnf
openssl req -config openssl.my.cnf -new -x509 -extensions v3_ca -keyout private/myca.key -out certs/myca.crt -days 3650
cp certs/myca.crt /usr/local/share/ca-certificates/
update-ca-certificates