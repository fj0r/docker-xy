const CWD = path self .

export module test {

    export def build [] {
        buildah unshare nu images/test.nu
    }

    export def run [
    --user(-u)
    --socat
    --s3
    ...args
    ] {
        mut flag = [
            -it
            --device /dev/fuse --privileged
            -v ($CWD)/entrypoint:/entrypoint
            --entrypoint /entrypoint/init.nu
        ]
        if $user {
            $flag ++= [--user 1000]
        }
        if $s3 {
            $flag ++= [
                -e 's3_pre=/srv/att,root,http://x.com,oss,test,access,secrets,nonempty'
                -e 's3_dev=/srv/att,root,http://x.com,oss,test,access,secrets,nonempty'
            ]
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
