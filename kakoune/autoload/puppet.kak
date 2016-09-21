# Puppet: reserved words and acceptable names
# https://docs.puppet.com/puppet/latest/reference/lang_reserved.html

hook global BufCreate .*\.pp %{
    set buffer mimetype ''
    set buffer filetype puppet
}

# Extra faces
face function  identifier
face resource  attribute
face noderegex 'rgb:ffa54f'
face pkeyword  'rgb:ee799f'
face parens    'rgb:76eec6'
face cname     'rgb:ffa54f'

addhl -group / regions -default code puppet \
    double_string %{(?<!\\)(\\\\)*\K"} %{(?<!\\)(\\\\)*"} '' \
    single_string %{(?<!\\)(\\\\)*\K'} %{'} '' \
    comment '(?<!\$)#' '$' ''

addhl -group /puppet/double_string fill string
addhl -group /puppet/single_string fill string

# Variables inside ""s
addhl -group /puppet/double_string regex \$(\w+|\{.+?\}) 0:identifier

addhl -group /puppet/comment fill comment

# class/define
addhl -group /puppet/code regex [a-z][a-z0-9_]*(?=\s*(?:{|$)) 0:pkeyword
addhl -group /puppet/code regex ([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)*(?=\s*(?:{|$)) 0:pkeyword
addhl -group /puppet/code regex (?:class|define)\s+\K[a-z][a-z0-9_]* 0:cname
addhl -group /puppet/code regex (?:class|define)\s+\K([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)* 0:cname

%sh[
# Grammar
booleans='false|true'
operators='and|in|or'
keywords='import|case|class|default|define|else|elsif|function|if|inherits|node|unless'
reserved='attr|private|type|application|consumes|produces|environment|undef'

types='[aA]ny|[aA]rray|[bB]oolean|[cC]atalog[eE]ntry|[cC]lass|[cC]ollection'
types="$types|[cC]allable|[dD]ata|[dD]efault|[eE]num|[fF]loat|[hH]ash|[iI]nteger"
types="$types|[nN]umeric|[oO]ptional|[pP]attern|[rR]esource|[rR]untime|[sS]calar"
types="$types|[sS]tring|[sS]truct|[tT]uple|[tT]ype|[uU]ndef|[vV]ariant"

resources='[aA]ugeas|[cC]omputer|[cC]ron|[eE]xec|[fF]ile|[fF]ilebucket|[gG]roup'
resources="$resources|[hH]ost|[iI]nterface|[kK]5login|[mM]acauthorization"
resources="$resources|[mM]ailalias|[mM]aillist|[mM]cx|[mM]ount|[nN]agios_command"
resources="$resources|[nN]agios_contact|[nN]agios_contactgroup|[nN]agios_host"
resources="$resources|[nN]agios_hostdependency|[nN]agios_hostescalation"
resources="$resources|[nN]agios_hostextinfo|[nN]agios_hostgroup|[nN]agios_service"
resources="$resources|[nN]agios_servicedependency|[nN]agios_serviceescalation"
resources="$resources|[nN]agios_serviceextinfo|[nN]agios_servicegroup"
resources="$resources|[nN]agios_timeperiod|[nN]otify|[pP]ackage|[rR]esources"
resources="$resources|[rR]outer|[sS]chedule|[sS]cheduled_task|[sS]elboolean"
resources="$resources|[sS]elmodule|[sS]ervice|[sS]sh_authorized_key|[sS]shkey"
resources="$resources|[sS]tage|[tT]idy|[uU]ser|[vV]lan|[yY]umrepo"
resources="$resources|[zZ]fs|[zZ]one|[zZ]pool"

functions='alert|assert_type|contain|create_resources|crit|debug|defined|dig'
functions="$functions|digest|each|emerg|epp|err|fail|file|filter|fqdn_rand"
functions="$functions|generate|hiera|hiera_array|hiera_hash|hiera_include"
functions="$functions|include|info|inline_epp|inline_template|lest|lookup"
functions="$functions|map|match|md5|new|notice|realize|reduce|regsubst"
functions="$functions|require|reverse_each|scanf|sha1|shellquote|slice|split"
functions="$functions|sprintf|step|tag|tagged|template|type|versioncmp|warning|with"

# Add the language's grammar to the static completion list
printf %s\\n "hook global WinSetOption filetype=puppet %{
    set window static_words '${keywords}'
}" | tr '|' ':'

# Highlight keywords
echo "addhl -group /puppet/code regex \b($keywords)\b 0:pkeyword"
echo "addhl -group /puppet/code regex (?:^|\s+)\K($resources)(?=\s*\{) 0:resource"
echo "addhl -group /puppet/code regex \b($functions)(?!\s*\{) 0:function"
echo "addhl -group /puppet/code regex \b($booleans)\b 0:red"
echo "addhl -group /puppet/code regex \b($operators)\b 0:red"
echo "addhl -group /puppet/code regex \b($reserved)\b 0:red"
echo "addhl -group /puppet/code regex \b($types)\b 0:red"
]

# Parens
addhl -group /puppet/code regex (?<!=)[[\]()<>{}] 0:parens

# node regex
addhl -group /puppet/code regex ^\h*node\h+\K/.*?/ 0:noderegex

# Resource attributes
addhl -group /puppet/code regex \S+(?=\s*=>) 0:attribute

# Variables, short and qualified
addhl -group /puppet/code regex \$[a-z0-9_][a-zA-Z0-9_]* 0:identifier
addhl -group /puppet/code regex \$([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)*::[a-z0-9_][a-zA-Z0-9_]* 0:identifier

hook global WinSetOption filetype=puppet %{ addhl ref puppet }
hook global WinSetOption filetype=(?!puppet).* %{ rmhl puppet }
