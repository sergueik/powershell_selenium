# based on: http://forum.oszone.net/thread-355077.html
# TODO: fix poor variable naming and usage
# see also: https://github.com/dfinke/ImportExcel
Param(
	$path1 = 'source.xls',
	$path2 = 'template.xlsx',
	$path3 = 'result.xlsx',
	$worksheet1 =  'sheet1',
	$worksheet2 =  'sheet2',
	$range1 = 'A7:CY1006',
	$range2 = 'A7',
	$range3 = 'CZ7:CZ1006',
	$range4 = 'DA7',
	$range5 = 'CZ7',
	$country = 'value'
)
Copy-Item $path2 $path3
$excel = New-Object -ComObject Excel.Application
$workbookSource = $excel.Workbooks.Open($path1)
$rangeToCopy = $workbookSource.Worksheets[$worksheet1].Range($range1)
$workbookTarget = $excel.Workbooks.Open($path3)
$targetSheet = $workbookTarget.Worksheets[$worksheet2]
$rangeToCopy.Copy($targetSheet.Range($range2))
$rangeToCopy = $workbookSource.Worksheets[$worksheet1].Range($range3)
$rangeToCopy.Copy($targetSheet.Range($range4))
$rangeToFill = $targetSheet.Range($range5)
$rangeToFill.Value = $country
$workbookTarget.Save()
$workbookSource.Close()
$workbookTarget.Close()
$excel.Quit()

