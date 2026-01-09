#!/usr/bin/env nu

# --- 核心函数：运行 s3fs ---
def run_s3 [s3_id: string, s3_args: string] {
    # 1. 结构化解析 CSV 参数
    let arr = ($s3_args | split row ",")

    let mount_point = ($arr | get 0)
    let user        = ($arr | get 1)
    let endpoint    = ($arr | get 2)
    let region      = ($arr | get 3)
    let bucket      = ($arr | get 4)
    let access_key  = ($arr | get 5)
    let secret_key  = ($arr | get 6)

    # 2. 解析后续的动态选项 (opts)
    # 逻辑：如果选项是 key=value 则保留，如果是 key 则转为 -o key
    let raw_opts = ($arr | drop 7)
    let opt_args = ($raw_opts | each { |it|
        if ($it | str contains "=") {
            ["-o" $it]
        } else {
            ["-o" $it]
        }
    } | flatten)

    # 3. 准备认证文件
    let safe_name = ($mount_point | str replace -a "/" "_")
    let logfile = $"/var/log/s3fs_($safe_name)"
    let auth_dir = "/.s3fs-passwd"
    let auth_file = $"($auth_dir)/($safe_name)"

    if (not ($auth_dir | path exists)) {
        sudo mkdir $auth_dir
    }

    print $"Generating authfile: ($auth_file)"
    $"($access_key):($secret_key)\n" | sudo tee $auth_file | ignore
    sudo chmod "go-rwx" $auth_file
    sudo chown $user $auth_file

    # 4. 准备挂载点
    sudo mkdir -p $mount_point
    sudo chown $user $mount_point

    # 5. 构建区域/终结点逻辑
    let region_opts = if ($region | is-empty) {
        ["-o" "use_path_request_style"]
    } else {
        ["-o" $"endpoint=($region)"]
    }

    # 6. 构建最终命令并提交给 Pueue
    # 注意：s3fs 必须加 -f (foreground) 才能被进程管理器正确监控
    let s3fs_cmd = [
        "sudo" "-u" $user "s3fs" "-f"
        ...$opt_args
        "-o" $"bucket=($bucket)"
        "-o" $"passwd_file=($auth_file)"
        "-o" $"url=($endpoint)"
        ...$region_opts
        $mount_point
    ] | str join " "

    print $"Starting s3fs ($s3_id) for ($mount_point)"

    # 将任务添加到 Pueue，并重定向日志
    pueue add --group default --title $"s3fs_($s3_id)" -- $"($s3fs_cmd) 2>&1 | sudo tee -a ($logfile)"
}

# --- 执行入口 ---
# 搜索所有以 s3_ 开头的环境变量
let s3_configs = ($env | transpose key value | where key starts-with "s3_")

if ($s3_configs | is-empty) {
    print "No S3 configurations found."
} else {
    $s3_configs | each { |row|
        let s3_id = ($row.key | str replace "s3_" "")
        print $"Configuring S3FS: ($s3_id)"
        run_s3 $s3_id $row.value
    }
}
