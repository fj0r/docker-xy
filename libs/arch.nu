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
