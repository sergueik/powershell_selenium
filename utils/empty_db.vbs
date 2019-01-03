' origin: http://forum.script-coding.com/viewtopic.php?id=6837
' prerequisite : COM server of 'ADOX.Catalog'
Option Explicit
Const adDouble = 5, adDate = 7, adCurrency = 6, adBoolean = 11, adVarWChar = 202, adLongVarWChar = 203

Dim cat
Dim tbl
Dim col
Set cat = Createobject("ADOX.Catalog")
cat.ActiveConnection = "Provider=Microsoft.Jet.OLEDB.4.0;" & _
                        "Data Source=cbook3.xls;Extended Properties=Excel 8.0"
Set tbl = Createobject("ADOX.Table")
tbl.Name = "TestTable"
Set col = Createobject("ADOX.Column")
With col
    .Name = "Col1"
    .Type = adVarWChar
End With
tbl.Columns.Append col
Set col = Nothing
Set col = Createobject("ADOX.Column")
With col
    .Name = "Col2"
    .Type = adVarWChar
End With
tbl.Columns.Append col
cat.Tables.Append tbl

Dim i, oRs, oCon, oCmd
Set oCon = cat.ActiveConnection

For i = 1 To 10
  Set oRs = oCon.Execute("INSERT INTO TestTable VALUES ('"& i & "', '" & i*2 & "')")
Next

Set oRs = Nothing
Set oCon = Nothing
Set col = Nothing
Set tbl = Nothing
Set cat = Nothing
