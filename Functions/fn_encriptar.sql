SET NOCOUNT ON
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fn_Encriptar' AND xtype = 'FN')
DROP FUNCTION dbo.fn_Encriptar
GO

CREATE FUNCTION dbo.fn_Encriptar
(@Password VARCHAR(20))
RETURNS VARCHAR(100)
--WITH ENCRYPTION 
AS
/*
** Autor Rodrigo Acosta
** Creation 10/07/03
** Ultima Modificacion --
** Encripts de password
*/
BEGIN
	/* Declaracion de variables */
	DECLARE @LenPassword AS INT,		-- Cantidad de caracteres en la password
		@Letra AS CHAR(1),		-- Guarda cada letra de la contraseña para encriptarla
		@I AS INT,			-- Contador
		@PassEncript AS VARCHAR(100)	-- Guarda y devuelve la contraseña encriptada

	/* seteo de variables */	
	SELECT @I = 1			
	SELECT @LenPassword = LEN(@Password)
	SELECT @PassEncript = ''

	/* loop que termina cuando llega al ultimo caracter de la password */
	WHILE @I < @LenPassword + 1
	BEGIN
		/* por cada letra, se suma 3 al caracter ASCII y luego la pasa a letra nuevamente */
		SELECT @Letra = CONVERT(CHAR(1),CHAR(CONVERT(INT,ASCII(SUBSTRING(@Password, @I, @I + 1))) +3))

		/* va formando la pass */
		SELECT @PassEncript = @PassEncript + ISNULL(@Letra, '0')
		
		/* aumenta el contador */
		SELECT @I = @I + 1
	END
	
	/* invierte la password encriptada */
	SELECT @PassEncript = REVERSE(@PassEncript)

	/* devuelve la password */
	RETURN @PassEncript
	
END
GO
