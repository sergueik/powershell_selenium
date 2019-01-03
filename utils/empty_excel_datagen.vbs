' origin: http://forum.script-coding.com/viewtopic.php?id=6837
' prerequisite: COM server dll for 'ADODB.Connection'
Option Explicit

Const adUseClient = 3 : Const adSchemaTables = 20 : Const adSchemaColumns = 4
Const adDouble = 5, adDate = 7, adCurrency = 6, adBoolean = 11, adVarWChar = 202, adLongVarWChar = 203

Dim oConn
Set oConn = CreateObject("ADODB.Connection")
With oConn
  .Provider = "Microsoft.Jet.OLEDB.4.0"
  .Properties("Extended Properties").Value = "Excel 8.0;"
  .CursorLocation = adUseClient
  .Open "cbook3.xls"
End With

Dim oRs
Set oRs = oConn.Execute("SELECT * FROM TestTable")

Do While Not (oRs.EOF)
  wscript.echo "[" & oRs("Col1").Value & "]; [" & oRs("Col2").Value & "]"
  oRs.MoveNext
Loop

Set oRs = Nothing
Set oConn = Nothing
