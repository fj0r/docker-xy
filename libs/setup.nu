use utils.nu *

export def timezone [timezone] {
    run [
        $'ln -sf /usr/share/zoneinfo/($timezone) /etc/localtime'
        $'echo "($timezone)" > /etc/timezone'
    ]
}

export def git [author] {
    run [
     'git config --global pull.rebase false'
     'git config --global init.defaultBranch main'
     $'git config --global user.name "($author)"'
     $'git config --global user.email "($author)@container"'
    ]
}

export def sudo [] {
    run [
        `sed -i 's/# \(%.*NOPASSWD.*\)/&\n\1/' /etc/sudoers`
    ]
}

export def master [config] {
    run [
        $'useradd -mU -G wheel,root ($config.user)'
        $'mkdir -p ($config.workdir)'
        $'chown ($config.user):($config.user) -R ($config.workdir)'
        $'mkdir -p ($config.config)'
        $'chown ($config.user):($config.user) -R ($config.config)'
    ]
}
