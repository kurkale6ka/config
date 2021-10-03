#! /usr/bin/env perl

use v5.22;
use warnings;
use Term::ANSIColor ':constants';

# Clipboard
open my $CB, '|-', $^O eq 'darwin' ? 'pbcopy' : qw/xclip -selection clipboard/
   or die RED.$!.RESET, "\n";

# TLS
if (-e '/usr/local/etc/openssl/cert.pem') {
   # Mac OS
   say $CB '/set weechat.network.gnutls_ca_user "/usr/local/etc/openssl/cert.pem"';
}
elsif (-e '/etc/ssl/certs/ca-certificates.crt') {
   # Linux
   say $CB '/set weechat.network.gnutls_ca_user "/etc/ssl/certs/ca-certificates.crt"';
}
else {
   die RED.'No valid certificates found'.RESET, "\n";
}

# Certificates
say BOLD."Certificates\n".RESET;

mkdir "$ENV{XDG_CONFIG_HOME}/weechat",       0700;
mkdir "$ENV{XDG_CONFIG_HOME}/weechat/certs", 0700;
chdir "$ENV{XDG_CONFIG_HOME}/weechat/certs" or die RED.$!.RESET, "\n";

foreach (qw/libera oftc/)
{
   if (-e "$_.pem")
   {
      print RED."Regenerate certificate for $_?: ".RESET;
      next unless <STDIN> =~ /y(es)?/in;
   }

   system qw/openssl req -x509 -new -newkey rsa:4096 -sha256 -days 1095 -nodes -out/, "$_.pem", '-keyout', "$_.pem", qw(-subj /C=GB);
   $? == 0 or die RED.$!.RESET, "\n";

   print CYAN.'fingerprint: '.RESET;

   system "openssl x509 -in $_.pem -outform der | sha1sum -b | cut -d' ' -f1";
   $? == 0 or die RED.$!.RESET, "\n";

   chmod 0600, "$_.pem";
}

# Copy IRC commands
while (<DATA>)
{
   next unless m(^/);
   print $CB $_;
}

say BOLD."\nPlease paste your configuration within weechat!\n".RESET;

print <<'';
/save
/connect -all
/msg nickserv identify **********
/msg nickserv cert add <fingerprint>

__DATA__

# Servers
/server add libera irc.libera.chat/6697 -ssl -ssl_verify -autoconnect
/server add OFTC irc.oftc.net/6697 -ssl -ssl_verify -autoconnect

# Authentication
/set irc.server.libera.ssl_cert %h/certs/oftc.pem
/set irc.server.OFTC.ssl_cert %h/certs/oftc.pem

# Identity
/set irc.server.libera.username kurkale6ka
/set irc.server.libera.nicks kurkale6ka
/set irc.server.libera.realname 'Dimitar Dimitrov'
/set irc.server.OFTC.username kurkale6ka
/set irc.server.OFTC.nicks kurkale6ka
/set irc.server.OFTC.realname 'Dimitar Dimitrov'

# Channels
/set irc.server.libera.autojoin #git,##linux,#neovim,#perl,#postfix,#python,#vim,#zsh
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
