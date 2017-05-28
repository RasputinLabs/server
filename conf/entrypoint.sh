#!/bin/bash
set -e
CMD=$1

echo "$CMD"

case "$CMD" in
  
  "start" )
    echo "=======> Replacing APP_HOST Environment Variable in nginx virtual host"
    envsubst \$APP_HOST < /tmp/conf/vhost.conf > /etc/nginx/conf.d/vhost.conf
    echo "=======> Starting Supervisor"
    exec /usr/bin/supervisord -c /etc/supervisord.conf
    ;;  

  * )
    exec $CMD ${@:2}
    ;;

esac