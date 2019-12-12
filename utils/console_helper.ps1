#Copyright (c) 2019 Serguei Kouzmine
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

<#
Usage:
powershell.exe -executionpolicy bypass -file console_helper.ps1
REM run the batch command without mouse interruptions
powershell.exe -executionpolicy bypass -file console_helper.ps1 -enable

#>
param(
  [switch]$enable
)

Add-Type -Language 'VisualBasic' -TypeDefinition @'
' based on:
' http://forum.oszone.net/thread-325464.html
' purpose: dis/enable simple mouse click-to-select that may pause the console window
' that may be busy running a lengthy batch process

Imports System
Public Class Helper

  Declare Function GetStdHandle   Lib "kernel32" (ByVal nStdHandle As Integer) As Integer
  Declare Function GetConsoleMode Lib "kernel32" (ByVal hConsoleHandle As Integer, ByRef lpMode As Integer) As Integer
  Declare Function SetConsoleMode Lib "kernel32" (ByVal hConsoleHandle As Integer, ByVal dwMode As Integer) As Integer

  Public Const STD_INPUT_HANDLE As Integer = -10&

  Sub ModifyConsoleMode(ByVal allowMouseSelection As Boolean)
    Dim hConsole As Integer
    Dim iMode As Integer
    Dim bSuccess As Integer

    hConsole = GetStdHandle(STD_INPUT_HANDLE)
    bSuccess = GetConsoleMode(hConsole, iMode)
    If allowMouseSelection = True Then
      bSuccess = SetConsoleMode(hConsole, iMode Or &H40)
    Else
      bSuccess = SetConsoleMode(hConsole, iMode And Not &H40)
    End If

  End Sub
End Class

'@

$object = New-Object -TypeName 'Helper'

if ([bool]$PSBoundParameters['enable'].IsPresent) {
  $object.ModifyConsoleMode($true)
} else {
  $object.ModifyConsoleMode($false)
}

<#
# original code:
# http://forum.oszone.net/thread-325464.html
Add-Type -Language 'VisualBasic' -TypeDefinition @'
' c:\Windows\Microsoft.NET\Framework\v2.0.50727\vbc.exe "ConsoleMode.vb" /target:exe /nologo /verbose
Imports System

Module mainModule
  Declare Function GetStdHandle   Lib "kernel32" (ByVal nStdHandle As Integer) As Integer
  Declare Function GetConsoleMode Lib "kernel32" (ByVal hConsoleHandle As Integer, ByRef lpMode As Integer) As Integer
  Declare Function SetConsoleMode Lib "kernel32" (ByVal hConsoleHandle As Integer, ByVal dwMode As Integer) As Integer

  Public Const STD_INPUT_HANDLE As Integer = -10&

  Sub Main()
    Dim hConsole As Integer
    Dim iMode As Integer
    Dim bSuccess As Integer

    hConsole = GetStdHandle(STD_INPUT_HANDLE)
    bSuccess = GetConsoleMode(hConsole, iMode)
    bSuccess = SetConsoleMode(hConsole, iMode And Not &H40)
  End Sub
End Module
'@
#>

