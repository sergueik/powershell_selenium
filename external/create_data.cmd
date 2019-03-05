@echo OFF
set TABLE=url_lighthouse_data
set DATABASE=url_lighthouse_data.sqlite
set QUERY=select * from %TABLE%  where status = 'false' limit 1
type "create_data.txt" | sqlite3.exe %DATABASE%
