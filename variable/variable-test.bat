@rem sqlcmd -S 127.0.0.1 -i "variable.sql" -v environment=Dev

sqlcmd -S %1 -i "variable-test.sql" -v environment=%2 