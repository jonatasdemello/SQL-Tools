CREATE FUNCTION dbo.RetornaDataJuliana(@Dia Int, @Mes Int, @Ano Int)  
RETURNS INT
/*Retorna Data Juliana*/
AS  

BEGIN 
	DECLARE @dtJuliana int
	SELECT @dtJuliana = (@Ano - 1) * 365 - @Ano/100 + @Ano/400 + (@Ano - 1 ) / 4 

		IF @Mes > 2 AND ( ( @Ano%100 <> 0 AND @Ano%4 = 0 ) OR @Ano%400 = 0 ) 
			SELECT @dtJuliana = @dtJuliana + 1 
			SELECT @dtJuliana = @dtJuliana + 31 * ( @Mes - 1 ) + @Dia
		IF ( @Mes > 2 ) 
			SELECT @dtJuliana = @dtJuliana - 3 
		IF ( @Mes > 4 )  
			SELECT @dtJuliana = @dtJuliana -  1       
		IF ( @Mes > 6 ) 
			SELECT @dtJuliana = @dtJuliana - 1 
		IF ( @Mes > 9 ) 
			SELECT @dtJuliana = @dtJuliana - 1 
		IF ( @Mes > 11 ) 
			SELECT @dtJuliana = @dtJuliana - 1 

	RETURN @dtJuliana
END

CREATE FUNCTION dbo.retornaDataGregoriana(@DataJuliana int)  
RETURNS datetime 
/*Retorna data Gregoriana a partir de data Juliana*/
AS  

BEGIN 
	RETURN(DATEADD(DAY,@DataJuliana - 722815, '1/1/80')) 
END

-- mostrar

select dbo.retornaDataGregoriana('08085')