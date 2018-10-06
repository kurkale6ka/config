#! /usr/bin/env bash

cb_file="$(mktemp)"

# TLS
# Mac OS
if [[ -r /usr/local/etc/openssl/cert.pem ]]
then
   echo '/set weechat.network.gnutls_ca_file "/usr/local/etc/openssl/cert.pem"' > "$cb_file"
# Linux
elif [[ -r /etc/ssl/certs/ca-certificates.crt ]]
then
   echo '/set weechat.network.gnutls_ca_file "/etc/ssl/certs/ca-certificates.crt"' > "$cb_file"
else
   echo 'No valid certificates found' 1>&2
   rm "$cb_file"
   exit 1
fi

# OFTC certificate
echo 'Generating certificate for authentication on OFTC...'
mkdir -p ~/.weechat/certs
if cd ~/.weechat/certs
then
   openssl req -nodes -newkey rsa:2048 -keyout nick.key -x509 -days 3650 -out nick.cert
   openssl x509 -in nick.cert -noout -fingerprint
   cat nick.cert nick.key > nick.pem
   chmod 400 nick.*
fi

cat >> "$cb_file" << 'COPY'

# Servers
/server add freenode chat.freenode.net/7000 -ssl -autoconnect
/server add OFTC irc.oftc.net/6697 -ssl -autoconnect

/set irc.server.OFTC.ssl_cert %h/certs/nick.pem

/connect freenode OFTC

# Identity
/set irc.server.freenode.username kurkale6ka
/set irc.server.freenode.nicks kurkale6ka
/set irc.server.freenode.realname 'Dimitar Dimitrov'
/set irc.server.OFTC.username kurkale6ka
/set irc.server.OFTC.nicks kurkale6ka
/set irc.server.OFTC.realname 'Dimitar Dimitrov'

# Channels
/set irc.server.freenode.autojoin #git,##linux,#neovim,#vim,#zsh,#python,#postfix
/set irc.server.OFTC.autojoin #debian,#awesome

# Filters
/filter add irc_smart * irc_smart_filter *
/filter add irc_join_names * irc_366 *
/filter add irc_join_topic_date * irc_332,irc_333 *

# irc
/set irc.look.part_closes_buffer on
/set irc.look.smart_filter on

# look
/set weechat.look.mouse on
/set weechat.look.buffer_time_format "%H${color:3}:${color:245}%M"
/set weechat.look.prefix_align_max 11
/set weechat.look.save_config_on_exit off
/set weechat.look.align_multiline_words on
/set weechat.look.prefix_suffix "│"
/set weechat.look.read_marker_string "─"
/set weechat.look.item_buffer_filter "•"
/set weechat.look.bar_more_down "▼"
/set weechat.look.bar_more_left "◀"
/set weechat.look.bar_more_right "▶"
/set weechat.look.bar_more_up "▲"

# Plugins
# /script install lnotify.py (requires notify-send)
# /script install urlserver.py
# /script install buffer_autoset.py histman.py

# Bars (...wait for plugins to finish installing)
/set weechat.bar.buffers.size_max 11
/set weechat.bar.input.size 0
/set weechat.bar.title.color_bg 60
/set weechat.bar.status.items "buffer_number.,buffer_name,{buffer_nicklist_count}+buffer_filter,[buffer_plugin],[lag],completion,scroll"
/unset weechat.bar.input.items

# Spelling
/set aspell.check.enabled on
/set aspell.check.real_time on
/set aspell.check.default_dict en

# Nicks
/bar hide nicklist
/alias add nicks /bar toggle nicklist
/set weechat.color.chat_nick_colors "cyan,magenta,green,brown,lightblue,default,lightcyan,lightmagenta,lightgreen,blue,31,35,38,40,49,63,70,80,92,99,112,126,130,138,142,148,160,162,167,169,174,176,178,184,186,210,212,215,247"

/key missing
/mouse enable

/set irc.server.freenode.sasl_username kurkale6ka
COPY

# Copy commands to clipboard
grep -v '^#\|^$' "$cb_file" | xclip

cat << 'MSG'

Freenode
/set irc.server.freenode.sasl_password **********

OFTC
/msg nickserv identify **********
/msg nickserv cert add

/save
MSG

rm "$cb_file"
