DECLARE @Step int = 1

step_0:

	print  '... do stuff'
	
	if @Step = 1 goto step_1
	if @Step = 2 goto step_2
	if @Step = 3 goto step_3

goto done;

step_1:
	--use dev
	print  'use dev'
	set @Step = @Step +1
	goto step_0
	
step_2:
	--use test
	print  'use test'
	set @Step = @Step +1
	goto step_0

step_3:
	--use uat
	print  'use uat'
	set @Step = @Step +1
	goto step_0

	
done:
	print  '- done'
	