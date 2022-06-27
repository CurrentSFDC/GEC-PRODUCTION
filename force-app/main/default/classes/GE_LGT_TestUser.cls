/***********************************************************************************************
*   Controller Name : GE_LGT_TestUser
*   Date            : 
*   Author          : MahindraSatyam
*   Called By       : All GE LGT Test Classes
*   Purpose         : This class will return Profile ID, Role and Applicant Information required for all
*                     GE LGT Test Classes.
*                      
*   Change History  :
*   Date                      Developer              Reason 
*   --------------------      -------------------    -------------------------
*                                         
**************************************************************************************************/ 

public class GE_LGT_TestUser
{
  public static User getNewUser()
  {
    Id profileID = getProfileId();
    Id roles = getRoleId(); 
    User aUser = new User( Email='test-user@fakeemail.com',Title='GELGT',ProfileId = profileid, UserName='test-user@fakeemail.com', Alias='tuser1', CommunityNickName='tuser1',TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User');
    insert aUser;
    return aUser;
  }

  public static ID getProfileId()
  {
    return [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
  }

  public static ID getRoleId()
  {
    return [SELECT Id FROM UserRole WHERE Name = 'Application Administrator'].Id; 
  }
}