#!/usr/bin/env nu

# --- Upterm 容器启动模块 (2026 优化版) ---

# 环境变量说明:
# $env.UPTERM_SERVER  - 可选: 私有服务器地址 (例如 "uptermd.example.com:22")
# $env.UPTERM_WEBHOOK - 可选: 接收 SSH 命令的 Webhook URL
# $env.UPTERM_LABELS  - 可选: 自定义标签 (例如 "env=prod,app=api")

def main [] {
    if (which upterm | is-empty) {
        print $"[(date now | format date '%+')] Skipping Upterm: binary not found"
        return
    }

    print $"[(date now | format date '%+')] Initializing Upterm service..."

    let server_arg = if ($env.UPTERM_SERVER? | is-not-empty) {
        ["--server" $env.UPTERM_SERVER]
    } else {
        []
    }

    if not ('~/.ssh' | path exists) { mkdir ~/.ssh }
    if not ('~/.ssh/id_ed25519' | path exists) {
        ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
    }

    # 必须添加 --admin-socket 否则在非交互环境下 session current 无法工作
    let upterm_args = [host ...$server_arg --skip-host-key-check --accept --force-command nu -- /usr/bin/env nu]

    # 3. 使用 Pueue 托管宿主进程
    let cmd_str = (["upterm" ...$upterm_args] | str join " ")
    let add_result = pueue add --group default --title "upterm_host" -- $cmd_str | complete

    if $add_result.exit_code != 0 {
        print $"[(date now | format date '%+')] Error: Failed to add task to Pueue: ($add_result.stderr)"
        return
    }

    let job_id = $add_result.stdout | parse -r 'New task added \(id (?<id>[0-9]+)\)' | get 0.id
    print $"[(date now | format date '%+')] Upterm task added to Pueue with ID: ($job_id)"

    # 4. 异步获取并推送连接字符串
    job spawn {
        mut connection_str = ""
        for i in 1..15 {
            sleep 2sec

            let job_log = pueue log $job_id --json | from json | get $job_id
            if 'Running' not-in $job_log.task.status {
                print $"[(date now | format date '%+')] Upterm process failed. Last logs:\n($job_log.output)"
                return
            }
            let matches = ($job_log.output | lines | where $it =~ "SSH:" | first? | str replace "SSH:" "" | str trim)
            if ($matches != null and ($matches | is-not-empty)) {
                $connection_str = $matches
                break
            }
        }

        if ($connection_str | is-empty) {
            print $"[(date now | format date '%+')] Upterm Error: Failed to retrieve session address"
            return
        }

        print $"[(date now | format date '%+')] Upterm Ready: ($connection_str)"

        if ($env.UPTERM_WEBHOOK? | is-not-empty) {
            let payload = {
                msg_type: "text",
                content: {
                    text: $"Container remote debugging enabled\nHostname: (hostname)\nCommand: ($connection_str)\nTime: (date now | format date '%+')"
                }
            }

            try {
                http post -t application/json $env.UPTERM_WEBHOOK $payload
                print $"[(date now | format date '%+')] Upterm Webhook sent successfully"
            } catch {
                print $"[(date now | format date '%+')] Upterm Webhook failed to send"
            }
        }
    }
}

# 运行主函数
main
