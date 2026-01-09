#!/usr/bin/env nu

# 1. 获取所有环境变量并转换为表格
# 2. 过滤包含指定关键词的 Key (对应原脚本 grep -E)
# 3. 排除特定前缀或名称的 Key (对应原脚本 grep -Ev)
let env_to_save = ($env 
    | transpose key value 
    | where key =~ '_|HOME|ROOT|PATH|TIMEZONE|HOSTNAME|DIR|VERSION|LANG|TIME|MODULE|BUFFERED'
    | where key !~ '^(_|HOME|USER|LS_COLORS)$'
)

# 4. 将结果格式化为 KEY=VALUE 格式
let env_lines = ($env_to_save 
    | each { |row| $"($row.key)=($row.value)" } 
    | str join "\n"
)

# 5. 追加到 /etc/environment
if ($env_lines | is-not-empty) {
    print $"(date now | format date '%+'): 导出环境变量到 /etc/environment"
    # 使用 sudo tee 追加内容
    $"($env_lines)\n" | sudo tee -a /etc/environment | ignore
}
