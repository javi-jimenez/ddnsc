#!/bin/sh
# Copyright (C) 2013 Javi Jiménez, guifi.net Foundation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.

# A very basic Avahi Zeroconf services publishing tool 
# to publish services to DNS servers with some utilities added.

# Example reference domain name
#domain=ddns

TTL=86400
PRI=0
WEIGHT=5

tmpfile=`mktemp`

# A utility to test if the ip is IPv6 or not
# Can be improved calling libs or writing regex
ip_is_ipv6 () {
  # params: ip
  [ $# -eq 0 ] && echo "A utility to test if the given IP is an IPv6 or not.\nUsage: `basename $0` <ip>" && exit 1
#  ip=$1
  echo $1 | grep ":" 2>&1 > /dev/null
  val=`echo $?`
  return $val
}

# Get a list of host IPs
get_my_ips () {
  # This is a very basic script to try helping the final user
  # you can use avahi_publish_remote_address to publish the IPs of your choice.
  [ $# -ge 1 ] && echo "A utility to get the list of your IPs, excluding the loopback interface.\nUsage: `basename $0`" && exit 1
  ips=`ip -f inet addr show | grep inet|cut -c 10- | cut -f 1 -d ' '|grep -v "127.0." | cut -f 1 -d '/'`
  echo $ips
}

# Automatically publishes all the host pair IP-hostname to a remote server
# Useful when the local IPs or hostname change
avahi_publish_remote_myips () {
  [ $# -eq 0 ] && echo "Usage: `basename $0` <domain>" && exit 1
  domain=$1
  # IPs for inet except loopback
  # private IPs are taken too
  # TODO: ips=get_my_ips
  ips=`ip -f inet addr show | grep inet|cut -c 10- | cut -f 1 -d ' '|grep -v "127.0." | cut -f 1 -d '/'`
  for var in $ips ; do
    avahi_publish_remote_address `hostname` $ips $domain
  done
}

# Publish addesses and hostname to the remote server
# The hostname and address is given manually in command line
avahi_publish_remote_address () {
  # Publish address for hostname
  [ $# -eq 0 ] && echo "Usage: `basename $0` <hostname> <address> [<domain>]" && exit 1
  hostname=$1
  address=$2
  [ $# -eq 3 ] && domain=$3 && echo "zone $domain" >> $tmpfile
  # DEBUG: echo "name=$name address=$address domain=$domain"
  # TODO: Have we to delete the previous registers?
  # For the development phase, we don't delete the previous registers.
  #echo "update delete $name.$domain A" >> $tmpfile
  #echo "update delete $name.$domain AAAA" >> $tmpfile
  if ip_is_ipv6 $address ; then
    echo "update add $hostname.$domain $TTL IN AAAA $address" >> $tmpfile
    echo "send" >> $tmpfile
  else
    echo "update add $hostname.$domain $TTL IN A $address" >> $tmpfile
    echo "send" >> $tmpfile
  fi
  do_nsupdate
}

# Publish a service to a remote server with a name, a type for the service,
# and with a port for the service, optionally a TXT-RECORD can be given
avahi_publish_remote_service () {
  [ $# -eq 0 ] && echo "Usage: `basename $0` <name> <type> <port> <domain> [<txt-record>]" && exit 1
  # publish requirements for service and service with domain name
name=$1
type=$2
port=$3
domain=$4
#txtrecord=$5 # used later as $5
# TODO: `hostname`
  echo "zone $domain" > $tmpfile
  echo "update add _services._dns-sd._udp.$domain $TTL PTR $type.$domain" >> $tmpfile
  echo "send" >> $tmpfile
  echo "update add $name.$type.$domain $TTL SRV $PRI $WEIGHT $port `hostname`.$domain." >> $tmpfile
  echo "send" >> $tmpfile
  echo "update add $type.$domain $TTL PTR $name.$type.$domain" >> $tmpfile
  echo "send" >> $tmpfile
  # txtrecord not empty
  if [ $# -eq 5 ] ; then
    # echo "update add $type.$domain $TTL TXT $5" >> $tmpfile
    echo "update add $name.$type.$domain $TTL TXT $5" >> $tmpfile
    echo "send" >> $tmpfile
  fi
  do_nsupdate
  echo "Remember to publish your ip address/es (IPv4, IPv6) for the name '$name' which will be visible pointing to your services in the remote server with the command './avahi_publish_remote_address'. If you want to automatically publish ALL your IPs to remote, you can run the command 'avahi_publish_remote_myips' without parameters."
}

# Run the update which is stored in a temporary file
do_nsupdate (){
  echo $tmpfile
  cat $tmpfile
  nsupdate -v $tmpfile
}

# Creates the auto_links giving the user new functionallity from the
# command line. Creates link files to this script.
make_auto_links (){
  # "() {" are     published functions of this script.
  # "(){"  are not published functions of this script.
  thisfile=`basename $0`
  for var in `cat $thisfile | grep "() {" | cut -f 1 -d ' '` ; do
    ln -s $thisfile $var 2>/dev/null 
  done
}

# If a link is used, run the proper function, else give info about 
# how to work with this script and functions.
if [ -L `basename $0` ] ; then
  `basename $0` $* 
else
  echo "Usage: Please use the created links to `basename $0` in this directory to use the functionality. If this is your first run, some scripts have been created in this directory for you." && { make_auto_links ; exit 1 ; }
fi

