$LEOCERTPATH=".\LEGENDARYLEO\LEGENDARYLEO-CA.cer"
$SCU611CERTPATH=".\SCU611\SCU611-CA.cer"
$CERTDEST="Cert:\LocalMachine\Root"

$HOSTURL="https://github.com/SCU610/SCU611_Hosts/archive/master.zip"
$HOSTFILEPATH=".\SCU611\HOSTS\source.zip"
$HOSTPATH=".\SCU611\HOSTS"
$TEMPNAME="SCU611_Hosts-master"

$WINDOWSHOSTPATH="C:\Windows\System32\drivers\etc"

function Check-Admin
{
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-CA
{
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow �CNoNewLine "��װ֤��:"
    Import-Certificate -FilePath $LEOCERTPATH -CertStoreLocation $CERTDEST
    Import-Certificate -FilePath $SCU611CERTPATH -CertStoreLocation $CERTDEST
    Write-Host -ForegroundColor Green "���"
    Write-Host "-----------------------"
}
function Get-Hosts
{
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow -NoNewline "����HOSTS�ļ�:"
    if(!(Test-Path $HOSTPATH))
    {
        New-Item -ItemType "directory" -Force -Path $HOSTPATH | Out-Null
    }
    Invoke-WebRequest -Uri $HOSTURL -OutFile $HOSTFILEPATH
    Write-Host -ForegroundColor Green "���"
    Write-Host "-----------------------"
    return
}

function Expand-Hosts
{
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow -NoNewline "��ѹ:"
    unzip -o -q $HOSTFILEPATH -d $HOSTPATH
    Copy-Item "$HOSTPATH\$TEMPNAME\*" "$HOSTPATH\" -Recurse -Force
    Write-Host -ForegroundColor Green "���"
    Write-Host "-----------------------"
    return
}

function Backup-Hosts
{
    $BACKUPPATH=".\Backup"
    $DATE=Get-Date -Format s | ForEach-Object {$_ -replace ":", "."}
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow -NoNewline "����HOSTS:"
    if(!(Test-Path $BACKUPPATH))
    {
        New-Item -ItemType "directory" -Force -Path $BACKUPPATH | Out-Null
    }
    Copy-Item "$WINDOWSHOSTPATH\hosts" "$BACKUPPATH\hosts_$date" -Force
    Write-Host -ForegroundColor Green "���"
    Write-Host "-----------------------"
    return
}

function Copy-Hosts
{
    $DESTHOSTSPATH=".\TEST"
    $IPV4_610HOSTSPATH="$HOSTPATH\IPV4\SCU610"
    $IPV4_611HOSTSPATH="$HOSTPATH\IPV4\SCU611"
    $IPV6_HOSTSPATH="$HOSTPATH\IPV6"
    $Prompt="
    1. ��װIPV4/SCU610 HOSTS
    2. ��װIPV4/SCU611 HOSTS
    3. ��װIPV6 HOSTS
    "
    $CHOICE = Read-Host -Prompt $Prompt
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow -NoNewline "������ѡHOSTS��ϵͳ�ļ���:"
    switch($CHOICE)
    {
        1
        {
            Copy-Item "$IPV4_610HOSTSPATH\hosts" "$DESTHOSTSPATH" -Force
            Write-Host -ForegroundColor Green "���"
        }
        2
        {
            Copy-Item "$IPV4_611HOSTSPATH\hosts" "$DESTHOSTSPATH" -Force
            Write-Host -ForegroundColor Green "���"
        }
        3
        {
            Copy-Item "$IPV6_HOSTSPATH\hosts" "$DESTHOSTSPATH" -Force
            Write-Host -ForegroundColor Green "���"
        }
        default
        {
            Write-Host -ForegroundColor White -BackgroundColor Red "ѡ������ʧ��"
        }
    }
    Write-Host "-----------------------"
    return
}

function Refresh-DNS
{
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow -NoNewline  "ˢ��DNS:"
    ipconfig /flushdns | Out-Null
    Write-Host -ForegroundColor Green "���"
    Write-Host "-----------------------"
}

function Remove-Temp
{
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow -NoNewline "������ʱ�ļ�:"
    Remove-Item $HOSTFILEPATH, "$HOSTPATH\*.pdf",  "$HOSTPATH\*.vsdx"
    Remove-Item "$HOSTPATH\SCU611_Hosts-master" -Recurse
    Write-Host -ForegroundColor Green "���"
    return
}

Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow "��ʼִ�а�װ�ű�"
Write-Host "======================="
$AdminStatus=Check-Admin
<#
if( -not $AdminStatus)
{
    Write-Host -ForegroundColor Red "����ԱȨ�޼��ʧ�ܣ���رմ˴��ڲ��Թ���ԱȨ����������Setup.bat"
    Write-Host "======================="
    Write-Host -ForegroundColor White -BackgroundColor Red "��װʧ��"
    return
}
#>
#Install-CA
Backup-Hosts
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Get-Hosts
Expand-Hosts
Copy-Hosts
Refresh-DNS
Remove-Temp
Write-Host "======================="
Write-Host -ForegroundColor White -BackgroundColor Green "��װ�ɹ�"