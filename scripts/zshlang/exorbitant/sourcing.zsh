if command -v opam &> /dev/null; then  eval $(opam env); fi
if [ -e /Users/evar/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/evar/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
GPG_TTY=$(tty)
export GPG_TTY

psource ~/torch/install/bin/torch-activate

rust-setup
