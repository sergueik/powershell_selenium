# based on: https://toster.ru/q/653216
function slurpArs {
    param(
        [Parameter (Mandatory = $true, Position = 0)] $first_param,
        [Switch]$debug_me,
        [Parameter (ValueFromRemainingArguments)] $other_params,
        [Switch]$debug_too
    )

  $debug_arg = $false
  if ([bool]$PSBoundParameters['debug_me'].IsPresent) {
    $debug_arg = $true
  }
  if ( [bool]$PSBoundParameters['debug_too'].IsPresent ) {
    $debug_arg = $true
  }
  if ($DebugPreference -eq 'Continue') {
    write-output 'PSBoundParameters :'
    write-output $PSBoundParameters.keys
  }
  write-output ('First param: {0}' -f $first_param )
  write-output ('Debug switch: {0}' -f $debug_arg )
  write-output ('All other params: {0}' -f ($other_params -join ','))
  # will print System.Collections.Generic.List`1[System.Object]
  write-output ('Other param (not really): {0}' -f $other_params)
  write-output ('Other params (will lose the index 1+): {0}' -f ($other_params -replace '\s+', ','))
}

# Validation

write-output "Callig: slurpArs -first 'first' -debug_me 'param1' 'param2'  'parame3'"

slurpArs -first 'first' -debug_me 'param1' 'param2'  'parame3'
write-output "Calling: slurpArs 'first' -debug_me 'param1' 'param2'  'parame3'"

slurpArs 'first' -debug_me 'param1' 'param2'  'parame3'

write-output "Calling: slurpArs 'first' 'param1' 'param2'  'parame3'"
slurpArs 'first' 'param1' 'param2'  'parame3'

write-output "Calling: slurpArs 'first' 'param1' 'param2'  'parame3' -debug_too"
slurpArs 'first' 'param1' 'param2'  'parame3' -debug_too

