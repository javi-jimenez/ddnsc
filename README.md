Avahi Publish Remote (Distributed DNS Cache, DDNSC)
===================================================

Authors: Javi Jiménez, Roger Baig, Pau Escrich (guifi.net Foundation), Henning Rogge, Dan Staples, Jonathan"storm" and Saverio Proto.

Part of the ["Distributed DNS Cache" (DDNSC)] [ddnsc] project from [Battlemesh v6] [wbmv6], due to the talk ["Automated Sharing and Location of Services"] [avahitalkwbmv6] and the communicated need to me of building a Cloud of Services for the guifi.net Community Network, with more than 20.000 nodes.

In the first release of this script we use Bind, which provides the RFC2136 mechanism for remotely update the DNS registers.

In next releases we want to use dnsmasq, at the moment there are no positive results using RFC2136 mechanisms. Updating files adding services don't work in dnsmasq at the moment. Adding host names updating files in dnsmasq works.

We try to use as many as possible standards and already existing tools for the project. We don't try to reinvent the wheel.

*This is an experimental script in its first release.*

Requirements
------------

- Client:
  - avahi-utils
  - dnsutils

- Server:
  - bind

We suppouse that:
- the remote domain is *ddns*, and is configured as in the Server section
- the network is not a broadcast domain
- there is/are router/s between the nodes of the network

Usage
-----

In the next sections we describe the configuration or steps to set up the client/s and server/s.

### Client

Download the `avahi-publish-remote.sh` script.

Configure your `/etc/resolv.conf` to point to the remote DNS server, configured as in the Server section.

Give execute permissions to the script or precede always your commands with the command `sh` writing for example `sh thisscriptname` to call the files.

Execute your downloaded script to automatically create the links which adds the functionality to the project. Ex.: `./avahi-publish-remote.sh` and the scripts with the functionality will be created for you.

Publish automatically your IP address/es and hostname to allow your host to be available in the remote service repository server: `avahi_publish_myips_remote ddns`, ddns is the domain in which you want to publish your services, Avahi uses the domain .local for local services.

Publish services to the remote service reposiroty server: `./avahi_publish_remote_service peterssh _ssh._tcp 22 ddns`. This is similar to avahi-publish-service, with this you are publishing the service ssh in the port 22 to the domain ddns.


enjoy!

### Server

The server is a normal `bind` server configured with a zone called `ddns` and with the zone parameter `allow-update { any; };`. You can filter with acl if you want. The user has to be allowed to publish it's own services, she doesn't need authorization from anyone.

The server can rely on the usual DNS upstream servers for the rest of domains.

### Checking the steps

To browse services from any client configured to use the Server (in /etc/resolv.conf) you can for example look for SSH servers in the remote DNS server, you can do: `avahi-browse -d ddns _ssh._tcp` (standard Avahi utils package). For HTTP servers you can change *ssh* for *http*, and for FTP change it with *ftp*, the available services are in the */etc/services* file of your system.

To get a complete list of services in the DNS server you can do: `avahi-browse -d ddns -a`, take care, can be too long.

If you want to resolve your own hostname in the remote DNS server, you can for example look for your hostname which is called `ahost` with the usual command `host ahost.ddns` and you have to get the IP address of your host called `ahost` in the domain `.ddns`.

Another interesting tool to test the DNS is `dig`.

### Improving searchs

You can add to the begin of `resolv.conf` file the `search ddns` to look for hosts directly in the domain `.ddns`, you can then do `host ahost` and the system will look for your host `ahost` in the domain `.ddns`. At the moment you have to continue specifying the domain when using the `avahi-publish-remote.sh` tools.

Distribute DNS servers
----------------------

For distributing the DNS servers we can announce an (easy) anycast route to the DNS server. Later we can replicate the DNS servers with one or more servers for zone.

Applications
------------

Share, Publish and enjoy services using Avahi, DDNS and Zeroconf standards allowing the services to be present outside the Broadcast Domain in Linux.

To form a Network of Services (Cloud) inside Community Networks, avoiding the restrictions of local Avahi deployment.

That's all
----------

In the first stage of the "Distributed DNS Cache" project we talked about the use of `dnsmasq` and anycast addresses, this one for the DNS servers in the zones.

Always the problem is that the scalability is ~1000 nodes.

Following the RFC2136 we made Avahi capable of publishing services to a remote DNS server.

In the next stages we can use `dnsmasq` and load-balancing. We think about the DDNSC document which says to use hashing for the services.

References
----------

[ddnsc]: https://docs.google.com/document/d/1lW1jH4yjf2W5HlBi0a6vM1rXi7fnfJAlcbE-idDlcOw/ "Distributed DNS Cache (DDNSC)"
[wbmv6]: http://battlemesh.org/BattleMeshV6/ "Battlemesh v6"
[avahitalkwbmv6]: http://battlemesh.org/BattleMeshV6/Agenda?action=AttachFile&do=view&target=LT01_automated-share-and-locate-services.pdf "Automated Sharing and Location of Services"
