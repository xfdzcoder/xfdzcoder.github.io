param (
    [string]$message = "new post"
)
# ���ع���
hugo

# ���� algolia ����
npm run algolia

# ��������ļ��� Git
Write-Host "add all files..."
git add .

# �ύ����
Write-Host "`ncommit it..."
git commit -m $message

# ���͵� main ��֧
Write-Host "`npush it"
git push origin main
