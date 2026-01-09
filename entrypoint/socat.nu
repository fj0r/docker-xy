def run_socat [proto: string, port: string, target: string] {
    let logfile = if ($env.stdlog? != null) { "/dev/stdout" } else { $"/var/log/socat_($proto)_($port)" }

    let cmd = $"sudo socat ($proto)-listen:($port),reuseaddr,fork ($proto):($target)"

    pueue add --group default --title $"socat_($proto)_($port)" -- $"($cmd) 2>&1 | sudo tee -a ($logfile)"

    print $"($proto):($port) --> ($target)"
}

$env | transpose key value | each { |row|
    if ($row.key | str starts-with "tcp_") {
        let port = ($row.key | str replace "tcp_" "")
        run_socat "tcp" $port $row.value
    } else if ($row.key | str starts-with "udp_") {
        let port = ($row.key | str replace "udp_" "")
        run_socat "udp" $port $row.value
    }
}

