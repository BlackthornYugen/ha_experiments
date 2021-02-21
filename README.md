# Failover round robin

```
./create_ca_and_ee.sh # Make some keys for mutual auth
./create_ha.sh        # Make some haproxy instances and test config
```

# Test

```
do curl --cacert tls/RootCA.pem --cert tls/client${i}.pem "https://localhost:$((443 + i))/headers" --silent --fail --show-error ; done | jq '.headers' -r
```

```
{
  "Accept": "*/*",
  "Connection": "close",
  "Forwarded-Proto": "https,https,https,https,https,https,https,https,https",
  "Haproxy0-Date": "21/Feb/2021:16:40:06.705,21/Feb/2021:16:40:06.797,21/Feb/2021:16:40:06.897",
  "Haproxy1-Date": "21/Feb/2021:16:40:06.729,21/Feb/2021:16:40:06.823",
  "Haproxy2-Date": "21/Feb/2021:16:40:06.752,21/Feb/2021:16:40:06.848",
  "Haproxy3-Date": "21/Feb/2021:16:40:06.774,21/Feb/2021:16:40:06.873",
  "Host": "localhost",
  "Tls-Client-Cn": "client0.local,haproxy0.local,haproxy1.local,haproxy2.local,haproxy3.local,haproxy0.local,haproxy1.local,haproxy2.local,haproxy3.local",
  "User-Agent": "curl/7.68.0"
}
{
  "Accept": "*/*",
  "Connection": "close",
  "Forwarded-Proto": "https,https,https,https,https,https,https,https,https",
  "Haproxy0-Date": "21/Feb/2021:16:40:07.039,21/Feb/2021:16:40:07.139",
  "Haproxy1-Date": "21/Feb/2021:16:40:06.958,21/Feb/2021:16:40:07.063,21/Feb/2021:16:40:07.164",
  "Haproxy2-Date": "21/Feb/2021:16:40:06.988,21/Feb/2021:16:40:07.089",
  "Haproxy3-Date": "21/Feb/2021:16:40:07.014,21/Feb/2021:16:40:07.114",
  "Host": "localhost:444",
  "Tls-Client-Cn": "client1.local,haproxy1.local,haproxy2.local,haproxy3.local,haproxy0.local,haproxy1.local,haproxy2.local,haproxy3.local,haproxy0.local",
  "User-Agent": "curl/7.68.0"
}
{
  "Accept": "*/*",
  "Connection": "close",
  "Forwarded-Proto": "https,https,https,https,https,https,https,https,https",
  "Haproxy0-Date": "21/Feb/2021:16:40:07.282,21/Feb/2021:16:40:07.382",
  "Haproxy1-Date": "21/Feb/2021:16:40:07.308,21/Feb/2021:16:40:07.407",
  "Haproxy2-Date": "21/Feb/2021:16:40:07.231,21/Feb/2021:16:40:07.333,21/Feb/2021:16:40:07.432",
  "Haproxy3-Date": "21/Feb/2021:16:40:07.257,21/Feb/2021:16:40:07.357",
  "Host": "localhost:445",
  "Tls-Client-Cn": "client2.local,haproxy2.local,haproxy3.local,haproxy0.local,haproxy1.local,haproxy2.local,haproxy3.local,haproxy0.local,haproxy1.local",
  "User-Agent": "curl/7.68.0"
}
{
  "Accept": "*/*",
  "Connection": "close",
  "Forwarded-Proto": "https,https,https,https,https,https,https,https,https",
  "Haproxy0-Date": "21/Feb/2021:16:40:07.527,21/Feb/2021:16:40:07.624",
  "Haproxy1-Date": "21/Feb/2021:16:40:07.551,21/Feb/2021:16:40:07.646",
  "Haproxy2-Date": "21/Feb/2021:16:40:07.576,21/Feb/2021:16:40:07.669",
  "Haproxy3-Date": "21/Feb/2021:16:40:07.497,21/Feb/2021:16:40:07.600,21/Feb/2021:16:40:07.693",
  "Host": "localhost:446",
  "Tls-Client-Cn": "client3.local,haproxy3.local,haproxy0.local,haproxy1.local,haproxy2.local,haproxy3.local,haproxy0.local,haproxy1.local,haproxy2.local",
  "User-Agent": "curl/7.68.0"
}
```

# Break things

```bash
docker stop httpbin1 httpbin2 httpbin3
```

# Test again

```bash
for i in {0..3} ; do curl --cacert tls/RootCA.pem --cert tls/client${i}.pem "https://localhost:$((443 + i))/headers" --silent --fail --show-error ; done | jq '.headers' -r
```

```json
{
  "Accept": "*/*",
  "Connection": "close",
  "Forwarded-Proto": "https,https,https,https,https,https,https,https,https",
  "Haproxy0-Date": "21/Feb/2021:16:37:15.420,21/Feb/2021:16:37:15.514,21/Feb/2021:16:37:15.613",
  "Haproxy1-Date": "21/Feb/2021:16:37:15.444,21/Feb/2021:16:37:15.539",
  "Haproxy2-Date": "21/Feb/2021:16:37:15.467,21/Feb/2021:16:37:15.564",
  "Haproxy3-Date": "21/Feb/2021:16:37:15.490,21/Feb/2021:16:37:15.589",
  "Host": "localhost",
  "Tls-Client-Cn": "client0.local,haproxy0.local,haproxy1.local,haproxy2.local,haproxy3.local,haproxy0.local,haproxy1.local,haproxy2.local,haproxy3.local",
  "User-Agent": "curl/7.68.0"
}
{
  "Accept": "*/*",
  "Connection": "close",
  "Forwarded-Proto": "https,https,https,https,https,https,https,https,https,https,https",
  "Haproxy0-Date": "21/Feb/2021:16:37:15.730,21/Feb/2021:16:37:15.822",
  "Haproxy1-Date": "21/Feb/2021:16:37:15.658,21/Feb/2021:16:37:15.753,21/Feb/2021:16:37:15.848",
  "Haproxy2-Date": "21/Feb/2021:16:37:15.683,21/Feb/2021:16:37:15.775,21/Feb/2021:16:37:15.877",
  "Haproxy3-Date": "21/Feb/2021:16:37:15.706,21/Feb/2021:16:37:15.797,21/Feb/2021:16:37:15.901",
  "Host": "localhost:444",
  "Tls-Client-Cn": "client1.local,haproxy1.local,haproxy2.local,haproxy3.local,haproxy0.local,haproxy1.local,haproxy2.local,haproxy3.local,haproxy0.local,haproxy1.local,haproxy2.local",
  "User-Agent": "curl/7.68.0"
}
{
  "Accept": "*/*",
  "Connection": "close",
  "Forwarded-Proto": "https,https,https,https,https,https,https,https,https,https",
  "Haproxy0-Date": "21/Feb/2021:16:37:16.028,21/Feb/2021:16:37:16.134",
  "Haproxy1-Date": "21/Feb/2021:16:37:16.054,21/Feb/2021:16:37:16.158",
  "Haproxy2-Date": "21/Feb/2021:16:37:15.969,21/Feb/2021:16:37:16.079,21/Feb/2021:16:37:16.185",
  "Haproxy3-Date": "21/Feb/2021:16:37:15.998,21/Feb/2021:16:37:16.104,21/Feb/2021:16:37:16.215",
  "Host": "localhost:445",
  "Tls-Client-Cn": "client2.local,haproxy2.local,haproxy3.local,haproxy0.local,haproxy1.local,haproxy2.local,haproxy3.local,haproxy0.local,haproxy1.local,haproxy2.local",
  "User-Agent": "curl/7.68.0"
}
{
  "Accept": "*/*",
  "Connection": "close",
  "Forwarded-Proto": "https,https,https,https,https,https,https,https,https",
  "Haproxy0-Date": "21/Feb/2021:16:37:16.307,21/Feb/2021:16:37:16.413",
  "Haproxy1-Date": "21/Feb/2021:16:37:16.336,21/Feb/2021:16:37:16.438",
  "Haproxy2-Date": "21/Feb/2021:16:37:16.365,21/Feb/2021:16:37:16.463",
  "Haproxy3-Date": "21/Feb/2021:16:37:16.277,21/Feb/2021:16:37:16.388,21/Feb/2021:16:37:16.488",
  "Host": "localhost:446",
  "Tls-Client-Cn": "client3.local,haproxy3.local,haproxy0.local,haproxy1.local,haproxy2.local,haproxy3.local,haproxy0.local,haproxy1.local,haproxy2.local",
  "User-Agent": "curl/7.68.0"
}

```