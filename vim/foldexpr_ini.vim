; Empty/blank lines: level 2, Lines not starting with [: level 1
; vim: set foldmethod=expr:
; vim: set foldexpr=getline(v\:lnum)=~'^\\s*;'||getline(v\:lnum)=~'^\\s*$'?2\:getline(v\:lnum)=~'^\\s*[^[]'?1\:0:
