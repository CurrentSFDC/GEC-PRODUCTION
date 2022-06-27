/*
Name - SC012_TermAndPromoAgreements
Author - Matthew Gugumuck
Purpose - Schedule class of BA_012_TermAndPromoAgreementsCreate
Created Date - September 2021
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By             Date            Comments

*/
global class SC012_TermAndPromoAgreements  implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        BA_012_TermAndPromoAgreementsCreate termAndPromo = new BA_012_TermAndPromoAgreementsCreate();
        Database.executeBatch(termAndPromo, 1);
    }
    
}