print '*** {debug} environment: $(environment)'

IF EXISTS(SELECT 1 WHERE 'Dev' = '$(environment)')
begin
	print '*** do stuff in dev'
end
ELSE
begin
	print '*** do other stuff not in dev'
end

