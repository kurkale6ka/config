# ex: '-e SC2087'
decl str sh_options

decl -hidden line-flags sh_flags
decl -hidden str sh_errors

def sh-parse -params 0..1 -docstring 'Parse the contents of the current buffer with shellcheck' %{
    %sh{
        dir=$(mktemp -d -t kak-sh.XXXXXXXX)
        mkfifo "$dir"/fifo
        printf '%s\n' "eval -no-hooks write $dir/buf"

        printf '%s\n' "eval -draft %{
                  edit! -fifo $dir/fifo *sh-output*
                  set buffer filetype make
                  set buffer _make_current_error_line 0
                  hook -group fifo buffer BufCloseFifo .* %{
                      nop %sh{ rm -r '$dir' }
                      rmhooks buffer fifo
                  }
              }"

        { # do the parsing in the background and when ready send to the session

        shellcheck -fgcc ${kak_opt_sh_options} "$dir"/buf > "$dir"/stderr
        printf '%s\n' "eval -client $kak_client echo 'shellcheck parsing done'" | kak -p "$kak_session"

        # Update the gutter with errors and warnings: line3|{red}:line11|{yellow}
        flags=$(awk -F: '
                    /:[0-9]+:([0-9]+:)? (fatal )?error/ { print $2"|{red}█" }
                    /:[0-9]+:([0-9]+:)? (warning|note)/ { print $2"|{yellow}█" }
                ' "$dir"/stderr | paste -s -d ':')

        # 1,err1
        # 2,err2
        # ...
        errors=$(awk -F: '
                    /:[0-9]+:([0-9]+:)? ((fatal )?error|warning|note)/ { print $2","substr($4,2)":"$5 }
                 ' "$dir"/stderr | sort -n)

        cut -d: -f2- "$dir"/stderr | sed "s@^@$kak_bufname:@" > "$dir"/fifo

        printf '%s\n' "set 'buffer=${kak_buffile}' sh_flags %{$kak_timestamp:$flags}
                       set 'buffer=${kak_buffile}' sh_errors %{$errors}" | kak -p "$kak_session"

        } >/dev/null 2>&1 </dev/null &
    }
}

def -hidden sh-show-error-info %{ %sh{
    desc=$(printf '%s\n' "$kak_opt_sh_errors" | sed -ne "/^$kak_cursor_line,.*/ { s/^[[:digit:]]\+,//g; s/'/\\\\'/g; p }")
    if [ -n "$desc" ]; then
        printf '%s\n' "info -anchor $kak_cursor_line.$kak_cursor_column '$desc'"
    fi
}}

def sh-enable-diagnostics -docstring "Activate automatic diagnostics of the code by sh" %{
    addhl flag_lines default sh_flags
    hook window -group sh-diagnostics NormalIdle .* %{ sh-show-error-info }
    hook window -group sh-diagnostics WinSetOption ^sh_errors=.* %{ info; sh-show-error-info }
}

def sh-disable-diagnostics -docstring "Disable automatic diagnostics of the code" %{
    rmhl hlflags_sh_flags
    rmhooks window sh-diagnostics
}

def sh-diagnostics-next -docstring "Jump to the next line that contains an error" %{ %sh{
    printf '%s\n' "$kak_opt_sh_errors" | {
        line=-1
        first_line=-1
        while read -r line_content; do
            candidate="${line_content%%,*}"
            if [ -n "$candidate" ]
            then
                first_line=$(( first_line == -1 ? candidate : first_line ))
                line=$((candidate > kak_cursor_line && (candidate < line || line == -1) ? candidate : line ))
            fi
        done
        line=$((line == -1 ? first_line : line))
        if [ "$line" -ne -1 ]
        then
            printf '%s\n' "exec $line g"
        else
            echo 'echo -color Error no next sh diagnostic'
        fi
    }
}}
