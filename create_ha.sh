#!/usr/bin/env bash
set -e
DOCKER_NETWORK=ha
START_DELAY=5
HAPROXY_INSTANCES="$(echo {0..3})"

# Create a haproxy instance
# usage: create_ha <INSTANCE#> <UPSTREAM_TARGET#> <HTTP_PORT> <HTTPS_PORT>
function create_ha() {
    INSTANCE_NAME="haproxy${1}"
    docker stop "${INSTANCE_NAME}" && docker rm   "${INSTANCE_NAME}" || true
    docker create --workdir /usr/local/etc/haproxy \
        --name "${INSTANCE_NAME}" \
        --env INSTANCE_NAME="${INSTANCE_NAME}" \
        --env UPSTREAM_INSTANCE_NAME="haproxy$2" \
        --env HTTPBIN_PRIMARY="httpbin$((   (i + 0) % 4 ))" \
        --env HTTPBIN_SECONDARY="httpbin$(( (i + 1) % 4 ))" \
        --net ${DOCKER_NETWORK} \
        --publish "$3":80 \
        --publish "$4":443 \
        -v ${PWD}:/usr/local/etc/haproxy \
        haproxytech/haproxy-alpine:2.0 \
        /bin/sh -c "sleep ${START_DELAY}; sh -x /docker-entrypoint.sh haproxy -f /usr/local/etc/haproxy/haproxy.cfg"
}

# Create a python http echo tool
# https://kennethreitz.org/
# https://github.com/postmanlabs/httpbin
function start_httpbin() {
    INSTANCE_NAME="httpbin${1}"
    docker stop "${INSTANCE_NAME}" && docker rm   "${INSTANCE_NAME}" || true
    docker run -d --net ${DOCKER_NETWORK} --name "${INSTANCE_NAME}" docker.io/kennethreitz/httpbin:latest
}

echo -e "\nCreate containers"

for i in ${HAPROXY_INSTANCES} ; do
    start_httpbin "$i"
    create_ha "$i" "$(( (i + 1) % 4 ))" "$(( i % 4  + 80 ))" "$(( i % 4  + 443 ))"
done

echo -e "\nStart containers"
for i in ${HAPROXY_INSTANCES} ; do
    docker start "haproxy$i"
done

echo -e "\nWait \"$(( 1 + START_DELAY ))\" seconds for containers to start."
sleep $(( 1 + START_DELAY ));

for i in ${HAPROXY_INSTANCES} ; do
    sleep 0.2
    curl \
        --cacert "tls/RootCA.pem" \
        --cert "tls/client${i}.pem" --silent --fail --show-error \
            "http://localhost:$((  i % 4  + 80  ))/get" \
            "https://localhost:$(( i % 4  + 443 ))/get" | jq
done