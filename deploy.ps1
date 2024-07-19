param (
    [string]$message = "new post"
)

# 添加所有文件到 Git
Write-Host "add all files..."
git add .

# 提交更改
Write-Host "`ncommit it..."
git commit -m $message

# 推送到 main 分支
Write-Host "`npush it"
git push origin main
