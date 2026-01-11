const CWD = path self .

export module test {

    export def build [] {
        buildah unshare nu images/test.nu
    }

    export def run [
    --user(-u)
    --socat(-s)
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
        if $socat {
            $flag ++= [
                -e tcp_123=abc:123
                -e tcp_456=abc:456
                -e udp_123=uuu:123
                -e udp_456=uuu:456
            ]
        }
        ^$env.CNTRCTL run ...[
            ...$flag
            ghcr.io/fj0r/xy:z
            ...$args
        ]
    }

}
