const CWD = path self .

export module test {

    export def build [] {
        buildah unshare nu images/test.nu
    }

    export def run [
    --user(-u)
    ...args
    ] {
        mut flag = [
            -it
            -v ($CWD)/entrypoint:/entrypoint
            --entrypoint /entrypoint/init.nu
        ]
        if $user {
            $flag ++= [--user 1000]
        }
        ^$env.CNTRCTL run ...[
            ...$flag
            ghcr.io/fj0r/xy:z
            ...$args
        ]
    }

}
