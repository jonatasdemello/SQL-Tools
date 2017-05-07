
--sp_changeobjectowner is how to change the owner of an object. 
--sp_changedbowner is how to change the owner of the db itself, 

--not the objects in the db. :) 


exec sp_changeobjectowner [ @objname = ] 'object' , [ @newowner = ] 'owner'

EXEC sp_changeobjectowner 'authors', 'Corporate\GeorgeW'

EXEC sp_changeobjectowner 'sistema_W05.LIC_Licitacoes', 'dbo'