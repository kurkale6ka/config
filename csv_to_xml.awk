#! /usr/bin/gawk -f

# Usage:
#     1 - ./brand.awk line=<start line> data.csv > data.xml
# ---------------------------------------------------------

function tag_print(indent, tag, value, nb_lines)
{
    # Empty value => empty tag
    if (value ~ /^\s*$/)
    {
        res = indent "<" tag "/>"
    }
    # Short content => one line
    else if (nb_lines == 1)
    {
        res = indent "<" tag "> " value " </" tag ">"
    }
    # Long content => several lines
    else
    {
        res =     indent "<"  tag   ">\n"
        res = res indent      value "\n"
        res = res indent "</" tag   ">"
    }

    print res
}

BEGIN {

    if (ARGV[1] !~ "line") {

        print "Usage: ./brand.awk line=<start line> data.csv > data.xml"
        exit
    }

    # Field separator
    FS="~"

    print "<?xml version='1.0' encoding='utf-8'?>\n"
    print "<content>\n"
}

{
    # Number of fields: only parse records containing data
    if (NF != 0 && NR >= line)
    {
        print "\t<!-- Record number " NR - line + 1 " -->"

        tag_print("\t", "title", $15, 1)

        sys_date="date"; sys_date | getline the_date; close(sys_date)
        print "<updated>" the_date "</updated>"

        print "\t<html>"
        tag_print("\t\t", "title", $19, 1)
        print "\t</html>"

        tag_print("\t", "owner", $18, 1)

        print "\t<promo>"

        if (match($33, /F[[:digit:]]+/, msg))
        {
            tag_print("\t\t", "messageboard", msg[0], 1)
        }
        else
        {
            print "\t\t<messageboard/>"
        }

        print "\t</promo>"

        print "\t<foldeez>"

        tag_print("\t\t", "instructions", $34, 2)

        print "\t</foldeez>\n"
    }
}

END {

    if (ARGV[1] ~ "line") {

        print "</content>"
    }
}
