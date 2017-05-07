create  Procedure sp_cons_eventos_ordem
(
@Status int,
@inicio datetime,
@fim datetime,
@ordenacao int,
@regiao int
)
as

if @ordenacao in (0,1)

	SELECT Eventos.EVId, Eventos.EVnumeroevento,Eventos.EVNrAditivo, 
	    Eventos.EVdatainicio, Eventos.EVdata,Eventos.EVstatus, Nivel7.N7Descricao, 
	    Municipios.MUNome, CAST (Instrutores.INNome AS VARCHAR) COLLATE SQL_Latin1_General_CP1_CI_AS
--Instrutores.INNome
	FROM Regioes 
	    INNER JOIN Supervisores ON Regioes.REID = Supervisores.SURegiao 
	    INNER JOIN Eventos 
	    INNER JOIN Curso ON Eventos.EVCurso = Curso.CRId 
	    INNER JOIN Municipios ON Eventos.EVMunicipios = Municipios.IDENTITYCOL 
	    INNER JOIN Conveniados ON Eventos.EVConveniado = Conveniados.CONId 
	    INNER JOIN Nivel7 ON Curso.CRCodni7 = Nivel7.N7Id ON Regioes.REID = Municipios.MURegiao
	    INNER join Instrutores ON instrutores.INid = Eventos.EVCodigoInstrutor
	
	WHERE (Eventos.EVStatus = @status ) AND (Municipios.MURegiao = @regiao) AND
	      (Eventos.EVDatainicio >= @inicio ) AND (Eventos.EVDatainicio <= @fim ) AND
	      (Supervisores.SUAtivo = 0)

ORDER BY CASE @ordenacao
            WHEN 0 THEN Eventos.EVNumeroevento
            WHEN 1 THEN Instrutores.INNome
        END,
		CASE @ordenacao
            WHEN 0 THEN Eventos.EVDatainicio
            WHEN 1 THEN Eventos.EVDatainicio
		end
else
	select * from eventos
go

/*
For implicit conversion of varchar value to varchar do the following:
Cast(Field_Name As Varchar) COLLATE <Collation Name>

Ex:
ISNULL(CAST (surname AS VARCHAR) COLLATE SQL_Latin1_General_CP1_CI_AS,'')
*/


/* teste Dynamic SQL */
CREATE TABLE blat 
( 
    blatID INT, 
    hits INT, 
    firstname VARCHAR(3), 
    email VARCHAR(9) 
) 
GO 
 
SET NOCOUNT ON 
INSERT blat VALUES(1, 12, 'bob', 'bob@x.com') 
INSERT blat VALUES(2, 8,  'sue', 'sue@x.com') 
INSERT blat VALUES(3, 17, 'pat', 'pat@x.com') 
INSERT blat VALUES(4, 4,  'pam', 'pam@x.com') 
INSERT blat VALUES(5, 1,  'jen', 'jen@x.com') 
INSERT blat VALUES(6, 3,  'rod', 'rod@x.com') 
INSERT blat VALUES(7, 5,  'nat', 'nat@x.com') 
INSERT blat VALUES(8, 19, 'rob', 'rob@x.com') 
INSERT blat VALUES(9, 24, 'jan', 'jan@x.com') 
INSERT blat VALUES(10, 0, 'meg', 'meg@x.com') 
GO

select * from blat

DECLARE @col VARCHAR(9) 
SET @col = 'firstname' 
 
IF @col IN ('firstname', 'email') 
    SELECT * FROM blat 
        ORDER BY CASE @col 
            WHEN 'firstname' THEN firstname 
            WHEN 'email' THEN email 
        END 
ELSE 
    SELECT * FROM blat 
GO 



DECLARE @col VARCHAR(9) 
SET @col = 'hits' 
 
    SELECT * FROM blat 
        ORDER BY 
        CASE @col 
            WHEN 'firstname' THEN firstname 
            WHEN 'email' THEN email 
        END, 
        CASE @col 
            WHEN 'blatID' THEN blatID 
            WHEN 'hits' THEN hits 
        END 
GO


DROP TABLE blat 
GO
