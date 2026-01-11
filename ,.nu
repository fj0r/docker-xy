const CWD = path self .

export module test {

    export def build [] {
        buildah unshare nu images/test.nu
    }

    export def run [...args] {
        mut flag = [
            --user 1000
            -it
            -v ($CWD)/entrypoint:/entrypoint
            --entrypoint /entrypoint/init.nu
        ]
        ^$env.CNTRCTL run ...[
            ...$flag
            ghcr.io/fj0r/xy:z
            ...$args
        ]
    }

}
