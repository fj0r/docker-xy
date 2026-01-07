use utils.nu *

export def install [pkgs] {
    run [
        $"pacman -Sy --noconfirm ($pkgs | str join ' ')"
        "rm -rf /var/cache/pacman/pkg/*"
    ]
}

export def update [] {
    run ["pacman -Syu --noconfirm"]
}

export def 'pip install' [pkgs] {
    let pkgs = $pkgs | str join ' '
    run [
        $"pip install --no-cache-dir --break-system-packages ($pkgs)"
    ]
}

export def 'setup python' [pkgs] {
    install [
        python python-pip
    ]
    pip install $pkgs
}

export def 'setup js' [pkgs] {
    install [
        bun
    ]
    let pkgs = $pkgs | str join ' '
    run [
        $"bun install --global --no-cache ($pkgs)"
    ]
}

export module config {
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
    export def master [user workdir] {
        let xdg_home = $"/home/($user)/.config"
        run [
            $'useradd -mU -G wheel,root -s /usr/bin/nu ($user)'
            $'mkdir -p ($workdir)'
            $'chown ($user):($user) -R ($workdir)'
            $'mkdir -p ($xdg_home)'
            $'chown ($user):($user) -R ($xdg_home)'
        ]
        $xdg_home
    }

    export def nushell [user home url] {
        run [
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
