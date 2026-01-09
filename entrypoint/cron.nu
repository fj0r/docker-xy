#!/usr/bin/env nu

# --- Cron 服務初始化模組 ---

if ($env.CRONFILE? | is-not-empty) {
    if ($env.CRONFILE | path exists) {
        print $"(date now | format date '%+'): 加載 Crontab 文件: ($env.CRONFILE)"

        # 1. 加载 Cron 配置
        sudo crontab $env.CRONFILE

        # 2. 使用 Pueue 託管 Cron 守護進程
        # -f: 前台運行模式，確保 Pueue 可以監控其生命週期
        # 放入 'default' 組，以便 entrypoint 進行統一監控
        print $"(date now | format date '%+'): 啟動 Cron 守護進程..."

        pueue add --group default --title "cron" -- "sudo cron -f"
    } else {
        print $"(date now | format date '%+'): [Error] 找不到 CRONFILE: ($env.CRONFILE)"
    }
}
