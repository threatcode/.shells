lpassf() {
    lpass ls  | fz -q "$*" | awk '{print $(NF)}' | sed 's/\]//g'
}
function lpassf_() {
    doc 'macro to create lpassf* functions'
    local body="re lpass$1 "'"${(@f)$(lpassf "$*")}"'
    eval "function lpassf$1() { $body }" 
}
re lpassf_ u p g
alias lp=lpassfg
alias lpp=lpassfp
alias lpu=lpassfu
lpassg() {
    lpass show --basic-regexp --expand-multi "$@"
}
lpassu() {
    lpassg --username "$@" |pbcopy
}
lpassp() {
    lpassg --password "$@" |pbcopy
}