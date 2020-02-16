Install-Module BurntToast
$Logo = "C:\$env:HOMEPATH\Pictures\logo.jfif"
New-BurntToastNotification -AppLogo $Logo -Text "Shutdown Notification" , "Attention ça va couper ;)" -Sound Alarm6