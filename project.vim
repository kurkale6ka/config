" All this information could just be stored in the .Session file?
if has('win32')

    source    D:/dev/org/.SessionWin.vim
    rviminfo! D:/dev/org/.viminfoWin

    set path+=D:/dev/org/**

    " set path+=Q:/org/dev/
    " set path+=Q:/org/redesign/
    set path+=Q:/org/stage/

    set tags+=D:/dev/org/tags_org

    let $CTRL = 'D:/dev/org/.../controllers'
    let $VIEW = 'D:/dev/org/.../views/scripts/'
    let $LIB  = 'D:/dev/org/.../lib/'

    let $DEV      = 'Q:/org/dev/'
    let $REDESIGN = 'Q:/org/redesign/'
    let $STAGE    = 'Q:/org/stage/'

else

    source    /mnt/.../org/.Session.vim
    rviminfo! /mnt/.../org/.viminfo

    " set path+=Q:/org/dev/
    " set path+=Q:/org/redesign/
    " set path+=Q:/org/stage/

    set path+=/mnt/.../org/**

    set tags+=/mnt/.../org/tags_org

    let $CTRL = '/mnt/.../org/controllers'
    let $VIEW = '/mnt/.../org/views/scripts/'
    let $LIB  = '/mnt/.../lib/'

    " let $DEV      = 'Q:/org/dev/'
    " let $REDESIGN = 'Q:/org/redesign/'
    " let $STAGE    = 'Q:/org/stage/'

endif
