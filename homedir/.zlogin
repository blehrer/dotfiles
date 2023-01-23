eval "$(ssh-agent -s)"
prefix=/Users/a206672215/.ssh/keys
keys=("blehrer.github.com")
keys+=("206672215_nbcuni.github.com")
keys+=("brianlehrer-nbcuni.github.com")
keys+=("ws.xit.sl")
keys+=("ws.xit.tll")
keys+=("nbcnoc.ntsi")

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

