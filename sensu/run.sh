#!/bin/sh

TMPDIR=/etc/sensu/tmp confd -verbose -onetime -node "http://$ETCD_ADDR:4001" -prefix='/ops'

cat <<EOT >> /etc/confd/confd.toml
[confd]
confdir  = "/etc/confd"
etcd_nodes = [
  "http://$ETCD_ADDR:4001",
]
EOT

/usr/bin/supervisord
