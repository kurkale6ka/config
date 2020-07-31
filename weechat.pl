#! /usr/bin/env perl

use strict;
use warnings;
use feature qw/say/;
use File::Glob ':bsd_glob';
use Term::ANSIColor qw/:constants/;

# Clipboard
open my $cb, '|-', $^O eq 'darwin' ? 'pbcopy' : 'xclip'
   or die RED."$!".RESET, "\n";

# TLS
if (-e '/usr/local/etc/openssl/cert.pem') {
   # Mac OS
   say $cb '/set weechat.network.gnutls_ca_file "/usr/local/etc/openssl/cert.pem"';
} elsif (-e '/etc/ssl/certs/ca-certificates.crt') {
   # Linux
   say $cb '/set weechat.network.gnutls_ca_file "/etc/ssl/certs/ca-certificates.crt"';
} else {
   die "No valid certificates found\n";
}

# Certificates
print BOLD, "Certificates\n\n", RESET;

mkdir glob '~/.weechat/certs';
chdir glob '~/.weechat/certs' or die RED."$!".RESET, "\n";

foreach (qw/freenode oftc/)
{
   if (-e "$_.pem")
   {
      print RED, "Regenerate certificate for $_?: ", RESET;
      next unless <STDIN> =~ /y(es)?/in;
   }

   system "openssl req -x509 -new -newkey rsa:4096 -sha256 -days 1000 -nodes -out $_.pem -keyout $_.pem -subj '/C=GB'"
      or die RED."$!".RESET, "\n";

   print CYAN, 'fingerprint: ', RESET;

   system "openssl x509 -in $_.pem -outform der | sha1sum -b | cut -d' ' -f1"
      or die RED."$!".RESET, "\n";

   chmod 0600, "$_.pem";
}

# Copy IRC commands
while (<DATA>) {
   next unless m(^/);
   print $cb $_;
}

print BOLD, "\nPlease paste your configuration within weechat!\n\n", RESET;

print << 'MSG';
Freenode & OFTC:
/msg nickserv identify **********
/msg nickserv cert add

/save
MSG

__DATA__

# Servers
/server add freenode chat.freenode.net/7000 -ssl -autoconnect
/server add OFTC irc.oftc.net/6697 -ssl -autoconnect

/set irc.server.OFTC.ssl_cert %h/certs/oftc.pem
/set irc.server.freenode.ssl_cert %h/certs/freenode.pem

/set irc.server.freenode.sasl_mechanism external

/connect freenode OFTC

# Identity
/set irc.server.freenode.username kurkale6ka
/set irc.server.freenode.nicks kurkale6ka
/set irc.server.freenode.realname 'Dimitar Dimitrov'
/set irc.server.OFTC.username kurkale6ka
/set irc.server.OFTC.nicks kurkale6ka
/set irc.server.OFTC.realname 'Dimitar Dimitrov'

# Channels
/set irc.server.freenode.autojoin #git,##linux,#neovim,#perl,#postfix,#python,#vim,#zsh
/set irc.server.OFTC.autojoin #debian

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
/set weechat.bar.input.size 0
/set weechat.bar.title.color_bg 60
/set weechat.bar.status.items "buffer_number.,buffer_name,{buffer_nicklist_count}+buffer_filter,[buffer_plugin],[lag],completion,scroll"
/unset weechat.bar.input.items

# Spelling
/set spell.check.enabled on
/set spell.check.real_time on
/set spell.check.default_dict en

# Nicks
/bar hide nicklist
/alias add nicks /bar toggle nicklist
/set weechat.color.chat_nick_colors "cyan,magenta,green,brown,lightblue,default,lightcyan,lightmagenta,lightgreen,blue,31,35,38,40,49,63,70,80,92,99,112,126,130,138,142,148,160,162,167,169,174,176,178,184,186,210,212,215,247"

/key missing
/mouse enable
