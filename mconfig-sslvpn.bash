#! /usr/bin/env bash
if grep -q '# hostname 10.100.201.45' ~/.ssh/config
then
   echo 'ssh config: switching to sslvpn mode!'
   command vim -nNX -u NONE -c 'g/switch/+s/\ze\%(hostname\|ProxyCommand\)/# /' \
                            -c 'g/switch/+2s/#\s\+\ze\%(hostname\|ProxyCommand\)' \
                            +wq ~/.ssh/config
else
   echo 'already in sslvpn mode!'
fi
