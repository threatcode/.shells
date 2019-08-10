function 2mobi() {
    doc usage: FILE calibre-options
    ebook-convert "$1" "${1:r}.mobi" "${@:2}"
}
function 2m2k() {
    doc usage: FILE calibre-options
    [[ "$1" =~ 'mobi.az1$' ]] && {
        mv "$1" "${1:r}"
        ecdbg "az1 detected; Renaming to ${1:r}"
        set -- "${1:r}"
    } || if test "${1:e}" != mobi ; then
        2mobi "$@"
        set -- "${1:r}.mobi"
    fi
    2kindle "$1"
}
function aap() {
    aa "$@" --on-download-complete aa-pToKindle
}
function aab() {
    aa "$@" --on-download-complete aa-toKindle
}
function 2kindle() {
    mutt -s "${2:-convert}" -a "$1" -- "${3:-$kindle_email}" <<<hi
}
function 2ko() {
    2kindle "$1" "some_subject" "$2"
}
function 2p2k() {
    k2pdf "$1"
    2ko "${1:r}_k2opt.pdf"
}
tlrl-ng() {
    #IMPL
}