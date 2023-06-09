##
isI && {
    source "$NIGHTDIR"/zshlang/widgets.zsh
    ##
    function precmd_pipestatus {
        # @duplicateCode/0043fdb53e9bf6f36a57e7570b22453b
        local r=$? ps=("${pipestatus[@]}") ps_p=("${pipestatus_preserved[@]}")
        if (( r != 0 )) ; then
            if (( r != 0 && ${#ps} == 1 && ${#ps_p} > 1 )) ; then
                ps=("$ps_p[@]")
            fi

            if (( ${#ps} > 1 )) ; then
                RPROMPT="${(j.|.)ps}"
            else
                RPROMPT="${r}"
            fi
        else
            RPROMPT=""
        fi
    }
    add-zsh-hook precmd precmd_pipestatus
    ##
    function prompt-hide-venv {
        #: @experimental
        ##
        prompt='%(?.%F{$prompt_pure_colors[prompt:success]}.%F{$prompt_pure_colors[prompt:error]})${prompt_pure_state[prompt]}%f ' #: copied from Pure
    }

    function prompt-reset-venv {
        #: @experimental
        ##
        CONDA_DEFAULT_ENV="?"
    }
    ##
}
##
function pp {
    pngpaste "$1".png
}

function pph {
    local lastimg="$(l-m)"
    mv "${1:-$(pbpaste)}" "${lastimg:r}.html"
}
##
