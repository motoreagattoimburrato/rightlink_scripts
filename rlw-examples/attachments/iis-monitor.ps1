# Collect following metrics using WMI queries:
# -IIS Anonymous Users per Second
# -IIS Connection Attempts per Second
# -IIS Current Connections
# -IIS Get Requests per Second
# -IIS Logon Attempts per Second
# -IIS Non-Anonymous Users per Second
# -IIS Not Found Errors per Second
# -IIS Post Requests per Second
# -IIS Total Bytes Received
# -IIS Total Bytes Sent
# -IIS Inetinfo Handle Count
# -IIS Inetinfo Percent Processor Time
#
# Data is passed back to TSS in plain text protocol similar to one used in Exec plugin for collectd
# (see https://collectd.org/wiki/index.php/Plain_text_protocol#PUTVAL)

while ($True) {
  $res =  Get-WmiObject -Query "Select * from Win32_PerfRawData_W3SVC_WebService where Name='_Total'"
  $nowT = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
  if ($res) {
    Write-Host "PUTVAL $Env:COLLECTD_HOSTNAME/IIS/iis_bytes-per-sec interval=$Env:COLLECTD_INTERVAL ${nowT}:$($res.BytesReceivedPerSec):$($res.BytesSentPerSec)"
    Write-Host "PUTVAL $Env:COLLECTD_HOSTNAME/IIS/requests-sec interval=$Env:COLLECTD_INTERVAL ${nowT}:$($res.TotalMethodRequests)"
    Write-Host "PUTVAL $Env:COLLECTD_HOSTNAME/IIS/anonymous-users interval=$Env:COLLECTD_INTERVAL ${nowT}:$($res.TotalAnonymousUsers)"
    Write-Host "PUTVAL $Env:COLLECTD_HOSTNAME/IIS/non-anonymous-users interval=$Env:COLLECTD_INTERVAL ${nowT}:$($res.TotalNonAnonymousUsers)"
    Write-Host "PUTVAL $Env:COLLECTD_HOSTNAME/IIS/connection-attempts interval=$Env:COLLECTD_INTERVAL ${nowT}:$($res.TotalConnectionAttemptsallinstances)"
    Write-Host "PUTVAL $Env:COLLECTD_HOSTNAME/IIS/not-found-errors interval=$Env:COLLECTD_INTERVAL ${nowT}:$($res.TotalNotFoundErrors)"
    Write-Host "PUTVAL $Env:COLLECTD_HOSTNAME/IIS/logon-attempts interval=$Env:COLLECTD_INTERVAL ${nowT}:$($res.TotalLogonAttempts)"
  }
  $res = Get-WmiObject -Query "Select PercentProcessorTime, ThreadCount from Win32_PerfRawData_PerfProc_Process where name='w3wp'"
  if ($res) {
    Write-Host "PUTVAL $Env:COLLECTD_HOSTNAME/IIS/w3wp-percent-processor-time interval=$Env:COLLECTD_INTERVAL ${nowT}:$($res.PercentProcessorTime)"
    Write-Host "PUTVAL $Env:COLLECTD_HOSTNAME/IIS/w3wp-thread-count interval=$Env:COLLECTD_INTERVAL ${nowT}:$($res.ThreadCount)"
  }
  Sleep $Env:COLLECTD_INTERVAL
}
