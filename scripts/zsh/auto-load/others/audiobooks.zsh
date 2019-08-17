dir2ab() {
    mdocu '<dir> <output_name>
Joins the audio files in <dir>, removes the originals, generates a podcast feed, and returns the url.' MAGIC
    local abdir="$1" out="$2" base=~/Downloads/
    pushf $base
    abdir="$(realpath --relative-to $base "$abdir")"
    local tmp=$abdir/tmp_dir2ab/
    mv $abdir/*.(${(j.|.)~audio_formats})(D) $tmp
    audio-join $abdir/$out $tmp/*(D)
    ecdbg Audio joined with $?
    local covers=($abdir/*cover*.(jpg|png))
    (( ${#covers} )) || {
        fetch-ebook-metadata --title "$out" --cover $abdir/cover.png
        covers=($abdir/*cover*.(jpg|png))
    }
    genRSS.py -d $abdir -e "${aj_out:e}" -t "$out" -p "The night is fair ..." -o $abdir/feed.rss --image "$covers[1]" --host 'http://lilf.ir:8080'
    # \rm -r $tmp #URGENTTD
    get-dl-link $abdir/feed.rss
}