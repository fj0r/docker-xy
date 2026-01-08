export def main [server?] {
    let url = 'https://github.com/owenthereal/upterm/releases/download/v0.21.1/upterm_linux_amd64.tar.gz'
    curl -sSL $url | tar -zxf - -C /usr/local/bin upterm
    run-upterm $server
}

export def run-upterm [server?] {
    let srv = if ($server | is-empty) { "" } else { $"--server ($server)" }
    let log = [/tmp $"upterm.(random chars -l 8).log"] | path join
    print $"pwd=(pwd) log=($log) server=($server)"
    sh -c $"upterm host ($srv) --accept --force-command 'nu' -- nu > ($log) 2>&1 &"
    print "init upterm session..."
    let flag = "SSH Command"
    loop {
        if ($log | path exists) {
            let content = (open $log | str trim)
            if ($content | str contains $flag) {
                break
            }
        }
        sleep 1sec
    }

    print "upterm ok..."
    let session_info = (open $log
        | lines
        | where ($it | str contains $flag)
        | first
        | split row ":"
        | last
        | str trim)

    print $"================================================"
    print $"($flag): ($session_info)"
    print $"================================================"

    let upterm_pid = (ps | where name == "upterm" | last | get pid)

    loop {
        if not (ps | any {|it| $it.pid == $upterm_pid}) {
            print "upterm stop"
            break
        }
        sleep 5sec
    }
}
