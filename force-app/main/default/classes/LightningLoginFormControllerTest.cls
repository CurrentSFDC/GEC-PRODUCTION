@IsTest
public with sharing class LightningLoginFormControllerTest {

 @IsTest
 static void LightningLoginFormControllerInstantiation() {
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null);
 }

 

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
 }

 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
 }

 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
     //sagar changes
    
    @IsTest
 static void TestsetExperienceId() {
    LightningLoginFormController.setExperienceId('123');
 }
     @IsTest
 static void TestgetForgotPasswordUrl() {
   LightningLoginFormController.getForgotPasswordUrl();
        }
    
    @IsTest
    static void Testlogin() {
         LightningLoginFormController.login('Test','Test@123', 'www.test.com');
        
    }
}