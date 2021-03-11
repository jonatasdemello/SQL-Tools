/************************************************************************
* Objetivo: Associa os usuarios de um database a seu respectivo			*
* login.																*
*             															*
* ATENÇÃO: O LOGIN E O USUÁIO DENTRO DA BASE DEVEM TER O MESMO NOME 	*
*																		*
* Autor: Nilton Pinheiro												*
* Website: www.mcdbabrasil.com.br										*
*																		*		
* Funciona com SQL Server 2000/2005										*	 
************************************************************************/

-- ATENçÂO: Pode default varre todos os dbs. 
-- Para verificar um banco específico troque SET @db = NULL por pelo nome do db desejado
-- Exemplo: SET @db = 'Pubs'

USE MASTER
GO
SET NOCOUNT ON
--> Declaracao de Variaveis
DECLARE @sql 	nvarchar(1000)
DECLARE @User	sysname
DECLARE @db	varchar(30)

SET @db = NULL

CREATE TABLE #tbUsuarios (usuarios sysname)
IF @db is not null -- Para um db específico
BEGIN
	SET @sql = 'SELECT usu.name FROM '+@db+'.dbo.sysusers usu  
				LEFT OUTER JOIN master.dbo.syslogins lo 
				ON usu.sid = lo.sid
	  			WHERE (usu.islogin = 1 AND usu.isaliased = 0 AND usu.hasdbaccess = 1)
				AND lo.loginname is null'
	INSERT INTO #tbUsuarios exec sp_executesql @sql	
	IF exists(SELECT usuarios FROM #tbUsuarios)
	BEGIN
		SELECT @User = min(usuarios) from #tbUsuarios
		WHILE @User is not null
		BEGIN
			SELECT @sql = @db+'.dbo.sp_change_users_login ''Update_One'','''+ @User + ''','''+ @User +''''
			EXEC sp_executesql @sql
			SET @sql = 'O usuário '''+ @User +''' do database '''+@db +''' foi associado ao seu login '''+@User+''''
			Print @sql
			SELECT @User = min(usuarios) from #tbUsuarios where usuarios > @User			
		END
	END
END
ELSE
BEGIN
	-- Pesquisa em todos os dbs
	SELECT @db = min(name) from master.dbo.sysdatabases where name not in ('tempdb', 'pubs', 'msdb', 'NorthWind', 'master','model')
	WHILE @db is not null
	BEGIN
		SET @sql = 'SELECT usu.name FROM '+@db+'.dbo.sysusers usu  
				LEFT OUTER JOIN master.dbo.syslogins lo 
				ON usu.sid = lo.sid
	  			WHERE (usu.islogin = 1 AND usu.isaliased = 0 AND usu.hasdbaccess = 1)
				AND lo.loginname is null'	
		INSERT INTO	#tbUsuarios exec sp_executesql @sql
		IF exists(SELECT usuarios FROM #tbUsuarios)
		BEGIN
			SELECT @User = min(usuarios) from #tbUsuarios
			WHILE @User is not null
			BEGIN
				SET @sql = @db+'..sp_change_users_login ''Update_One'','''+ @User + ''','''+ @User +''''
				EXEC sp_executesql @sql
				SET @sql = 'O usuário '''+ @User +''' do database '''+@db +''' foi associado ao seu login '''+@User+''''
				Print @sql
				SELECT @User = min(usuarios) from #tbUsuarios where usuarios > @User				
			END
		END
		DELETE #tbUsuarios
		SELECT @db = min(name) FROM master.dbo.sysdatabases WHERE name not in ('tempdb', 'pubs', 'msdb', 'NorthWind', 'master','model')
		AND Name > @db
	END
END
GO
DROP TABLE #tbUsuarios