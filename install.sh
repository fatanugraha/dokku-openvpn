#!/usr/bin/env sh

dokku apps:create vpn
sudo -u dokku mkdir /var/lib/dokku/data/storage/vpn
dokku storage:mount vpn /var/lib/dokku/data/storage/vpn:/etc/openvpn

git remote add dokku self:vpn
git push dokku master

dokku run vpn ovpn_genconfig -u udp://yourvpn.example.org

# Generate self-signed certificate
# Remember the password!
dokku run vpn ovpn_initpki

# Tell dokku to bind a port and allow the container to perform network
# configuration operations
dokku docker-options:add vpn deploy --cap-add=NET_ADMIN
dokku docker-options:add vpn deploy -p 5000:1194/udp

# Tell dokku not to perform http health checks
dokku checks:disable vpn

# Tell dokku to not even try to proxy a udp service through nginx
dokku proxy:disable vpn

# Always restart the container on errror
dokku ps:set-restart-policy vpn always

# Scale up the vpn process
dokku ps:scale vpn vpn=1

# Generate client profile
dokku run vpn easyrsa build-client-full your-client-name nopass
