eval "$(ssh-agent -s)"
prefix=/home/206672215/.ssh
keys=("id_blehrer")
keys+=("id_206672215_nbcuni_github")
keys+=("id_brianlehrer_nbcuni_github.com")
#keys+=("id_ed25519") 
keys+=("nbcnoc_at_ntsi") 
keys+=("ws_at_tll_xit_rsa")
keys+=("206672215_as_ws_at_sl_xit_rsa")

function doLogin() {
    echo -n "ssh private passphrase: "
    read -s password
    [ $password ] && for id in "${keys[@]}"; do
        expect -c "
            spawn ssh-add $prefix/$id
            expect \"Enter passphrase for $prefix/$id: \"
            send \"$password\r\"
            interact"  
    done || echo ---None supplied---
}

doLogin
neofetch

