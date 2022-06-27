/*
Name - SC013_connectRelatedAccountRefresh
Author - Matthew Gugumuck
Purpose - Schedule class of BA_012_TermAndPromoAgreementsCreate
Created Date - September 2021
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By             Date            Comments

*/
global class SC013_connectRelatedAccountRefresh  implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        BA_13_connectRelatedAccountRefresh connectRefresh = new BA_13_connectRelatedAccountRefresh();
        Database.executeBatch(connectRefresh, 1);
    }
    
}