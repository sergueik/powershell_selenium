param(
  [String]$command = 'Help: Command=Help',
  [String]$filepath = $null
)
# https://rkeithhill.wordpress.com/2014/11/01/windows-powershell-and-named-pipes/
# https://manual.audacityteam.org/man/scripting_reference.html
function do_command {
  param(
    [String]$command = 'Help: Command=Help'
  )

  $pipe_out = new-object System.IO.Pipes.NamedPipeClientStream('.', 'ToSrvPipe', [System.IO.Pipes.PipeDirection]::Out)
  $pipe_out.Connect()
  $pipe_writer = new-object System.IO.StreamWriter($pipe_out)
  $pipe_writer.AutoFlush = $true

  $pipe_in = new-object System.IO.Pipes.NamedPipeClientStream('.', 'FromSrvPipe', [System.IO.Pipes.PipeDirection]::In)
  $pipe_in.Connect()
  $pipe_reader = new-object System.IO.StreamReader($pipe_in)
  $pipe_writer.WriteLine($command)
  while (($result =  $pipe_reader.Readline()) -notmatch "BatchCommand finished") {
    write-output $result
    $has_result = $true
  }

  $pipe_in.Dispose()
  $pipe_out.Dispose()
}


if (($filepath -ne $null ) -and ($filepath -ne '' ) -and (test-path -path "${filepath}" )) {
  do_command -command ('Import2: Filename="{0}"' -f $filepath )
  do_command 'Export2:'
} else {
  do_command -command $command
}
