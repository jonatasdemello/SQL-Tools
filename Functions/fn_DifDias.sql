/*
 Primeiramente declaramos que vamos criar uma fun��o, 
 neste caso se chama Dif Dias e recebe dois par�metros, 
 a data inicial do per�odo e a final
*/ 

IF exists (SELECT * FROM dbo.sysobjects WHERE ID = object_id(N'[dbo].[fn_DifDias]'))
DROP FUNCTION [dbo].[fn_DifDias]
GO

CREATE FUNCTION dbo.fn_DifDias( @StartDate DATETIME, @EndDate DATETIME ) 
RETURNS integer 
AS 
Begin 

	-- conta o sabado ( domingo e feriado NAO )

--//Com esta variavel calculamos quantos dias "normais" existem na classe de datas 

DECLARE @DaysBetween INT 

--//Com esta variavel acumulamos os dias totais 

DECLARE @BusinessDays INT 

--//esta variavel nos serve de contador para saber quando chegarmos ao ultimo dia da classe 

DECLARE @Cnt INT 

/*esta variavel eh a que comparamos para saber se o dia que esta calculando eh sabado ou domingo*/ 

DECLARE @EvalDate DATETIME 

/*Estas duas variaveis servem para comparar as duas datas, se sao iguais, a funcao nos regressa um 0*/ 

DECLARE @ini VARCHAR(10) 
DECLARE @fin VARCHAR(10) 

--//Iniciamos algumas variaveis 

SELECT @DaysBetween = 0 
SELECT @BusinessDays = 0 
SELECT @Cnt=0 

--//Calculamos quantos dias normais existem na classe de datas 

SELECT @DaysBetween = DATEDIFF(DAY,@StartDate,@EndDate) + 1 

/*Ordenamos o formato das datas para que n�o importando como se proporcionem se comparem igual*/ 

SELECT @ini = (SELECT CAST((CAST(datepart(dd,@StartDate)AS 
	VARCHAR(2))+'/'+ CAST(datepart(mm,@StartDate)AS 
	VARCHAR(2))+'/'+CAST(datepart(yy,@StartDate)AS VARCHAR(4))) as 
	varchar(10))) 
	SELECT @fin = (SELECT CAST((CAST(datepart(dd,@EndDate)AS 
	VARCHAR(2))+'/'+ CAST(datepart(mm,@EndDate)AS VARCHAR(2))+'/'+ 
	CAST(datepart(yy,@EndDate)AS VARCHAR(4)))as varchar(10))) 

--//Comparam-se as duas datas 

IF @ini <>@fin 
BEGIN 

/*Se a diferenca de datas for igual a dois, eh porque so foi transcorrido um dia, portanto somente se valida de que nao vai marcar dias de mais*/ 

IF @DaysBetween = 2 
 BEGIN 
	SELECT @BusinessDays = 1 
 END 
ELSE 
 BEGIN 
	WHILE @Cnt < @DaysBetween 
 BEGIN 

/*Iguala-se a data que vamos calcular para saber se eh sabado ou domingo na variavel @EvalDate somando os dias que marque o contador, o qual nao deve ser maior que o numero total de dias que existem na classe de datas*/ 

SELECT @EvalDate = @StartDate + @Cnt 

/*Utilizando a funcao datepart com o parametro dw que calcula que dia da semana corresponde uma data determinada, determinados que nao seja sabado (7) ou domingo (1)*/ 

IF ((datepart(dw,@EvalDate) <> 1) and (datepart(dw,@EvalDate) <> 7) ) 
BEGIN 

/*Se nao eh sabado ou domingo, entao se soma um ao total de dias que queremos desdobrar*/ 

SELECT @BusinessDays = @BusinessDays + 1 
END 

--//Soma-se um dia a mais ao contador 

SELECT @Cnt = @Cnt + 1 
END 
END 
END 
ELSE 
BEGIN 

--//Se fosse certo que as datas eram iguales se desdobraria em zero 

SELECT @BusinessDays = 0 
END 

--//Ao finalizar o ciclo, a funcao regressa o numero total de dias 

return (@BusinessDays) 
END 