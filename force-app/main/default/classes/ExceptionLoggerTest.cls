@IsTest
private class ExceptionLoggerTest {

	@IsTest
	private static void exceptionLogTest(){
		try{
			CalloutException e = (CalloutException)CalloutException.class.newInstance();
			e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
			throw e;
		}catch (System.CalloutException cex){
			ExceptionLogger.newExceptionLog(cex,'ExceptionLoggerTest','exceptionLogTest');
			List<ExceptionLog__c> els=[Select Id From ExceptionLog__c];
			System.assertEquals(1, els.size());
        }
	}

	@TestSetup
	static void setupTestData(){
		ExceptionLoggingFramework__c elf = new ExceptionLoggingFramework__c();
		elf.Enabled__c=true;
		elf.EmailNotificationEnabled__c=true;
        elf.Emails__c='abc@gecurrent.com';
		insert elf;
	}

}