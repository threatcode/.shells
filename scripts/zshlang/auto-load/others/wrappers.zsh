function '$' {
  reval "$@"
}
##
function hammerspoon() {
  # -t timeout (default 4)
  assert gtimeout 30s hs -A -t 5 "$@" @RET
}
##
function mcli-getexecpath_h() {
  brew unlink m-cli
  
  mcli_path=("$(brew --cellar m-cli)"/*/bin/m)
  ec "$mcli_path"
}
function mcli-getexecpath() {
  memoi_expire=0 memoi-eval mcli-getexecpath_h "$@"
}
function mcli() {
  # https://github.com/rgcr/m-cli
  command "${mcli_path:-$(mcli-getexecpath)}" "$@"
}
function tldr() {
  #nig ea  #not needed because of piping autoremoval of color.
  isDarwin && { command tldr "$@" || command tldr -p linux "$@" ; return $? }
  command tldr "$@" | bt
}
function exa() {
  local arg long=''
  for arg in "$@"
  do
    [[ "$arg" == "-l" || "$arg" == "--long" || "$arg" =~ "-(-tree|T)" ]] && long='y'
  done
  if test -z "$long"
  then
    command exa -1 "$@"
  else
    command exa "$@"
  fi
}

function k2pdfopt() {
    if isDarwin ; then
        command k2pdfopt_darwin "$@"
    else
        command k2pdfopt_linux "$@"
    fi
}
##
function ffmpeg() {
    isI && command ffmpeg "$@" || command ffmpeg -loglevel error "$@"
}
##
function edir() {
  command edir --all --recurse  --suffix '' "$@"
}
##
function watchm() {
    ruu "watch -n $1" "${@:2}"
}
##
function fd() {
  # include ignored files by default
  command fd -u "$@"
}
##
# function open() {
#   assert isDarwin @RET
#   if false && [[ "$1" =~ '\.pdf$' ]] ; then
#     ##
#     # command open -a opera "$1"
#     ##
#     assert chrome-open-pdf "$1"
#     ##
#     shift
#     "$0" "$@"
#     return $?
#   elif (( $#@ >= 1 )) ; then
#     command open "$@"
#   fi
# }

function open-with {
  local app="$1" ; shift
  assert-args app @RET

  in-or-args "$@" |
    inargsf grealpath -- |
    inargsf reval-ec open -a "$app" --
}

aliasfn opv open-with preview
aliasfn ops open-with Skim
aliasfn opy open-with sioyek
##
function mega-get() {
  if isBicon ; then
    ecgray "$0: mega-get sometimes hangs when run in Bicon; Wrapping it in a tmux session."
    tshd command mega-get "$@"
  else
    command mega-get "$@"
  fi
}
##
function mipsi-stdin() {
  mipsi =(cat)
}
##
function ssh-p() {
  local password
  vared -p 'Password:' password @RET
  # typeset -g ssh_pass="$password" # @naughty

  if isDarwin ; then
    # https://stackoverflow.com/questions/32255660/how-to-install-sshpass-on-mac/62623099#62623099
    ##
    ssh "$@"
  else
    sshpass -p "$pass" ssh "$@"
  fi
}
##
function pwd {
  if isOutTty ; then
    ecn "${PWD}/" | pbcopy || true
  fi

  builtin pwd
}
##
function titlecase {
  #: @install/pip
  ##
  cat-paste-if-tty | command titlecase "$@" | cat-copy-if-tty
}
##
function spotdl {
  local args=("$@")

  invocation-save "$0" "${args[@]}"

  @opts engine bell-dl @ reval-bell command spotdl "${args[@]}"
}
##
function vcard-to-json {
  # ~[vcard-to-json]/vcard-to-json-0.1.0-SNAPSHOT "$@" |
  java -jar ~[vcard-to-json]/target/vcard-to-json-0.1.0-SNAPSHOT.jar "$@" |
    jq-rtl . #: needed to, e.g., normalize strings
}
##
function zathura {
  local name="${1:r}" args=()
  name="zathura $(str2tmuxname "$name")" @TRET
  for arg in "$@" ; do
    if test -e "$arg" ; then
      args+="$(realpath "$arg")" @TRET
    else
      args+="$arg"
    fi
  done

  reval-ec tmuxnew "$name" command zathura "${args[@]}"
}
##
