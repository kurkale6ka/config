# desertex theme

%sh{
    # fg,bg+attributes
    background='default,rgb:262626'
    #zenstatus="rgb:efdcbc,rgb:2a2a2a"
    #zencursor="default,rgb:7f9f7f"
    #zeninfo="rgb:cc9393,rgb:2a2a2a"
    menubg='rgb:000000,rgb:c2bfa5+b'
    menufg='rgb:f0a0c0,rgb:302028'
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

    echo "
        # then we map them to code
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

        # and markup
        face title $keyword
        face header $constant
        #face bold ${zenstorageClass}
        face italic $function
        face mono $number
        face block $statement
        face link $string
        face bullet $identifier
        #face list ${zentype}

        # and built in faces
        face Default $background
        face PrimarySelection 'default,rgb:373b41'
        face SecondarySelection 'rgb:605958,rgb:373b41'
        face PrimaryCursor black,white
        face SecondaryCursor black,white
        face LineNumbers 'rgb:605958'
        #face LineNumberCursor ${zenstatus}
        face MenuForeground $menufg
        face MenuBackground $menubg
        face MenuInfo rgb:cc9393
        #face Information ${zeninfo}
        face Error default,red
        #face StatusLine ${zenstatus}
        face StatusLineMode $comment
        #face StatusLineInfo ${zenspecial}
        face StatusLineValue $number
        #face StatusCursor ${zencursor}
        face Prompt yellow
        face MatchingChar default+b
        #face BufferPadding ${zenpadding}
    "
}
