function backup-cron() {
    # aka cellar-getcron
    local d="$nightNotes/backups/crontabs/$(hostname)"
    mkdir -p "$d"
    crontab -l > "${d}/$(whoami)"
}

### zii
function ziib-all() {
    pushf $nightNotes/private/configs/zii/
    {
        mkdir -p discourse
        scp root@51.178.215.202:/var/discourse/containers/app.yml ./discourse/
        full-html2 https://discourse.lilf.ir/admin/site_settings.json > ./discourse/site_settings.json # https://github.com/pfaffman/discourse-settings-uploader


        scp zii@51.178.215.202:/home/zii/.muttrc .
        scp zii@51.178.215.202:/home/zii/Caddyfile .
        scp zii@51.178.215.202:/home/zii/.privateShell .

        mkdir -p v2ray
        scp zii@51.178.215.202:/usr/local/etc/v2ray/config.json ./v2ray/

        mkdir -p trojan
        scp root@51.178.215.202:/usr/local/etc/trojan/config.json ./trojan/

        mkdir -p mailu
        scp root@51.178.215.202:/mailu/docker-compose.yml ./mailu/
        scp root@51.178.215.202:/mailu/mailu.env ./mailu/
    } always { popf }
}
###