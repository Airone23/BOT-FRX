Install-Module BurntToast
Import-Module BurntToast
$base64=""

$Logo = "C:\$env:HOMEPATH\Pictures\logo.jfif"

#on convertit l'image en base 64 en string
$bytes = [Convert]::FromBase64String($base64)

#on écrit le résultat dans un fichier dans le dossiers images
[IO.File]::WriteAllBytes($filename, $bytes)

#On déclenche la notification
New-BurntToastNotification -AppLogo $Logo -Text "Shutdown Notification" , "Attention ça va couper ;)" -Sound Alarm6
