#!/bin/bash
pki_role=$1
common_name=$2

JSON=$(vault write -format=json pki/issue/$pki_role common_name=$common_name format=pem)
echo $JSON | jq -r '.data.certificate' > "${common_name}.crt"
echo $JSON | jq -r '.data.issuing_ca' >> "${common_name}.crt"
echo $JSON | jq -r '.data.private_key' > "${common_name}.key"
cat ${common_name}.key ${common_name}.crt > ${common_name}_bundle.pem

