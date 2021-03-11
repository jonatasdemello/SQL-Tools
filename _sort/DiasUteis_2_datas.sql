
/* Funcão para calcular o numero de dias uteis entre 2 datas */

select * from feriados

	-- este conta dias corridos (inclusive domingos) = 11
select datediff(d, '2010-06-07', '2010-06-18')


	-- com o ultimo INCLUSIVE - apenas DIAS UTEIS
select dbo.fn_DiasUteis ('2010-06-07', '2010-06-18') --9
select dbo.fn_DiasUteis ('2010-06-01', '2010-06-18')

	-- conta o sabado / domingo e feriado NAO
select dbo.fn_DifDias('2010-06-07', '2010-06-18') as dias -- 10
select dbo.fn_DifDias('2010-06-01', '2010-06-18') as dias -- 14

	-- pega o proximo dia util, N dias depois da data fornecida
select dbo.fn_GetDiaUtil('2010-06-07', 5) -- 14 seg-feira


grant execute on dbo.fn_GetDiaUtil to helpdesk
grant execute on dbo.fn_DifDias to helpdesk
grant execute on dbo.fn_DiasUteis to helpdesk

sp_helpuser
 


dbo.fn_DiasUteis( @DataInicial datetime, @DataFinal datetime)

dbo.fn_DifDias(@StartDate DATETIME,@EndDate DATETIME) 

dbo.fn_GetDiaUtil (@DateStartSup smalldatetime , @Dias int)  