# 以 Edge 独立窗口方式打开「送货单」
$ErrorActionPreference = 'SilentlyContinue'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$html = Join-Path $here '送货单.html'

if (-not (Test-Path -LiteralPath $html)) {
    Write-Host "找不到 送货单.html，请确认文件和本脚本在同一个文件夹。"
    Start-Sleep -Seconds 5
    exit 1
}

# 转成标准 file:/// 地址（自动处理中文与空格）
$uri = ([System.Uri]$html).AbsoluteUri

$candidates = @(
    (Join-Path ${env:ProgramFiles} 'Microsoft\Edge\Application\msedge.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application\msedge.exe')
)
$edge = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1

if ($edge) {
    Start-Process -FilePath $edge -ArgumentList "--app=$uri", "--window-size=1440,920"
} else {
    # 没有 Edge 时用系统默认浏览器打开
    Start-Process $html
}
