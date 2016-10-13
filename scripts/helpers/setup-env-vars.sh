export VAULT_ADDR="http://127.0.0.1:8200"
TOKEN_LINE=$(grep "VAULT_TOKEN" /vagrant/demo/.env)
if [[ $? -gt 0 ]]; then
    export VAULT_TOKEN=$(uuidgen)
    echo "VAULT_TOKEN=${VAULT_TOKEN}" >> /vagrant/demo/.env
else
    export VAULT_TOKEN=$(echo $TOKEN_LINE | cut -d= -f 2)
fi