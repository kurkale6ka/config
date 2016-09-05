# desertex theme

%sh{

#zentext="rgb:efefef"
#zenstorageClass="rgb:c3bf9f+b"
comment='rgb:7ccd7c+i'
constant='rgb:fa8072'
number=$constant
#zenspecial="rgb:cfbfaf"
function='rgb:87ceeb'
statement='rgb:eedc82'
keyword=$statement
identifier='rgb:87ceeb'
#zentype="rgb:dfdfbf"
string=$constant
#zenexception="rgb:c3bf9f+b"
#zenmatching="rgb:3f3f3f,rgb:8cd0d3"
#zenpadding="rgb:f0dfaf,rgb:343434+b"

cat << FACES

# Code
face value $constant
#face type ${zentype}
face identifier $identifier
face string $string
#face error ${zenexception}
face keyword $keyword
face operator $function
face attribute $statement
face comment $comment
#face meta ${zenspecial}

# Markup
face title $keyword
face header $constant
#face bold ${zenstorageClass}
face italic $function
face mono $number
face block $statement
face link $string
face bullet $identifier
#face list ${zentype}

# Builtin
# fg,bg+attributes
face Default 'default,rgb:262626'
# face PrimarySelection 'default,rgb:373b41'
# face SecondarySelection 'rgb:605958,rgb:373b41'
face PrimarySelection white,blue
face SecondarySelection black,blue
face PrimaryCursor black,white
face SecondaryCursor black,white
face LineNumbers 'rgb:605958'
face LineNumberCursor 'yellow,default+b'

# Bottom menu:
# text + background
face MenuBackground 'black,rgb:c2bfa5+b'
# selected entry in the menu
face MenuForeground 'rgb:f0a0c0,rgb:302028'

face MenuInfo rgb:cc9393
face Information black,yellow
face Error default,red
face StatusLine 'cyan,default'
face StatusLineMode $comment
#face StatusLineInfo ${zenspecial}
face StatusLineValue $number
face StatusCursor black,cyan
face Prompt blue
face MatchingChar default+b
#face BufferPadding ${zenpadding}

FACES
}
