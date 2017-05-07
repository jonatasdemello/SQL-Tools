IF exists (SELECT * FROM dbo.sysobjects WHERE ID = object_id(N'[dbo].[fn_DiasUteis]'))
	DROP FUNCTION [dbo].[fn_DiasUteis]
GO

CREATE FUNCTION dbo.fn_DiasUteis( @DataInicial datetime, @DataFinal datetime)
RETURNS int
AS
BEGIN
	
-- com o ultimo INCLUSIVE - apenas DIAS UTEIS

-- Cria função para calcular dias úteis entre duas datas informadas

-- Cria variaveis
DECLARE @Feriados int, @Retorno int, @DiasAUX int, @DataAUX datetime

-- Seta primeiro dia da semana em domingo
--SET DATEFIRST 7
--SET DATEFIRST 1

-- Monta cursor
DECLARE CursorFeriado CURSOR FOR
	SELECT count(*) 'Total' FROM Feriados 
		WHERE FEdata between @DataInicial + 1 AND @DataFinal AND DATEPART(dw, FEdata) not in (1, 7)

-- Abre cursor
OPEN CursorFeriado

-- Pega primeiro
FETCH NEXT FROM CursorFeriado INTO @Feriados

-- Seta dias úteis como 0
SET @Retorno = DateDiff(d, @DataInicial, @DataFinal)

-- Seta data auxiliar para cálculos
SET @DataAUX = @DataFinal

-- Contabiliza dias úteis
WHILE @DataInicial <= @DataAUX
BEGIN
-- Se for final de semana, desconsidera do total
IF DATEPART(dw, @DataAUX) in (1, 7)
BEGIN
SET @Retorno = @Retorno - 1
END

-- Subtrai um da data auxiliar
SET @DataAUX = @DataAUX - 1
END

-- Corrige caso data inicial seja um FDS
IF DATEPART(dw, @DataInicial) in (1, 7)
BEGIN
SET @Retorno = @Retorno + 1
END

-- Fecha cursor
CLOSE CursorFeriado
DEALLOCATE CursorFeriado

-- Desconsidera os feriados
SET @Retorno = @Retorno - @Feriados
RETURN(@RETORNO)

END 
