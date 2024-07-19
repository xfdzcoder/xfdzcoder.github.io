param (
    [string]$message = "new post"
)

# 添加所有文件到 Git
git add .

# 提交更改
git commit -m $message

# 推送到 main 分支
git push origin main