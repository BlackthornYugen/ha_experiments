#!/usr/bin/env bash
set -e
CA_CRT_SUBJ="${CA_CRT_SUBJ:-/O=jskw/OU=mutual-auth/CN=jskw-test-root}"
CA_KEY_TYPE="${CA_KEY_TYPE:-ec:prime256v1.pem}"
EE_KEY_TYPE="${EE_KEY_TYPE:-${CA_KEY_TYPE}}"
openssl ecparam -name prime256v1 > prime256v1.pem
openssl req -x509 -nodes -new -sha256 -days 1024 -newkey "$CA_KEY_TYPE" -keyout RootCA.key.pem -out RootCA.pem -subj "$CA_CRT_SUBJ"

for i in {1..4} ; do for OU in client haproxy ; do
    echo $CLIENT
    CLIENT="${OU}${i}"
    EE_CRT_SUBJ="/O=jskw/OU=${OU}/CN=${CLIENT}.local"
    openssl req \
        -new \
        -nodes \
        -newkey "$EE_KEY_TYPE" \
        -keyout "${CLIENT}.key.pem" \
        -out "${CLIENT}.csr.pem" \
        -subj "$EE_CRT_SUBJ"
    openssl x509 -req -sha256 \
        -days 1024 \
        -in "${CLIENT}.csr.pem" \
        -CA RootCA.pem \
        -CAkey RootCA.key.pem \
        -CAcreateserial \
        -extfile <( cat <<_
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${CLIENT}.local
DNS.2 = localhost
IP.1 = 127.0.0.1
_
) \
        -out "${CLIENT}.crt.pem"

    cat "${CLIENT}.crt.pem" "${CLIENT}.key.pem" > "${CLIENT}.pem"
    echo ""
done
done

openssl verify -verbose -CAfile RootCA.pem RootCA.pem *.crt.pem
# Make a pem file that openssl s_server or haproxy or whatever could use
