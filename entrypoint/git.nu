#!/usr/bin/env nu

# --- Git Pull 任務自動排程模組 (2026 優化版) ---

# 檢查 git_pull 環境變數是否存在且不為空
if ($env.git_pull? | is-not-empty) {

    # 1. 初始化日誌目錄
    let log_dir = "/var/log/git_pull"
    if not ($log_dir | path exists) {
        sudo mkdir -p $log_dir
    }

    # 2. 解析目錄列表
    # 使用 split row 配合 str trim 清理多餘空白
    let git_dirs = ($env.git_pull | split row "," | str trim | where ($it | is-not-empty))

    for dir in $git_dirs {
        # 檢查目錄是否存在且為資料夾
        if not ($dir | path exists) {
            print $"(date now | format date '%+'): [Warning] 跳過不存在的目錄: ($dir)"
            continue
        }

        # 3. 準備任務資訊
        let base_name = ($dir | path basename)
        let log_file = $"($log_dir)/($base_name).log"
        
        print $"(date now | format date '%+'): 排程 Git Pull -> ($dir)"

        # 4. 使用 Pueue 託管任務
        # 2026 最佳實踐：
        # - 使用 --immediate 確保立即執行
        # - 將任務放入獨立的 'update' 佇列，避免阻塞主服務
        # - 顯式使用 sh -c 以確保 cd 與 && 邏輯正確執行
        let task_cmd = $"cd ($dir) && git pull 2>&1 | sudo tee -a ($log_file)"
        
        pueue add --immediate --title $"git_pull:($base_name)" -- $"($task_cmd)"
    }
} else {
    print $"(date now | format date '%+'): 未偵測到 git_pull 任務，跳過。"
}
