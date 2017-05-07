
exec CriarProcedures aganual



select [id],[name] from dbo.sysobjects where OBJECTPROPERTY(id, N'IsUserTable') = 1 order by [name]

select sc.*
	--sc.[name],sc.[xtype],st.[name], sc.[length], sc.[prec], sc.[scale]
from dbo.syscolumns sc 
inner join dbo.systypes st on sc.[xtype]=st.[xtype]
where sc.[id] = 2062734501
order by colorder

2091258605 


select * from systypes order by 1

2091258605
AGAnual	


/*
select a.id, b.indid, a.name, b.name, c.name, c.xtype, c.length, d.name, c.xprec, c.xscale
from sysobjects a, sysindexes b, syscolumns c, systypes d
where a.type = 'U'
and a.id = b.id
and b.indid = 1
and a.id = c.id
and c.xtype = d.xtype
*/
--sp_help syscolumns
--select * from systypes

IF EXISTS(SELECT id FROM sysobjects WHERE type = 'P' and name = 'CriarProcedures')
  DROP PROCEDURE CriarProcedures
GO

CREATE PROC CriarProcedures

AS 

DECLARE @idtabela int,
 @nometabela varchar(256),
 @nomelimpo varchar(256),
 @nomecoluna varchar(256),
 @xtype tinyint,
 @length smallint,
 @nometipo varchar(256),
 @xprec tinyint,
 @xscale tinyint,
 @scale tinyint,
 @virgula varchar(10),
 @virgula2 varchar(10),
 @linha varchar(2000),
 @campos varchar(2000),
 @valores varchar(2000)

PRINT '------------ COPIE O TEXTO ABAIXO PARA A JANELA DE EXECUÇÃO DO QUERY ANALYZER -------------'
PRINT ''
PRINT ''
PRINT ''

DECLARE tabelas CURSOR 
FOR 
SELECT a.id, a.name
FROM sysobjects a
WHERE a.type = 'U'

OPEN tabelas

FETCH NEXT FROM tabelas
INTO @idtabela, @nometabela

WHILE @@FETCH_STATUS = 0 
BEGIN


-- STORED PROCEDURE DE EXCLUSÃO

DECLARE @condicoes varchar(2000),
 @final varchar(2000)

  PRINT '-- SE A STORED PROCEDURE sp_Excluir_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7) + ' EXISTIR, DELETA-LA'
  PRINT 'IF EXISTS(SELECT id FROM sysobjects WHERE type = ''P'' and name = ''sp_Excluir_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7) + ''')'
  PRINT '  DROP PROCEDURE sp_Excluir_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7)
  PRINT 'GO'
  PRINT '' 
  PRINT '--STORED PROCEDURE PARA EXCLUIR REGISTROS DA TABELA ' + @nometabela
  PRINT 'CREATE PROCEDURE sp_Excluir_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7)

  DECLARE colunas CURSOR
  FOR 
    SELECT c.name, c.xtype, c.length, d.name, c.xprec, c.xscale, d.scale
    FROM sysobjects a, sysindexes b, syscolumns c, systypes d, sysindexkeys e
    WHERE a.id = @idtabela
    AND a.id = b.id
    AND b.indid = 1
    AND c.colid = e.colid
    AND a.id = c.id
    AND a.id = e.id
    AND c.xtype = d.xtype

  OPEN colunas

  FETCH NEXT FROM colunas
  INTO @nomecoluna, @xtype, @length, @nometipo, @xprec, @xscale, @scale

  SELECT @condicoes = 'WHERE '

  WHILE @@FETCH_STATUS = 0 
  BEGIN
    IF @scale IS NULL
      IF @xtype = 35 OR @xtype = 99 -- SE FOR TEXT OU NTEXT
        SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo
      ELSE
        SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo + '(' + convert(varchar(10),@length) + ')'
    ELSE
      IF @scale = 0 
        SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo
      ELSE
 IF @xtype = 60 OR @xtype = 122 OR @xtype = 61 -- SE FOR MONEY OU SMALLMONEY OU DATETIME
          SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo 
 ELSE
          SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo + '(' + convert(varchar(10),@xprec) + ', ' + convert(varchar(10),@xscale) + ')'

    SELECT @condicoes = @condicoes + @nomecoluna + ' = ' + '@' + @nomecoluna 
 
    FETCH NEXT FROM colunas
    INTO @nomecoluna, @xtype, @length, @nometipo, @xprec, @xscale, @scale
    IF @@FETCH_STATUS = 0
      BEGIN 
 SELECT @virgula = ', '
        SELECT @final = char(13) + 'AND   '  
      END
    ELSE
      BEGIN 
 SELECT @virgula = ''
        SELECT @final = ''  
      END

    PRINT @linha + @virgula
    SELECT @condicoes = @condicoes + @final
 
  END

  CLOSE colunas

  DEALLOCATE colunas

  PRINT ''
  PRINT 'AS'
  PRINT ''

  PRINT 'DELETE FROM ' + @nometabela 
  PRINT @condicoes
  PRINT ''
  PRINT 'GO'
  PRINT ''
  PRINT ''

-- STORED PROCEDURE PARA ALTERAÇÃO
-- ALTERA TODOS OS CAMPOS, EXCETO OS QUE FAZEM PARTE DA CHAVE PRIMARIA

DECLARE @idcoluna smallint,
 @alterar varchar(2000),
 @flag char(1),
 @nrocondicoes int,
 @nroalteracoes int,
 @condicoesaux varchar(2000),
 @alteraraux varchar(2000)

  PRINT '-- SE A STORED PROCEDURE sp_Alterar_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7) + ' EXISTIR, DELETA-LA'
  PRINT 'IF EXISTS(SELECT id FROM sysobjects WHERE type = ''P'' and name = ''sp_Alterar_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7) + ''')'
  PRINT '  DROP PROCEDURE sp_Alterar_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7)
  PRINT 'GO'
  PRINT '' 
  PRINT '-- STORED PROCEDURE PARA ALTERAR REGISTROS NA TABELA ' + @nometabela
  PRINT 'CREATE PROCEDURE sp_Alterar_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7)

  DECLARE colunas CURSOR
  FOR 
    SELECT c.name, c.xtype, c.length, d.name, c.xprec, c.xscale, d.scale, c.colid
    FROM syscolumns c, systypes d
    WHERE c.id = @idtabela
    AND   c.xtype = d.xtype

  OPEN colunas

  FETCH NEXT FROM colunas
  INTO @nomecoluna, @xtype, @length, @nometipo, @xprec, @xscale, @scale, @idcoluna

  SELECT @nrocondicoes = 0
  SELECT @nroalteracoes = 0

  SELECT @condicoes = 'WHERE '
  SELECT @alterar = 'SET '

  WHILE @@FETCH_STATUS = 0 
  BEGIN
    IF @scale IS NULL
      IF @xtype = 35 OR @xtype = 99 -- SE FOR TEXT OU NTEXT
        SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo
      ELSE
        SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo + '(' + convert(varchar(10),@length) + ')'
    ELSE
      IF @scale = 0 
        SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo
      ELSE
 IF @xtype = 60 OR @xtype = 122 OR @xtype = 61 -- SE FOR MONEY OU SMALLMONEY OU DATETIME
          SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo 
 ELSE
          SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo + '(' + convert(varchar(10),@xprec) + ', ' + convert(varchar(10),@xscale) + ')'
    IF EXISTS (SELECT y.name, x.name
     FROM syscolumns x, sysobjects y
     WHERE y.id = @idtabela
     AND x.colid = @idcoluna
     AND x.colid not in (SELECT c.colid
           FROM sysobjects a, sysindexes b, syscolumns c, systypes d, sysindexkeys e
           WHERE a.id = @idtabela
           AND c.colid = @idcoluna
           AND a.id = b.id
           AND b.indid = 1
           AND c.colid = e.colid
           AND a.id = c.id
           AND a.id = e.id
           AND c.xtype = d.xtype))
      BEGIN
--        SELECT @alterar = @alterar + @nomecoluna + ' = ' + '@' + @nomecoluna 
        SELECT @alteraraux = @nomecoluna + ' = ' + '@' + @nomecoluna 
        SELECT @flag = 'A'
        SELECT @nroalteracoes = @nroalteracoes + 1
      END
    ELSE
      BEGIN
--        SELECT @condicoes = @condicoes + @nomecoluna + ' = ' + '@' + @nomecoluna 
        SELECT @condicoesaux = @nomecoluna + ' = ' + '@' + @nomecoluna 
        SELECT @flag = 'C'
        SELECT @nrocondicoes = @nrocondicoes + 1
      END

    FETCH NEXT FROM colunas
    INTO @nomecoluna, @xtype, @length, @nometipo, @xprec, @xscale, @scale, @idcoluna
    IF @@FETCH_STATUS = 0
      BEGIN 
 SELECT @virgula = ', '
        SELECT @virgula2 = ', ' + char(13) + '    '
        SELECT @final = char(13) + 'AND   '  
      END
    ELSE
      BEGIN 
 SELECT @virgula = ''
        SELECT @virgula2 = ', ' + char(13) + '    '
        SELECT @final = char(13) + 'AND   '
      END

    PRINT @linha + @virgula
    IF @flag = 'A'
      IF @nroalteracoes > 1 
        SELECT @alterar = @alterar + @virgula2 + @alteraraux
      ELSE
        SELECT @alterar = @alterar + @alteraraux
    ELSE
      IF @nrocondicoes > 1 
        SELECT @condicoes = @condicoes + @final + @condicoesaux 
      ELSE
        SELECT @condicoes = @condicoes + @condicoesaux
  END

  CLOSE colunas

  DEALLOCATE colunas

  PRINT ''
  PRINT 'AS'
  PRINT ''

  IF DATALENGTH(@alterar) > 4 
    BEGIN
      PRINT 'UPDATE ' + @nometabela + ' ' --+ @campos + ')'
      PRINT @alterar
      PRINT @condicoes
    END
  ELSE 
    BEGIN
      PRINT 'PRINT ''NÃO É POSSIVEL ALTERAR REGISTROS DE UMA TABELA''' 
      PRINT 'PRINT ''ONDE TODOS OS CAMPOS SÃO PARTE DA CHAVE PRIMÁRIA'''
    END
  PRINT ''
  PRINT 'GO'
  PRINT ''
  PRINT ''


-- STORED PROCEDURE DE INCLUSÃO
  PRINT '-- SE A STORED PROCEDURE sp_Incluir_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7) + ' EXISTIR, DELETA-LA'
  PRINT 'IF EXISTS(SELECT id FROM sysobjects WHERE type = ''P'' and name = ''sp_Incluir_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7) + ''')'
  PRINT '  DROP PROCEDURE sp_Incluir_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7)
  PRINT 'GO'
  PRINT '' 
  PRINT '-- STORED PROCEDURE PARA INCLUIR REGISTROS NA TABELA ' + @nometabela
  PRINT 'CREATE PROCEDURE sp_Incluir_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7)

  DECLARE colunas CURSOR
  FOR 
    SELECT c.name, c.xtype, c.length, d.name, c.xprec, c.xscale, d.scale
    FROM syscolumns c, systypes d
    WHERE c.id = @idtabela
    AND   c.xtype = d.xtype

  OPEN colunas

  FETCH NEXT FROM colunas
  INTO @nomecoluna, @xtype, @length, @nometipo, @xprec, @xscale, @scale

  SELECT @campos = '('
  SELECT @valores = '('

  WHILE @@FETCH_STATUS = 0 
  BEGIN
    IF @scale IS NULL
      IF @xtype = 35 OR @xtype = 99 -- SE FOR TEXT OU NTEXT
        SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo
      ELSE
        SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo + '(' + convert(varchar(10),@length) + ')'
    ELSE
      IF @scale = 0 
        SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo
      ELSE
 IF @xtype = 60 OR @xtype = 122 OR @xtype = 61 -- SE FOR MONEY OU SMALLMONEY OU DATETIME
          SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo 
 ELSE
          SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo + '(' + convert(varchar(10),@xprec) + ', ' + convert(varchar(10),@xscale) + ')'

    SELECT @campos = @campos + @nomecoluna
    SELECT @valores = @valores + '@' + @nomecoluna

    FETCH NEXT FROM colunas
    INTO @nomecoluna, @xtype, @length, @nometipo, @xprec, @xscale, @scale
    IF @@FETCH_STATUS = 0 
 SELECT @virgula = ', '
    ELSE
 SELECT @virgula = ''

    PRINT @linha + @virgula
    SELECT @campos = @campos + @virgula
    SELECT @valores = @valores + @virgula
 
  END

  CLOSE colunas

  DEALLOCATE colunas

  PRINT ''
  PRINT 'AS'
  PRINT ''

  PRINT 'IF NOT EXISTS (SELECT * FROM ' + @nometabela + ' ' + REPLACE(@condicoes, char(13) + 'AND  ',' AND') + ')'
  PRINT ''
  PRINT '  INSERT ' + @nometabela + @campos + ')'
  PRINT '  VALUES ' + @valores + ')'
  PRINT ''
  PRINT 'GO'
  PRINT ''
  PRINT ''

-- STORED PROCEDURE DE CONSULTA

  PRINT '-- SE A STORED PROCEDURE sp_Consultar_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7) + ' EXISTIR, DELETA-LA'
  PRINT 'IF EXISTS(SELECT id FROM sysobjects WHERE type = ''P'' and name = ''sp_Consultar_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7) + ''')'
  PRINT '  DROP PROCEDURE sp_Consultar_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7)
  PRINT 'GO'
  PRINT '' 
  PRINT '--STORED PROCEDURE PARA CONSULTAR REGISTROS DA TABELA ' + @nometabela
  PRINT 'CREATE PROCEDURE sp_Consultar_' + UPPER(SUBSTRING(@nometabela, 7, 1)) + RIGHT(@nometabela, DATALENGTH(@nometabela) - 7)

  DECLARE colunas CURSOR
  FOR 
    SELECT c.name, c.xtype, c.length, d.name, c.xprec, c.xscale, d.scale
    FROM sysobjects a, sysindexes b, syscolumns c, systypes d, sysindexkeys e
    WHERE a.id = @idtabela
    AND a.id = b.id
    AND b.indid = 1
    AND c.colid = e.colid
    AND a.id = c.id
    AND a.id = e.id
    AND c.xtype = d.xtype

  OPEN colunas

  FETCH NEXT FROM colunas
  INTO @nomecoluna, @xtype, @length, @nometipo, @xprec, @xscale, @scale

  SELECT @condicoes = 'WHERE '

  WHILE @@FETCH_STATUS = 0 
  BEGIN
    IF @scale IS NULL
      IF @xtype = 35 OR @xtype = 99 -- SE FOR TEXT OU NTEXT
        SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo
      ELSE
        SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo + '(' + convert(varchar(10),@length) + ')'
    ELSE
      IF @scale = 0 
        SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo
      ELSE
 IF @xtype = 60 OR @xtype = 122 OR @xtype = 61 -- SE FOR MONEY OU SMALLMONEY OU DATETIME
          SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo 
 ELSE
          SELECT @linha = '@' + @nomecoluna + ' ' + @nometipo + '(' + convert(varchar(10),@xprec) + ', ' + convert(varchar(10),@xscale) + ')'

    SELECT @condicoes = @condicoes + @nomecoluna + ' = ' + '@' + @nomecoluna 
 
    FETCH NEXT FROM colunas
    INTO @nomecoluna, @xtype, @length, @nometipo, @xprec, @xscale, @scale
    IF @@FETCH_STATUS = 0
      BEGIN 
 SELECT @virgula = ', '
        SELECT @final = char(13) + 'AND   '  
      END
    ELSE
      BEGIN 
 SELECT @virgula = ''
        SELECT @final = ''  
      END

    PRINT @linha + @virgula
    SELECT @condicoes = @condicoes + @final

  END

  CLOSE colunas

  DEALLOCATE colunas

  PRINT ''
  PRINT 'AS'
  PRINT ''

  PRINT 'SELECT * FROM ' + @nometabela 
  PRINT @condicoes
  PRINT ''
  PRINT 'GO'
  PRINT ''
  PRINT ''

  FETCH NEXT FROM tabelas
  INTO @idtabela, @nometabela

END

CLOSE tabelas

DEALLOCATE tabelas

GO


