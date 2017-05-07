
sp_CONFIGURE 'show advanced', 1
GO
RECONFIGURE
GO
sp_CONFIGURE 'Database Mail XPs', 1
GO
RECONFIGURE
GO 

/*  test email  */
/*
Account:	account_W14
Profile:	MailProfileW14
*/

USE msdb
GO
EXEC sp_send_dbmail @profile_name='MailProfileW14',
@recipients='jonatas@senarpr.org.br',
@subject='Test message',
@body='This is the body of the test message.' 

