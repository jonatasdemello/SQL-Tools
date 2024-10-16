

SELECT @@VERSION

SELECT  
	SERVERPROPERTY('productversion'), 
	SERVERPROPERTY ('productlevel'), 
	SERVERPROPERTY ('edition')

/*
SQL Server 2005 

Os resultados são:
•A versão do produto (por exemplo, "9.00.1399.06").
•O nível do produto (por exemplo, "RTM").
•A edição (por exemplo, "Enterprise Edition").
Por exemplo, o resultado deve ser similar a:Recolher esta tabelaExpandir esta tabela9.00.1399.06 RTM Enterprise Edition 
A seguinte tabela lista o número de versão do Sqlservr.exe: Recolher esta tabelaExpandir esta tabelaLançamento Sqlservr.exe 
RTM 2005.90.1399 
SQL Server 2005 Service Pack 1 2005.90.2047 


SQL Server 2000 

Os resultados são:
•A versão do produto (por exemplo, 8.00.534).
•O nível do produto (por exemplo, "RTM" ou "SP2").
•A edição (por exemplo, "Standard Edition"). Por exemplo, o resultado deve ser similar a:

8.00.534 RTM Standard Edition
A seguinte tabela lista o número de versão do Sqlservr.exe:Recolher esta tabelaExpandir esta tabelaLançamento Sqlservr.exe 
RTM 2000.80.194.0 
SQL Server 2000 SP1 2000.80.384.0 
SQL Server 2000 SP2 2000.80.534.0 
SQL Server 2000 SP3 2000.80.760.0 
SQL Server 2000 SP3a 2000.80.760.0 
SQL Server 2000 SP4 2000.8.00.2039 


SQL Server 7.0

Número da Versão Service Pack 
7.00.1063 SQL Server 7.0 Service Pack 4 (SP4) 
7.00.961 SQL Server 7.0 Service Pack 3 (SP3) 
7.00.842 SQL Server 7.0 Service Pack 2 (SP2) 
7.00.699 SQL Server 7.0 Service Pack 1 (SP1) 
7.00.623 SQL Server 7.0 RTM (Release To Manufacturing) 

*/
