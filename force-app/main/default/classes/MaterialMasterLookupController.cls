//Material Master Lookup Controller
//The following apex class is connected to the MaterialMasterLookupPopup Page to enable data to be passed to the front end to show users
public with sharing class MaterialMasterLookupController 
{
    //Rashmitha Changed the API vesion from 36 to 45 on 6-Mar-2019 as per 1447 request
    //Initializing variables to hold data
    public integer totalCount {get;set;}
    public String query {get; set;}
    public integer recordLimit {get; set;}
    public integer recordOffSet {get; set;}
    public String prodHierarchyFilter {get; set;}
    public List<GE_LGT_EM_MaterialMaster__c> SKUs
    {
        get {
            prodHierarchyFilter = ApexPages.currentPage().getParameters().get('prodHierarchy');
            if(prodHierarchyFilter != ''){
                prodHierarchyFilter += '%';
                if (SKUs == null){
                    if (query != null) {
                        String SearchString = '%' + query + '%';
                        totalCount =database.countQuery('SELECT count() FROM GE_LGT_EM_MaterialMaster__c  WHERE  GE_LGT_EM_ProductHierarchy__c LIKE :prodHierarchyFilter AND (GE_LGT_EM_MaterialDescription__c LIKE :SearchString OR GE_LGT_EM_SAP_MaterialNumber__c LIKE :SearchString)');
                    } else {
                        totalCount =database.countQuery('SELECT count() FROM GE_LGT_EM_MaterialMaster__c  WHERE GE_LGT_EM_ProductHierarchy__c LIKE :prodHierarchyFilter');
                    }
                    recordLimit =10;
                    recordOffSet=0;
                }
                if (query != null) {
                    String SearchString = '%' + query + '%';
                    SKUs = [SELECT Id,Name, GE_LGT_EM_SAP_MaterialNumber__c, GE_LGT_EM_ProductHierarchy__c, GE_LGT_EM_MaterialDescription__c FROM GE_LGT_EM_MaterialMaster__c  WHERE  GE_LGT_EM_ProductHierarchy__c LIKE :prodHierarchyFilter AND (GE_LGT_EM_MaterialDescription__c LIKE :SearchString OR GE_LGT_EM_SAP_MaterialNumber__c LIKE :SearchString) Limit :recordLimit offset :recordOffSet];
                } else {
                    SKUs = [SELECT Id,Name, GE_LGT_EM_SAP_MaterialNumber__c, GE_LGT_EM_ProductHierarchy__c, GE_LGT_EM_MaterialDescription__c FROM GE_LGT_EM_MaterialMaster__c  WHERE GE_LGT_EM_ProductHierarchy__c LIKE :prodHierarchyFilter Limit :recordLimit offset :recordOffSet];
                }
                return SKUs;
            }
            return null;
        }
        set;
    }
    public PageReference runQuery()
    {   
        SKUs=null;
        return null;
    }
    //Boolean to check if there are more records after the present displaying records
    public Boolean hasNext
    {
        get
        {
            return recordOffSet+recordLimit > totalCount ? true: false;
        }
        set;
    }
    //Boolean to check if there are more records before the present displaying records
    public Boolean hasPrevious
    {
        get
        {
            return recordOffSet-recordLimit < 0 ? true: false;
        }
        set;
    }
    //Returns the previous page of records
    public void previous()
    {
        recordOffSet=recordOffSet-recordLimit<=0 ? 0 : recordOffSet-recordLimit;
    }
    //Returns the next page of records
    public void next()
    {
        recordOffSet=recordOffSet+recordLimit>totalcount ? totalCount-recordLimit: recordOffSet +recordLimit;
    }
}