function chronic-all() {
    tmuxzombie-kill
    rm-caches
    chronic-backup
    chronic-update
}
function chronic-update() {
    brew update
    re 'brew upgrade' googler ddgr fanficfare
    re 'pip install -U' youtube-dl fanficfare
    tldr --update
    if isServer ; then
        brew upgrade
    fi
}
function chronic-backup() {
    re backup-file $timetracker_db
}
##