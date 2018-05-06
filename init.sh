#! /bin/bash -e

source devstack.rc

echo "Mount iso file"
mkdir -p $OS_PATH $TEMP_PATH
umount $OS_PATH || /bin/true
mount -o loop,rw -t iso9660 $OS_IMG $OS_PATH

echo "Start HTTP server"
if which nginx; then
    cp config/netboot.conf /etc/nginx/conf.d
    systemctl restart nginx
else
    start_simple_http_server
fi

echo "Link ssh private key"
ln -sf $(readlink -f config/devstack) $TEMP_PATH

start_simple_http_server() {
    cd $HOME_PATH
    echo -n "Start HTTP server"
    kill $(ps -ef |grep SimpleHTTPServer | awk '{ print $2 }') 2>/dev/null || /bin/true
    for i in {1..3}; do
        echo -n "." && sleep 1
    done
    python -m SimpleHTTPServer 8800 >/tmp/simplehttp.log 2>&1 &
    echo
}

cat >&1 <<EOF
HTTP server is deployed, you can run "./boot.sh <name>" to init vm or run ansible plays.
EOF
