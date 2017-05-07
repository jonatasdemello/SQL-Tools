IF exists (SELECT * FROM dbo.sysobjects WHERE ID = object_id(N'[dbo].[fn_GetDiaUtil]'))
DROP FUNCTION [dbo].[fn_GetDiaUtil]
GO

CREATE function dbo.fn_GetDiaUtil (@DateStartSup smalldatetime , @Dias int)  
RETURNS smalldatetime  
AS  

-- pega o proximo dia util, N dias depois da data fornecida

BEGIN  
	Declare @Start Int  
	Declare @Count Int  
	Declare @DateStart Datetime  

	Select @DateStart = Dateadd(Day,1,@DateStartSup),  @Count = 0, @Start = 0  

	While @Count < @Dias  
	Begin  
		If DatePart(WeekDay, @DateStart) Not In (7,1) And @DateStart Not In ( Select FEdata from Feriados )  
		Select @Count = @Count + 1  
		Select @DateStart = Dateadd(day,1,@DateStart), @Start = @Start + 1  
	End  
	RETURN  DateAdd(day,@Start,@DateStartSup)  
END