#Script FRX_Socket 
function global:FRX_Socket-Listen-Connect{
    param($port=1984)
    $socket = new-object System.Net.Sockets.TcpListener('0.0.0.0',$port)
    if($socket -eq $null){exit 1}
    $socket.Start()

    return $socket    
}
function global:FRX_Socket-Listen-Read{
    param($socket,$buffersize=512)
    $script:client = $socket.AcceptTcpClient()

    $stream = $script:client.GetStream() # je rÃ©cupÃ¨re ce qui est envoyÃ©
    # Mais qu'est ce qui a Ã©tÃ© transmis alors ?
    $buffer = New-Object system.byte[] $buffersize
    do{
        $read = $null
        while($stream.DataAvailable -or $read -eq $null){
            $read = $stream.read($buffer,0,$buffersize)
        }    
    }while($read -gt 1)
    $message = ([System.Text.Encoding]::ASCII).GetString($buffer)
    $message = $message.substring(0,$message.IndexOf(0))
    
    return $message    
}
function global:FRX_Socket-Listen-Close{
    param($socket)
    $socket.stop()
    $script:client.close()
    return $null
}
Function global:FRX_Socket-Send-Port{
    param($port = 1984,$IPTarget=127.0.0.1,$message="echo123456")
    $socket = new-object System.Net.Sockets.TcpClient($IPTarget, $port)
    $data = [System.Text.Encoding]::ASCII.GetBytes($message)
    $stream = $socket.GetStream()
    $stream.Write($data, 0, $data.Length)
    $socket.close()
    return $null
}
$botpath = "C:\lib\BOT\BOTOK.ps1"
$URL     = "https://raw.githubusercontent.com/Airone23/BOT-FRX/master/BOTOK.ps1"
# sur le bot : 
function global:FRX_Socket-MessageAction{
    param($message)
    $stop = $false
    switch ($message) {
        {$_ -match "HACKMETHIS"  } {write-host "hack this" -ForegroundColor green | rundll32.exe user32.dll,LockWorkStation}
        {$_ -match "COUNT"       } {write-host "COUNT" -ForegroundColor Yellow}
        {$_ -like  "GAMEOVER"    } {write-host "--- TERMINATING CONNECTION ---" -ForegroundColor red
                                    $stop=$true}
        {$_ -like "*.. " }         {
        #idée : check maj sur github. lors du Gameover puis télécharger la MAJ sur un fichier temporaire, vérifier le HASH puis remplacer le bot par nouvelle version et effacer le fichier temp
        write-host "On va faire la MAJ avec ça" -ForegroundColor Magenta
        #On télécharge le fichier mis à jour
        #https://github.com/Airone23/BOT-FRX/releases/download/v1/BOT_ameliore.ps1
        Invoke-WebRequest -Uri $URL -OutFile $botpath
        Foreach-object {
             write-host "+---- Download ----+" -fore yellow}{
             write-host "|" -ForegroundColor Yellow -no
             Write-Host "   Download ok!   " -ForegroundColor Blue -NoNewline
             write-host "|" -ForegroundColor Yellow 
        }{   write-host "+------------------+"-fore yellow}


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
write-host "salut je suis à jour"
#powershell $botpath
