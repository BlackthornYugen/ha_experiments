#!/usr/bin/env bash
set -e
function create_ha() {
    docker create --workdir /usr/local/etc/haproxy \
        --name "haproxy$1" \
        --env INSTANCE_NAME="haproxy$1" \
        --env UPSTREAM_INSTANCE_NAME="haproxy$2" \
        --net ha \
        --publish "$3":80 \
        --publish "$4":443 \
        -v ${PWD}:/usr/local/etc/haproxy \
        haproxytech/haproxy-alpine:2.0 \
        /bin/sh -c "sleep 5; sh -x /docker-entrypoint.sh haproxy -f /usr/local/etc/haproxy/haproxy.cfg"
}

echo "Remove old"
for i in {1..4} ; do
    docker stop "haproxy${i}"
    docker rm "haproxy${i}"
done

echo "Create new"
for i in {1..4} ; do
    create_ha "$i" "$(( i % 4  + 1))" "$(( i % 4  + 80 ))" "$(( i % 4  + 443 ))"
done

echo "Start containers"
for i in {1..4} ; do
    docker start "haproxy$i"
done

sleep 5;

for i in {1..4} ; do
    docker exec -it "haproxy${i}" ps -a
    curl \
        --cacert "tls/RootCA.pem" \
        --cert "tls/client${i}.pem" --silent --fail --show-error \
            "http://localhost:$((  i % 4  + 80  ))/get" \
            "https://localhost:$(( i % 4  + 443 ))/get" | jq
done