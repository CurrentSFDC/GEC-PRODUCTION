@isTest(Seealldata=True)
public class SetUserCreateDate_Test
{ 
 static testMethod void UserCreateDate()
    {  
        // INSERT User RECORD
      User MyUser = new User(FirstName='TestUser',LastName='Test',Email = 'Testuser@ge.com',GE_LGT_Business_Division__c = 'Europe',Username = 'Testuser@ge.com',UserRoleId ='00Ei0000000YISNEA4');

       try{
       Test.StartTest();
         insert MyUser;
       }catch(Exception ext) {
        Boolean expectedExceptionThrown =  ext.getMessage().contains('Error') ? true : false;
        System.AssertEquals(expectedExceptionThrown, false);    
           }
       Test.StopTest();
    }      
}