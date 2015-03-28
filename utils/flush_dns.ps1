$target_server = ''
function flush_dns{

$command = 'C:\Windows\System32\ipconfig.exe /flushdns'
# $command = 'C:\Windows\System32\ipconfig.exe /all'
$result = (invoke-expression -command $command  )
write-output $result 
} 

$remote_run_step = invoke-command -computer $target_server -ScriptBlock ${function:flush_dns} 

write-output $remote_run_step 
