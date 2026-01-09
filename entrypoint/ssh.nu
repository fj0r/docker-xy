#!/usr/bin/env nu

# --- 1. 初始化與 Shell 檢測 ---
# 檢測可用 Shell，優先順序：zsh > bash > sh
let __shell = [
    "/bin/zsh"
    "/bin/bash"
    "/bin/sh"
] | where { |it| $it | path exists } | first

# --- 2. 定義用戶設定函數 ---
def set_user [user_info: string, comment: string, pubkey: string] {
    # 解析 user:uid:gid 格式
    let arr = $user_info | split row ":"
    let _name = $arr | get 0

    let _uid = if $_name == "root" { "0" } else { $arr | get 1? | default "1000" }
    let _gid = if $_name == "root" { "0" } else { $arr | get 2? | default "1000" }

    if $_name != "root" {
        # 建立組群 (若不存在)
        if (sudo getent group $_name | is-empty) {
            sudo groupadd -g $_gid $_name
        }
        # 建立用戶 (若不存在)
        if (sudo getent passwd $_name | is-empty) {
            sudo useradd -m -u $_uid -g $_gid -G sudo -s $__shell -c $comment $_name
        }
    }

    # 獲取家目錄
    let _home_dir = (sudo getent passwd $_name | split row ":" | get 5)

    # 更新 .profile 環境變數
    let _profile = $"($_home_dir)/.profile"
    $"\nPATH=($env.PATH)\n" | sudo tee -a $_profile

    # 設定 SSH 密鑰
    let ssh_dir = $"($_home_dir)/.ssh"
    sudo mkdir -p $ssh_dir
    $"ssh-ed25519 ($pubkey)\n" | sudo tee -a $"($ssh_dir)/authorized_keys"
    sudo chown -R $"($_name):($_name)" $ssh_dir
    sudo chmod -R "go-rwx" $ssh_dir
}

# --- 3. 初始化 SSH 配置 ---
def init_ssh [] {
    # 處理主機金鑰
    if ($env.SSH_HOSTKEY_ED25519? != null) {
        $env.SSH_HOSTKEY_ED25519 | decode base64 | sudo tee /etc/dropbear/dropbear_ed25519_host_key
    }

    # 掃描 ed25519_ 開頭的環境變數
    $env | transpose key value | where key starts-with "ed25519_" | each { |row|
        let _user_info = ($row.key | str replace "ed25519_" "")
        set_user $_user_info 'SSH User' $row.value
    }
}

# --- 4. 啟動 Dropbear 服務 ---
def run_ssh [] {
    let logfile = if ($env.stdlog? != null) { "/dev/stdout" } else { "/var/log/sshd" }
    let timeout_args = if ($env.SSH_TIMEOUT? != null) {
        print $"Starting dropbear with a timeout of ($env.SSH_TIMEOUT) seconds"
        ["-K" $env.SSH_TIMEOUT "-I" $env.SSH_TIMEOUT]
    } else {
        print "Starting dropbear"
        []
    }

    # 使用 Pueue 託管 Dropbear 服務
    # -R: 允許 root 登入, -E: 日誌輸出到 stderr, -F: 前台運行 (Pueue 必備)
    let cmd = [
        "sudo" "dropbear" "-REFems" "-p" "22"
        ...$timeout_args
    ] | str join " "

    pueue add --group default --title "sshd" -- $"($cmd) 2>&1 | sudo tee -a ($logfile)"
}

# --- 5. 執行入口 ---
# 檢查是否有任何 ed25519_ 設定
let has_ssh_config = ($env | transpose key value | any { |it| $it.key starts-with "ed25519_" })

if $has_ssh_config {
    sudo mkdir -p /etc/dropbear
    init_ssh
    run_ssh
}
