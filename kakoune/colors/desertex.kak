# desertex theme

%sh{

constant='rgb:fa8072'
function='rgb:87ceeb'
statement='rgb:eedc82'
keyword=$statement
identifier='rgb:87ceeb'
#zentype="rgb:dfdfbf"
string=$constant
#zenexception="rgb:c3bf9f+b"
#zenmatching="rgb:3f3f3f,rgb:8cd0d3"

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
face comment 'rgb:7ccd7c+i'

# #include <...>
face meta 'rgb:ee799f'

# Markup
face title $keyword
face header $constant
#face bold
face italic $function
#face mono
face block $statement
face link $string
face bullet $identifier
#face list ${zentype}

# Builtin
# fg,bg+attributes
face Default 'default,rgb:262626'

face PrimarySelection 'white,blue'
face SecondarySelection 'black,blue'

face PrimaryCursor 'black,white'
face SecondaryCursor 'black,white'

face LineNumbers 'rgb:605958'
face LineNumberCursor 'yellow,default+b'

# Bottom menu:
# text + background
face MenuBackground 'black,rgb:c2bfa5+b'
# selected entry in the menu
face MenuForeground 'rgb:f0a0c0,rgb:302028'

# completion menu info
face MenuInfo 'white,rgb:445599'

# assistant, [+]
face Information 'black,yellow'

face Error 'white,red'
face StatusLine 'cyan,default'

# Status line modes and prompts:
# insert, prompt, enter key...
face StatusLineMode 'rgb:ffd75f,default'

# 1 sel
face StatusLineInfo 'blue,default'

# param=value, reg=value. ex: "ey
face StatusLineValue 'green,default'
face StatusCursor 'black,cyan'

# :
face Prompt 'blue'

# (), {}
face MatchingChar 'cyan+b'

# EOF tildas (~)
face BufferPadding 'blue,default'

FACES
}
