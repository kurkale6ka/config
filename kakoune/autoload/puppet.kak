# Puppet: reserved words and acceptable names
# https://docs.puppet.com/puppet/latest/reference/lang_reserved.html

hook global BufCreate .*\.pp %{
    set buffer mimetype ''
    set buffer filetype puppet
}

# Extra faces
face function  identifier
face resource  'rgb:ffa54f'
face noderegex 'rgb:ffa54f'
face pkeyword  'rgb:ee799f'
face parens    'rgb:76eec6'
face cname     'rgb:ffa54f'
face constant  'rgb:5f5faf'

addhl -group / regions -default code puppet \
    cls_qstring  "class\h*{\h*\K'" "'" '' \
    cls_qqstring 'class\h*{\h*\K"' '"' '' \
    # must not be preceded by an odd number of backslashes
    double_string %{(?<!\\)(?:\\\\)*\K"} %{(?<!\\)(?:\\\\)*"} '' \
    single_string %{(?<!\\)(?:\\\\)*\K'} %{(?<!\\)(?:\\\\)*'} '' \
    comment '#' '$' ''

addhl -group /puppet/cls_qstring  fill pkeyword
addhl -group /puppet/cls_qqstring fill pkeyword

addhl -group /puppet/double_string fill string
addhl -group /puppet/single_string fill string

# Variables inside ""s
addhl -group /puppet/double_string regex \$(?:[a-z0-9_][a-zA-Z0-9_]*|\{.+?\}) 0:identifier
addhl -group /puppet/double_string regex \$([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)*::[a-z0-9_][a-zA-Z0-9_]* 0:identifier

addhl -group /puppet/comment fill comment

# my::define {...}
addhl -group /puppet/code regex ([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)*(?=\s*{) 0:pkeyword

# include my::class
addhl -group /puppet/code regex include\h+([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)* 0:pkeyword

# class/define ... {
addhl -group /puppet/code regex (?:class|define)\h+\K([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)* 0:cname

%sh[
# Grammar
types='[aA]ny|[aA]rray|[bB]oolean|[cC]atalog[eE]ntry|[cC]lass|[cC]ollection'
types="$types|[cC]allable|[dD]ata|[dD]efault|[eE]num|[fF]loat|[hH]ash|[iI]nteger"
types="$types|[nN]umeric|[oO]ptional|[pP]attern|[rR]esource|[rR]untime|[sS]calar"
types="$types|[sS]tring|[sS]truct|[tT]uple|[tT]ype|[uU]ndef|[vV]ariant"

resources='augeas|computer|cron|exec|file|filebucket|group'
resources="$resources|host|interface|k5login|macauthorization"
resources="$resources|mailalias|maillist|mcx|mount|nagios_command"
resources="$resources|nagios_contact|nagios_contactgroup|nagios_host"
resources="$resources|nagios_hostdependency|nagios_hostescalation"
resources="$resources|nagios_hostextinfo|nagios_hostgroup|nagios_service"
resources="$resources|nagios_servicedependency|nagios_serviceescalation"
resources="$resources|nagios_serviceextinfo|nagios_servicegroup"
resources="$resources|nagios_timeperiod|notify|package|resources"
resources="$resources|router|schedule|scheduled_task|selboolean"
resources="$resources|selmodule|service|ssh_authorized_key|sshkey"
resources="$resources|stage|tidy|user|vlan|yumrepo"
resources="$resources|zfs|zone|zpool"

functions='alert|assert_type|contain|create_resources|crit|debug|defined|dig'
functions="$functions|digest|each|emerg|epp|err|fail|file|filter|fqdn_rand"
functions="$functions|generate|hiera|hiera_array|hiera_hash|hiera_include"
functions="$functions|include|info|inline_epp|inline_template|lest|lookup"
functions="$functions|map|match|md5|new|notice|realize|reduce|regsubst"
functions="$functions|require|reverse_each|scanf|sha1|shellquote|slice|split"
functions="$functions|sprintf|step|tag|tagged|template|type|versioncmp|warning|with"

booleans='false|true'
operators='and|in|or'
attributes='present|absent|purged|latest|installed|running|stopped|(?:un)?mounted|role|configured|file|directory|link|on_failure'
keywords='import|case|class|default|define|else|elsif|function|if|inherits|node|unless'
reserved='attr|private|type|application|consumes|produces|environment|undef'

# Add the language's grammar to the static completion list
printf '%s\n' "hook global WinSetOption filetype=puppet %{
    set window static_words '$functions|$booleans|$attributes|$keywords'
}" | tr '|' ':'

cat << ADDHL
addhl -group /puppet/code regex \b($types)\b 0:constant
addhl -group /puppet/code regex (?:^|\h+)\K($resources)(?=\s*\{) 0:resource
addhl -group /puppet/code regex \b($functions)[\h(](?!\s*\{) 0:function
addhl -group /puppet/code regex \b($booleans)\b 0:constant
addhl -group /puppet/code regex \b($operators)\b 0:constant
addhl -group /puppet/code regex =>\h*\K($attributes)\b 0:constant
addhl -group /puppet/code regex \b($keywords)\b 0:pkeyword
addhl -group /puppet/code regex \b($reserved)\b 0:constant
ADDHL
]

# TODO: highlight as a function
# addhl -group /puppet/code regex class(?=\h*{\h*['"]) 0:function

# Resources in dependencies (ex: File[...] ~>)
addhl -group /puppet/code regex [A-Z][_a-z]+ 0:resource

# Digits
addhl -group /puppet/code regex \d+ 0:constant

# Parens + <<|...|>>
addhl -group /puppet/code regex [[\](){}]|<?<\||\|>>? 0:parens

# node regex
addhl -group /puppet/code regex ^\h*node\h+\K/.*?/ 0:noderegex

# Resource attributes
addhl -group /puppet/code regex \S+(?=\h*=>) 0:attribute

# /.../ in ifs or case switches
addhl -group /puppet/code regex /.*?/(?=\h*(?::\s*{|\h*=>))|[=!]~\h*?\K/.*?/(?=.*?{) 0:pkeyword

# Variables, short and qualified
addhl -group /puppet/code regex \$[a-z0-9_][a-zA-Z0-9_]* 0:identifier
addhl -group /puppet/code regex \$([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)*::[a-z0-9_][a-zA-Z0-9_]* 0:identifier

hook global WinSetOption filetype=puppet %{
    addhl ref puppet
    set buffer tabstop 2
    set buffer indentwidth 2
    hook window -group puppet-indent InsertChar \n _puppet-indent-on-newline
}

hook global WinSetOption filetype=(?!puppet).* %{
    rmhl puppet
    rmhooks window puppet-indent
}

def -hidden _puppet-indent-on-newline %[
    # indent after an opening brace
    try %[ exec -draft K <a-&> s\{\h*$<ret> j <a-gt> ]
]
