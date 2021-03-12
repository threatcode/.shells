function tsend-rssln() {
    local rec="${1:?}" link="${2:?}" title="$rssTitle"

    local reallink
    reallink="$(techmeme-extracturl $link)" && test -n "$reallink" || reallink="$link"
    local item="[$title]($reallink)"
    local acc="$PURGATORY/rssln.md"
    ##
    # print -nr -- "$item"$'\n\n' >> $acc
    url2note_override_title="$title" readmoz-md "$reallink" >> $acc # readmoz does not do urlfinalg
    ecn $'\n\n' >> $acc
    ##
    tsend --link-preview --parse-mode markdown -- "$rec" $item
}
function rssln2k() {
    local acc="$PURGATORY/rssln.md"
    test -e "$acc" || { ec "$0: Doesn't exist: $acc" ; return 0 }

    {
        pushf "$PURGATORY"
        local title="ephemeral"
        mv "$acc" "$acc.bak" # move first to avoid synch issues
        acc="$acc.bak"
        md2epub-pandoc "$title" "rssln $(datej)" "$acc"
        tsend --file "$title.epub" -- "$ephemeral" "$(datej)"
        pkDel=y p2k "$title.epub"
    } always { popf }
}
##
function sumgensim() {
    doc "Not recced. Doesn't respect sentence boundaries. We are also feeding it via env vars which is also really bad because env vars have a limited size."

    # text="$(wread "$1" text)"
    # lynx -dump -nolist
    # elinks can be used for this too, as it also has a -dump option (and has -no-references to omit the list of links)
    text="$(w3m -dump "$1")" word_count="${2:-150}" serr python -c 'from gensim.summarization import summarize ; import os; print(summarize(os.environ["text"], word_count=int(os.environ["word_count"])))'
}
function sumym () {
    ## ALT:
    # Not that good (bad free tier, traditional algo):
    # https://smmry.com/https://www.theverge.com/2020/11/18/21573109/epic-tim-sweeney-apple-app-store-fee-cut-reduction-criticize#&SM_LENGTH=5
    ##
    local url="$1"

    # https://pypi.org/project/sumy/
    # lex-rank, text-rank
    # kl can be crazy on CPU. It also is probably worse than lex-rank.
    sumy "${2:-lex-rank}" --length=4 --file =(readmoz-txt "$url") --format=plaintext
}
##
function rss-tl() {
    tl -p "$rssTitle | " "$@"
}
function rss-ctitle() {
    ggrep -P --silent "$rc_t[@]" <<< "$2"
}
function rss-tsend() {
    ensure-redis || return 1
    mkdir -p ~/logs/
    local log=~/logs/rss-tsend.log
    local engine=("${rt_e[@]:-tl}")
    local skip_engine="$rt_skip"
    local no_title="$rt_nt"
    local get_engine=("${rt_ge[@]}")
    test -n "$get_engine[*]" || get_engine=( rsstail -i 120 -l -n 10 -N  )
    local conditions=( ${rt_c[@]} )
    local each_url_delay="${rt_eud:-120}"
    local each_iteration_delay="${rt_eid:-1}"
    local notel="${rt_notel}"
    local id="${rt_id:-$water}"
    local rssurls="rssurls_${rt_duplicates_key}" # used for storing dup links in redis

    local c t l l_norm
    local url
    local urls=()
    for url in "$@"
    do
        if [[ "${get_engine[1]}" == rsstail ]] ; then
            urls+="-u"
        fi
        urls+="$url"
    done

    while :
    do
        ## get_engine:
        # Use git+https://github.com/s0hv/rsstail.py .
        # python -m rsstail -n 0 --striphtml --nofail --interval $((60*15)) --format '{title}
        # {link}
        # ' "$@"
        # python's rsstail sucks

        # https://github.com/flok99/rsstail
        ##

        reval "$get_engine[@]" "${urls[@]}" 2>&2 2>> $log | tee -a $log | while read -d $'\n' -r t; do
            if test -n "$no_title" ; then
                l="$t"
                t=""
            else
                read -d $'\n' -r l # Warning: I have seen this somehow skipped once and then the whole subsequent cycle breaks. I assume it was some faulty feed, as after I disabled that feed, thhe problem went away. Still, rsstail is buggy.
            fi
            l_norm="$(url-normalize "$l")"

            ! (( $(redism SISMEMBER $rssurls "$l_norm") )) || { ec "Duplicate link: $l"$'\n'"Skipping ..." ; continue }

            t="$(<<<"$t" html2utf.py)"
            for c in $conditions[@]
            do
                reval "$c" "$l" "$t" || { ecdate "Skipping $t $l" ; continue 2 }
            done
            ec "Title: $t"

            labeled redism SADD $rssurls $l_norm
            # ensurerun "150s" tsend ...
            test -n "$notel" || tsend --link-preview -- "${id}" "$t"$'\n'"${l}"$'\n'"Lex-rank: $(sumym "$l")"
            sleep "$each_url_delay" #because wuxia sometimes sends unupdated pages
            test -n "$skip_engine" || rssTitle="$t" revaldbg "$engine[@]" "$l" # "$t"
        done
        ecdate restarting "$0 $@ (get_engine: $get_engine[*] )(exit: ${pipestatus[@]})" | tee -a $log
        sleep "$each_iteration_delay" # allows us to terminate the program
    done
    ecdate Exiting. This is a bug.
}