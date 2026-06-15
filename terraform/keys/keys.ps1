$keysPath = (Get-Location).Path

$publicKeyPath = Join-Path $keysPath "key-ec2-public-triaige.pem"
$privateKeyPath = Join-Path $keysPath "key-ec2-private-triaige.pem"

ssh-keygen -t rsa -b 2048 -m PEM -f $publicKeyPath -N "`""
ssh-keygen -t rsa -b 2048 -m PEM -f $privateKeyPath -N "`""
