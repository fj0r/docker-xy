use utils.nu *
use lg

export def up [
    owner
    channel
    --component: list
    --target: list
    --bin: list
] {
    run [
        $"rustup default ($channel)"
        $"rustup toolchain install"
    ]
    if ($component | is-not-empty) {
        run [
            $"rustup component add ($component | str join ' ')"
        ]
        let dst = $env.BUILDAH_WORKING_MOUNTPOINT | path join usr/bin/
        for b in [rust-analyzer] {
            if ($b in $bin) and not ($dst | path join $b | path exists) {
                lg o -p 'fix-rustup-bin' $b
                ln -sf ($dst | path join rustup) ($dst | path join $b)
            }
        }
    }
    if ($target | is-not-empty) {
        run [
            $"rustup target add ($target | str join ' ')"
        ]
    }
    if ($bin | is-not-empty) {
        let dst = $env.BUILDAH_WORKING_MOUNTPOINT | path join usr/local/bin/
        lg o -p 'cargo-binstall-dir' $dst
        curl -fsSL https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-x86_64-unknown-linux-musl.tgz
        | tar zxf - -C $dst
        chmod +x ($dst | path join cargo-binstall)
        run [
            $"cargo binstall -y ($bin | str join ' ')"
        ]
    }
    run [
        "rm -rf ${CARGO_HOME}/registry/src/*"
        $'chown ($owner):($owner) -R ${CARGO_HOME}'
    ]
}

export def prefetch [owner workdir proj pkgs] {
    run [
        $"cd ($workdir)"
        $"cargo new ($proj)"
        $"cd ($proj)"
    ]
    let dst = [$env.BUILDAH_WORKING_MOUNTPOINT $workdir $proj] | path join Cargo.toml
    lg o -p 'prefetch' $dst
    let pkgs = $pkgs | reduce -f {} {|i,a|
        $a | insert $i '*'
    }
    let n = open $dst | update dependencies $pkgs 
    print $n
    $n | save -f $dst
    run [
        "cargo fetch"
        $"cd ($workdir)"
        $"chown ($owner):($owner) -R ($proj)"
        "rm -rf ${CARGO_HOME}/registry/src/*"
        $'chown ($owner):($owner) -R ${CARGO_HOME}'
    ]
  
}
