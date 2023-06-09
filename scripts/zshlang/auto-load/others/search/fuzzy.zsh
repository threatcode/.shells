function h-grep-output-to-fz {
    # @exampleUsages [agfi:irc-sees], [agfi:nt-due-sees]
    ##
    : 'GLOBAL inputs: fzp_ug [ntsearch_lines_pattern_default]'
    : 'GLOBAL outputs: out, acceptor'
    unset out
    unset acceptor

    local query="${h_grep_output_to_fz_query}"
    local rtl="${h_grep_output_to_fz_rtl}"
    local hidden="${h_grep_output_to_fz_hidden:-nohidden}"
    local output_pattern="${h_grep_output_to_fz_pattern:-${ntsearch_lines_pattern_default}}"
    assert-args output_pattern @RET

    ##
    local ntom_mode
    local preview_header_lines="${h_grep_output_to_fz_preview_header_lines:-0}"
    # @toFuture/1401 [[https://github.com/junegunn/fzf/issues/2639][`~HEADER_LINES` in `--preview-window` should count input lines, not soft-wrapped lines · Issue #2639 · junegunn/fzf]]

    if (( preview_header_lines == 0 )) ; then
        # preview_header_lines=''
        preview_header_lines=',~3'
        ntom_mode=0
    else # this is better for scrolling, as the previous mode doesn't let us scroll up, but fzf can't center around the match reliably because of soft-wrapping.
        # https://github.com/junegunn/fzf/issues/2373 preview header
        preview_header_lines=",+{2}-/2,~${preview_header_lines}"
        ntom_mode=1
    fi
    ##

    ensure-array h_grep_output_to_fz_delim_opts
    local delim_opts=("${h_grep_output_to_fz_delim_opts[@]}")
    if [[ "${delim_opts[*]}" == 'rg' ]] || (( ${#delim_opts} == 0 )) ; then
        delim_opts=(--delimiter : --with-nth '1,3..' --nth '..') # nth only works on with-nth fields
    fi

    ensure-array h_grep_output_to_fz_opts
    local fzopts=("${h_grep_output_to_fz_opts[@]}")

    local dir_main="${h_grep_output_to_fz_dir_main}" dir_main_quoted
    if test -z "$dir_main" ; then
        dir_main_quoted="/"
    else
        dir_main_quoted="$(gq $dir_main)"
    fi

    local previewcode="${h_grep_output_to_fz_previewcode:-ntom}"
    if [[ "$previewcode" == cat ]] ; then
        if test -z "$dir_main" ; then
            previewcode="$FZF_CAT_PREVIEW"
        else
            previewcode="cat ${dir_main_quoted}/{1} || printf -- '${0}: error_919815'"
        fi
    elif [[ "$previewcode" == ntom ]] ; then
        local rtl_code=''
        if bool "$rtl" ; then
            rtl_code='| rtl_reshaper.dash' # very bad perf for large files
            # adding ` | rtl_reshaper.dash` works fine if RTL text is not colored, it seems. @todo1 It's best if ntom does the reshaping itself ...
        fi
        previewcode="ntom {1} {2} {s3..} ${dir_main_quoted} ${ntom_mode} ${rtl_code} || printf -- \"\n\n%s \" {}"
    fi

    fzopts+=(--bind 'ctrl-\:execute-silent(brishzq.zsh ntsearch-postprocess-h1 '"${dir_main_quoted} $(gq "$output_pattern")"' {f})') # '{}' puts the current line itself, '{f}' puts a file containing it; using silent.zsh does not seem to make any difference to the strange fzf bug that causes escape codes to be written to the query

    fz_empty=y fzp_dni=truncate fzp --preview-window "right,50%,wrap,${hidden}${preview_header_lines}" --preview "$previewcode[*]" --ansi "${delim_opts[@]}" "${fzopts[@]}" --print0 --expect=alt-enter "$query" | {
        acceptor=''
        if isI ; then
            read -d $'\0' -r acceptor
        fi
        # dvar acceptor

        out="$(cat)"
        if isI || test -z "$fzp_ug" ; then
            # fzp_ug doesn't output zero in non-interactive usage (because fzf is not invoked), so we don't need to break these.
            out=( "${(@0)out}" )
            out=( "${(@)out[1,-2]}" ) # remove empty last element that \0 causes
        else
            out=( "${(@f)out}" )
        fi
    } || {
        local ret=$? s="${(j.|.)pipestatus[@]}"
        ecerr "$0: failed last statement with: $s"
        return $ret
    }
}
