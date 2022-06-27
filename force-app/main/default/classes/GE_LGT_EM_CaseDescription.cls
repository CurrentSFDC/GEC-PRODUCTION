/*
###########################################################################
# File..................:GE_LGT_EM_CaseDescription
# Version...............: 1.0
# Created by............:Jojan,Murugan,Snehil
# Created Date..........: 
# Description...........: This class is used for getting case object description mapped to complaintLineItem object description based on current pageparameters id.  
#                         
#               
*/


public with sharing class GE_LGT_EM_CaseDescription {

//getting current page id
    Id complaintId = System.currentPageReference().getParameters().get('id');
    
    public GE_LGT_EM_CaseDescription(ApexPages.StandardController controller) {

    }
    public GE_LGT_EM_ComplaintLineItem__c searchDescription {get;set;}
    
    public PageReference searchDescription() {
        system.debug('Id **************' + complaintId );
        searchDescription= [select GE_LGT_EM_CaseNumber__r.Description from GE_LGT_EM_ComplaintLineItem__c where id =:complaintId];
        system.debug('searchDescription **********'+searchDescription);

        return null;
    }
}