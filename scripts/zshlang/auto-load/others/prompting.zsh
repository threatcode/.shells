##
function prompt-missing-spaces {
    local input
    input="$(in-or-args "$@")" @RET


    # ec 'Write the following snippet in LaTeX code.'$'\n\n'"$input" |
    ec "Add the missing spaces in the following text:"$'\n\n'"$input"$'\n\n' |
        cat-copy-if-tty
}
##
function prompt-tex {
    local input
    input="$(in-or-args "$@")" @RET


    # ec 'Write the following snippet in LaTeX code.'$'\n\n'"$input" |
    ec 'Write the following snippet using inline LaTeX.'$'\n\n'"$input" |
        cat-copy-if-tty
    # @bad 'with `\\(` and `\\)`. Do not use `$`!'
}

function prompt-tex-yc {
    local input
    input="$(in-or-args "$@")" @RET

    ec 'Write the following snippet in LaTeX code. Separate different parts of the code with newlines.'$'\n\n'"$input" |
        cat-copy-if-tty
}
##
