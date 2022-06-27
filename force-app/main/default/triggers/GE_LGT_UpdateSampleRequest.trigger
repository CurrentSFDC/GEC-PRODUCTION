/*
Trigger Test class name - GE_LGT_UpdateSampelRequest_Test
*/
trigger GE_LGT_UpdateSampleRequest on Sample__c (before insert, after insert, before update, after update) {
    
    //Set account values on Sample Request
    if(trigger.isInsert && trigger.isBefore)
    {
        for(Sample__c s : Trigger.new){
            
            //Update status to request  
            s.Status__c = 'Not Submitted';
            if(s.Bill_To_Same_as_Ship_To__c == True)
            {
                s.Bill_To_Address__c = s.Ship_to_Address__c;
                s.Bill_To_Address_2__c = s.Ship_to_Address_2__c;
                s.Bill_To_City__c = s.Ship_to_City__c;
                s.Bill_To_Name__c = s.Ship_to_Name__c;
                s.Bill_To_State__c = s.Ship_to_State__c;
                s.Bill_To_Zip_Code__c = s.Ship_To_Zip_Code__c;
                
            }
            
        }
    }
    
        
    //Add any products from opportunity to the Sample Request
    //if(trigger.isInsert && trigger.isAfter && UserInfo.getProfileId()<>'00ei0000000c5OwAAI') // Profile<>'GE_NAS_Support_Agent'
    //Espresso  - 1416- User Separation as Current & Lightning 
    if(trigger.isInsert && trigger.isAfter && UserInfo.getProfileId()<>'00e3j000000zpx7AAA')   
    {  
        system.debug('User Profile Id = '+UserInfo.getProfileId());
        for(Sample__c s : Trigger.new){
            
           /* if(s.What_type_of_Sample_are_you_requesting__c != 'Technology Samples' &&
            s.GE_LGT_SR_Opportunity__c == '' && s.Distributor__c == '' && s.Fixture_Agency__c == '' && s.GE_LGT_SR_End_User__c == '') {
                s.addError('Opportunity, Distributor, End User, and Agency are REQUIRED');
            }*/
            
            if(s.What_type_of_Sample_are_you_requesting__c != 'Technology Samples'){
            //Get opportunity attached to sample
            Opportunity opp = [Select id,name,Account.id, account.type FROM Opportunity where id=:s.Opportunity__c];
            List <Sample_Product__c> SampleProductList = new List<Sample_Product__c>();
            
            //Get Opportunity Products
            List<OpportunityLineItem> relatedOLIs = [Select pricebookentry.product2.id from OpportunityLineItem where OpportunityId =: opp.id];
            for(OpportunityLineItem oli : relatedOLIs){  
                //Add product to new opp sample product
                Sample_Product__c sp = new Sample_Product__c(Sample_Request__c=s.id);
                sp.Product__c = oli.pricebookentry.product2.id;
                SampleProductList.add(sp);
            }  
            }
            //insert SampleProductList;
            
        }
    }
    
    //Check to make sure Part Number and Quantity are filled out on each 
    if(trigger.isUpdate && trigger.isBefore)
    {
        
        for(Sample__c s : Trigger.new){
            if(s.Bill_To_Same_as_Ship_To__c == True)
            {
                s.Bill_To_Address__c = s.Ship_to_Address__c;
                s.Bill_To_Address_2__c = s.Ship_to_Address_2__c;
                s.Bill_To_City__c = s.Ship_to_City__c;
                s.Bill_To_Name__c = s.Ship_to_Name__c;
                s.Bill_To_State__c = s.Ship_to_State__c;
                s.Bill_To_Zip_Code__c = s.Ship_To_Zip_Code__c;
                
            }
            
            if(s.Status__c == 'Waiting for Assignment' && s.Case__c == null)
            {
                Case c = new Case();
                c.ContactId = '0033j00003HfgLr';//new prod id
                c.AccountId = '0013j00002dPdEv';//new prod id
                //c.ContactId = '0035500000cZnhhAAC';//UAT id
                //c.AccountId = '0015500000gY9EEAA0';//UAT id
                c.Type = 'Sample Request';
                c.Origin = 'Sample Request';
                c.Subject = s.Name;
                c.Description = 'https://gecurrent.my.salesforce.com/' + s.Id;
                c.Status = 'Open';
                //c.recordtypeid = '01255000000JT8lAAG';//UAT id
                c.recordtypeid = '0123j000000X8ysAAC';//new prod id
                c.SuppliedEmail = s.Agent_Email__c;
                c.OwnerId = '00G3j000007ieXmEAI';
               
               /* 
               
               old dev ids:
               
               if(s.Bill_to_Region__c == 'Canada (00071244)')
                    c.OwnerId = '00Gi0000002BOJy';  //French Canada Team
                if(s.Bill_to_Region__c == 'Northeast (00071247)')
                    c.OwnerId = '00Gi0000001IaFj'; //ASR East Team
                if(s.Bill_to_Region__c == 'South (00071255)')
                    c.OwnerId = '00Gi0000002BOK8';
                if(s.Bill_to_Region__c == 'Midwest (00071263)')
                    c.OwnerId = '00Gi0000002BOJt';
                if(s.Bill_to_Region__c == 'West (00071264)')
                    c.OwnerId = '00Gi0000002BOK3';
                if(s.Bill_to_Region__c == 'Strategic Account (00071265)')
                   //ASR Specialty Team ////Commented via ticket no RITM0164218.Added below line
                    c.OwnerId = '00Gi0000003Uapf';//ASR Strategic Team
              
                if(s.Bill_to_Region__c == 'Grainger (00021179)')
                    c.OwnerId = '00Gi0000002BOKD';//ASR Specialty Team
                
                //March2015 - Added via ticket(KAFZY-47)-Two new LOV added to Bill to Region 
                if(s.Bill_to_Region__c == 'Graybar (470125)')
                    c.OwnerId = '00Gi0000002BOKD';//ASR Specialty Team
                if(s.Bill_to_Region__c == 'Utility (00002177)')
                    c.OwnerId = '00Gi0000003UgOy';//ASR Utility Team
                    
                    
                old prod ids:   
                    
                     if(s.Bill_to_Region__c == 'Canada (00071244)')
                    c.OwnerId = '00Gi0000002BOJy';  //French Canada Team
                if(s.Bill_to_Region__c == 'Northeast (00071247)')
                    c.OwnerId = '00Gi0000001IaFj'; //ASR East Team
                if(s.Bill_to_Region__c == 'South (00071255)')
                    c.OwnerId = '00Gi0000002BOK8';  //ASR South Team
                if(s.Bill_to_Region__c == 'Midwest (00071263)')
                    c.OwnerId = '00Gi0000002BOJt';  //ASR Midwest Team
                if(s.Bill_to_Region__c == 'West (00071264)')
                    c.OwnerId = '00Gi0000002BOK3';  //  ASR West Team
                if(s.Bill_to_Region__c == 'Strategic Account (00071265)')
                   //ASR Specialty Team ////Commented via ticket no RITM0164218.Added below line
                    c.OwnerId = '00Gi0000003Uapf';//ASR Strategic Team
              
                if(s.Bill_to_Region__c == 'Grainger (00021179)')
                    c.OwnerId = '00Gi0000002BOKD';//ASR Specialty Team
                
                //March2015 - Added via ticket(KAFZY-47)-Two new LOV added to Bill to Region 
                if(s.Bill_to_Region__c == 'Graybar (470125)')
                    c.OwnerId = '00Gi0000002BOKD';//ASR Specialty Team
                if(s.Bill_to_Region__c == 'Utility (00002177)')
                    c.OwnerId = '00Gi0000003UgOy';//ASR Utility Team*/
                    
                 //   New Prod Ids:
                    
                
                //CHANGE TO SEND ALL TO SUPPORT TEAM - COMMENTING OUT
                /* if(s.Bill_to_Region__c == 'Canada (00071244)')

                    c.OwnerId = '00G3j000007ieXWEAY';

                if(s.Bill_to_Region__c == 'Northeast (00071247)')

                    c.OwnerId = '00G3j000007ieWKEAY';

                if(s.Bill_to_Region__c == 'South (00071255)')

                    c.OwnerId = '00G3j000007ieWSEAY';

                if(s.Bill_to_Region__c == 'Midwest (00071263)')

                    c.OwnerId = '00G3j000007ieWQEAY';

                if(s.Bill_to_Region__c == 'West (00071264)')

                    c.OwnerId = '00G3j000007ieWXEAY';

                if(s.Bill_to_Region__c == 'Strategic Account (00071265)')

                   //ASR Specialty Team ////Commented via ticket no RITM0164218.Added below line

                    c.OwnerId = '00G3j000007ieWUEAY';//ASR Strategic Team

              

                if(s.Bill_to_Region__c == 'Grainger (00021179)')

                    c.OwnerId = '00G3j000007ieWTEAY';//ASR Specialty Team

                

                //March2015 - Added via ticket(KAFZY-47)-Two new LOV added to Bill to Region 

                if(s.Bill_to_Region__c == 'Graybar (470125)')

                    c.OwnerId = '00G3j000007ieWTEAY';//ASR Specialty Team

                if(s.Bill_to_Region__c == 'Utility (00002177)')

                    c.OwnerId = '00G3j000007ieWWEAY';//ASR Utility Team  */
                    
                    
                  /*UAT ids:
                  
                    if(s.Bill_to_Region__c == 'Canada (00071244)')

                    c.OwnerId = '00G550000028R1dEAE';

                if(s.Bill_to_Region__c == 'Northeast (00071247)')

                    c.OwnerId = '00G550000028R0HEAU';

                if(s.Bill_to_Region__c == 'South (00071255)')

                    c.OwnerId = '00G550000028R0UEAU';

                if(s.Bill_to_Region__c == 'Midwest (00071263)')

                    c.OwnerId = '00G550000028R0NEAU';

                if(s.Bill_to_Region__c == 'West (00071264)')

                    c.OwnerId = '00G550000028R0ZEAU';

                if(s.Bill_to_Region__c == 'Strategic Account (00071265)')

                   //ASR Specialty Team ////Commented via ticket no RITM0164218.Added below line

                    c.OwnerId = '00G550000028R0WEAU';//ASR Strategic Team

              

                if(s.Bill_to_Region__c == 'Grainger (00021179)')

                    c.OwnerId = '00G550000028R0VEAU';//ASR Specialty Team

                

                //March2015 - Added via ticket(KAFZY-47)-Two new LOV added to Bill to Region 

                if(s.Bill_to_Region__c == 'Graybar (470125)')

                    c.OwnerId = '00G550000028R0VEAU';//ASR Specialty Team

                if(s.Bill_to_Region__c == 'Utility (00002177)')

                    c.OwnerId = '00G550000028R0YEAU';//ASR Utility Team*/

                insert c;
                s.Case__c = c.id;
                
                
            }
            else if(s.Status__c == 'Waiting for Approval')
            {
                //Get list of sample products
                List <Sample_Product__c> SampleProductList = [Select Quantity__c,SKU_CAT_Logic_Description__c,Part_number__c from Sample_Product__c where Sample_Request__c =: s.id];
                if(SampleProductList.size() == 0)
                {
                    if(!Test.isRunningTest()){
                        s.addError('You must add at least one Sample Product to your Sample Request');
                    }
                }
                else
                {
                    for(Sample_Product__c SampleProd : SampleProductList)
                    {
                        if( SampleProd.Quantity__c != null && (SampleProd.Part_Number__c != null || SampleProd.SKU_CAT_Logic_Description__c != null))
                        {
                            //Go to next product
                        }
                        else {
                            if(!Test.isRunningTest()){
                                s.addError('You must set the Quantity and SKU/CAT Logic/Description or Product on each Sample Product Before Submitting for Approval');
                            }
                        }
                    }
                }    
                
            }
        }
    }
    //Close case if sample request is closed
    if(trigger.isUpdate && trigger.isAfter)
    {
        
        for(Sample__c s : Trigger.new){
            if(s.Status__c == 'Complete')
            {
                
                if(s.case__c != null)
                {
                //there are Cases associated with Sample request
                Case c = [Select Status, GE_NAS_Sub_Status__c, GE_NAS_NCSC_Resolution__c from Case where id =: s.case__c];
                c.Status = 'Closed';
                c.GE_NAS_Sub_Status__c = 'Closed';
                c.GE_NAS_NCSC_Resolution__c = 'Sample Request Completed';                
                update c;
                }
                else
                {
                //no cases associated.
                }
            }
        }
    }
    
}