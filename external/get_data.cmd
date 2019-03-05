@echo OFF
set TABLE=url_lighthouse_data
set DATABASE=url_lighthouse_data.sqlite
set QUERY=select * from %TABLE%  where status = 'false' limit 1

sqlite3.exe -batch -csv -ascii -cmd "%QUERY%" %DATABASE% 
