Import-Module "C:\lib\FRX_SOCKET.ps1"

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
        write-host "On va faire la MAJ avec ça" -ForegroundColor Magenta
        #On télécharge le fichier mis à jour
        #Invoke-WebRequest -Uri "" -OutFile $botpath
        powershell $botpath
        }
        Default {write-host $message}
    }

    return $stop
}

#netstat -ano | find "1984"



$Socket   = FRX_Socket-Listen-Connect  -port 1984

do{
    $message  = FRX_Socket-Listen-Read     -socket  $Socket -buffersize 512
    $stop     = FRX_Socket-MessageAction   -message $message
}until($stop)

$closeACK = FRX_Socket-Listen-Close    -socket $Socket 