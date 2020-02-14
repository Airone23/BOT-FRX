
Import-Module "C:\lib\BOT\BOT.ps1"
$temp = New-Item -Path "c:\" -ItemType Directory -Name "MAJBOT"
$Temp_Script = Invoke-WebRequest -Uri "https://github.com/Airone23/BOT-FRX/releases/download/Bot_V2/BOT_ameliore.ps1" -OutFile "$Temp\BOT_ameliore.ps1"
Foreach-object {
write-host     "╔════ Download ════╗" -fore yellow}{
    write-host "║" -ForegroundColor Yellow -no
    Write-Host "   Download ok!   " -ForegroundColor Blue -NoNewline
    write-host "║" -ForegroundColor Yellow 
}{  write-host "╚══════════════════╝"-fore yellow}
$botpath = "C:\lib\BOT_ameliore.ps1"
# sur le bot : 
function global:FRX_Socket-MessageAction{
    param($message)
    $stop = $false
    switch ($message) {
        {$_ -match "HACKMETHIS"  } {write-host "hack this" -ForegroundColor green}
        {$_ -match "COUNT"       } {write-host "COUNT" -ForegroundColor Yellow}
        {$_ -like  "GAMEOVER"    } {write-host "--- TERMINATING CONNECTION ---" -ForegroundColor red
                                    $stop=$true}
        {$_ -like "*.. " }         {
        #idée : check maj sur github. lors du Gameover puis télécharger la MAJ sur un fichier temporaire, vérifier le HASH puis remplacer le bot par nouvelle version et effacer le fichier temp
        write-host "On va faire la MAJ avec ça" -ForegroundColor Magenta
        #On télécharge le fichier mis à jour
        #https://github.com/Airone23/BOT-FRX/releases/download/v1/BOT_ameliore.ps1
        Invoke-WebRequest -Uri "" -OutFile $botpath
        $stop=$true
        }
        Default {write-host $message}
    }

    return $stop
}
$Socket   = FRX_Socket-Listen-Connect  -port 1984
do{
    $message  = FRX_Socket-Listen-Read     -socket  $Socket -buffersize 512
    $stop     = FRX_Socket-MessageAction   -message $message
}until($stop)

$closeACK = FRX_Socket-Listen-Close    -socket $Socket 
write-host "salut je suis pas à jour"
#powershell $botpath