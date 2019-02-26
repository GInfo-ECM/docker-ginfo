#!/bin/bash

reserved=12582912
availableMemory=$((1024 * $( (grep MemAvailable /proc/meminfo || grep MemTotal /proc/meminfo) | sed 's/[^0-9]//g' ) ))
if [ $availableMemory -le $(($reserved * 2)) ]; then
    echo "Not enough memory" >&2
    exit 1
fi
availableMemory=$(($availableMemory - $reserved))
rr_cache_size=$(($availableMemory / 3))
# Use roughly twice as much rrset cache memory as msg cache memory
msg_cache_size=$(($rr_cache_size / 2))
nproc=$(nproc)
export nproc
if [ "$nproc" -gt 1 ]; then
    threads=$((nproc - 1))
    # Calculate base 2 log of the number of processors
    nproc_log=$(perl -e 'printf "%5.5f\n", log($ENV{nproc})/log(2);')

    # Round the logarithm to an integer
    rounded_nproc_log="$(printf '%.*f\n' 0 "$nproc_log")"

    # Set *-slabs to a power of 2 close to the num-threads value.
    # This reduces lock contention.
    slabs=$(( 2 ** rounded_nproc_log ))
else
    threads=1
    slabs=4
fi

if [ ! -f /opt/unbound/etc/unbound/unbound.conf ]; then
    sed \
        -e "s/@MSG_CACHE_SIZE@/${msg_cache_size}/" \
        -e "s/@RR_CACHE_SIZE@/${rr_cache_size}/" \
        -e "s/@THREADS@/${threads}/" \
        -e "s/@SLABS@/${slabs}/" \
        > /opt/unbound/etc/unbound/unbound.conf << EOT
    server:
     verbosity: 1
     interface: 0.0.0.0@53
     access-control: 127.0.0.1/32 allow
     access-control: 192.168.0.0/16 allow
     access-control: 172.16.0.0/12 allow
     access-control: 10.0.0.0/8 allow
     log-queries: yes
     log-replies: yes
     log-servfail: yes
     do-ip4: yes
     do-ip6: no
     do-udp: yes
     do-tcp: yes
     logfile: /dev/null
     hide-identity: yes
     hide-version: yes
     harden-glue: yes
     use-caps-for-id: yes
     do-not-query-localhost: yes
    include: /opt/unbound/etc/unbound/a-records.conf
    forward-zone:
     name: "."
     forward-addr: 147.94.19.141
EOT
fi

mkdir -p /opt/unbound/etc/unbound/dev && \
cp -a /dev/random /dev/urandom /opt/unbound/etc/unbound/dev/

mkdir -p -m 700 /opt/unbound/etc/unbound/var && \
chown _unbound:_unbound /opt/unbound/etc/unbound/var && \
/opt/unbound/sbin/unbound-anchor -a /opt/unbound/etc/unbound/var/root.key

exec /opt/unbound/sbin/unbound -d -c /opt/unbound/etc/unbound/unbound.conf