#! /usr/bin/env perl

open FILE, "$ENV{'HOME'}/.ssh/config" or die $!;

while (<FILE>) {

   if (/^host\s+(?:uk|rtc|oi|tla|tr|vms|build|penguin)(?!.*\*)/) {

      @host = split and print "$host[1]\n";

      # Make links
      # if (@ARGV) {
      #    # system "rm $ENV{'HOME'}/bin/$host[1]";
      #    system "ln -s $ENV{'HOME'}/bin/mssh $host[1]";
      #    next;
      # }

      # Check if vimx installed
      # print `ssh -T $host[1] 'apt-cache policy vim-X11'`;

      # print `ssh -T root\@$host[1] 'grep dimi /root/.inputrc'`;

      system "rsync --recursive --links --stats "               .
             "--exclude-from $ENV{'HOME'}/help/.rsync_exclude " .
             "$ENV{'HOME'}/config/ "                            .
             "$host[1]:/home/dimitar.dimitrov/config >/dev/null"
   }
}
