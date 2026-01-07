export def install [pkgs] {
    do $in.run [
        $"pacman -Sy --noconfirm ($pkgs | str join ' ')"
        "rm -rf /var/cache/pacman/pkg/*"
    ]
}

export def update [] {
    do $in.run ["pacman -Syu --noconfirm"]
}

export def 'pip install' [pkgs] {
    let n = $in
    let pkgs = $pkgs | str join ' '
    do $n.run [
        $"pip install --no-cache-dir --break-system-packages ($pkgs)"
    ]
}

export def 'setup python' [pkgs] {
    let n = $in
    $n | install [
        python python-pip
    ]
    $n | pip install $pkgs
}

export def 'setup js' [pkgs] {
    let n = $in
    $n | install [
        bun
    ]
    let pkgs = $pkgs | str join ' '
    do $n.run [
        $"bun install --global --no-cache ($pkgs)"
    ]
}

export module config {
    export def timezone [timezone] {
        do $in.run [
            $'ln -sf /usr/share/zoneinfo/($timezone) /etc/localtime'
            $'echo "($timezone)" > /etc/timezone'
        ]
    }
    export def git [author] {
        do $in.run [
         'git config --global pull.rebase false'
         'git config --global init.defaultBranch main'
         $'git config --global user.name "($author)"'
         $'git config --global user.email "($author)@container"'
        ]
    }
    export def sudo [] {
        do $in.run [
            `sed -i 's/# \(%.*NOPASSWD.*\)/&\n\1/' /etc/sudoers`
        ]
    }
    export def master [user workdir] {
        let n = $in
        let xdg_home = $"/home/($user)/.config"
        do $n.run [
            $'useradd -mU -G wheel,root -s /usr/bin/nu ($user)'
            $'mkdir -p ($workdir)'
            $'chown ($user):($user) -R ($workdir)'
            $'mkdir -p ($xdg_home)'
            $'chown ($user):($user) -R ($xdg_home)'
        ]
        $xdg_home
    }

    export def nushell [user home url] {
        do $in.run [
            $'git clone --depth=3 ($url) ($home)/nushell'
            'opwd=$PWD'
            $'cd ($home)/nushell'
            'git log -1 --date=iso'
            'cd $opwd'
            $'chown ($user):($user) -R ($home)/nushell'
            $'sudo -u ($user) nu -c "plugin add /usr/bin/nu_plugin_query"'
            $"echo '$env.NU_POWER_CONFIG.theme.color.normal = \"xterm_olive\"' >> /home/($user)/.nu"
            $"chown ($user):($user) /home/($user)/.nu"
        ]
    }
}
