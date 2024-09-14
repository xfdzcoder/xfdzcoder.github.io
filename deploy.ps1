param (
    [string]$message = "new post"
)
# 本地构建
hugo

# 构建 algolia 索引
npm run algolia

# 添加所有文件到 Git
Write-Host "add all files..."
git add .

# 提交更改
Write-Host "`ncommit it..."
git commit -m $message

# 推送到 main 分支
Write-Host "`npush it"
git push origin main
