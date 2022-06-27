/***********************************************************************************************
*   Trigger Name    : GE_LGT_EM_PreventDuplMatMasters 
*   Date            : 09/14/2015
*   Author          : Shyam Prasad -- Tech Mahindra
*   Object          : GE_LGT_EM_MaterialMaster__c
*   Purpose         : For checking duplicates based on SAP Material Number. If SAP number don't 
Exist in Salesforce then a new reocrd is inserted otherwise all the fields 
will be updated for old record with same SAP Material Number.
**************************************************************************************************/
trigger GE_LGT_EM_PreventDuplMatMasters on GE_LGT_EM_MaterialMaster__c (before insert,after insert,before update) 
{
    GE_LGT_EM_PreventDuplMatMasters_Helper helper=new GE_LGT_EM_PreventDuplMatMasters_Helper();
    if(trigger.isInsert && trigger.isAfter)
    {
        List<GE_LGT_EM_MaterialMaster__c> matMasterList=new List<GE_LGT_EM_MaterialMaster__c>();
        Map<ID,GE_LGT_EM_MaterialMaster__c> matMasterToUpdate=new Map<ID,GE_LGT_EM_MaterialMaster__c>();
        Map<String,ID> matMasterToDelete=new Map<String,ID>();
        List<ID> matMasToDelete=New List<ID>();
        
        //This code is to delete the duplicate materials if SAP contains duplicates.
        Map<String,GE_LGT_EM_MaterialMaster__c> matMasterMap=new Map<String,GE_LGT_EM_MaterialMaster__c>();
        List<ID> matMasToDelete1=New List<ID>();
        for(GE_LGT_EM_MaterialMaster__c m:Trigger.new)
        {
            if((!matMasterMap.containsKey(m.GE_LGT_EM_SAP_MaterialNumber__c)))
            {
                matMasterMap.put(m.GE_LGT_EM_SAP_MaterialNumber__c, m);
            }
            else
            {
                matMasToDelete1.add(m.Id);
            }
        }
        Database.delete(matMasToDelete1);
        
        //The below code is for getting the Materials with the same Material Number and update the old records if they exists in Salesforce and delete new records with same SAP number
        if(matMasterMap!=NULL)
        {
            matMasterList=[SELECT Id,GE_LGT_EM_SAP_MaterialNumber__c,GE_LGT_EM_ProductHierarchy__c,GE_LGT_EM_MaterialDescription__c,GE_LGT_EM_Base_Unit_Measure__c,GE_LGT_EM_Conversion_on_Unit__c,
                           GE_LGT_EM_Distribution_Chain_Status__c,GE_LGT_EM_Distribution_Channel__c,GE_LGT_EM_ProductFamily__c,GE_LGT_EM_PSICode__c,GE_LGT_EM_Sales_Org__c,Unit_cost__c,GE_LGT_Variable_cost__c,
                           GE_LGT_Unit_cost__c,CurrencyIsoCode,Level_1__c,Level_2__c,Level_3__c,Level_4__c,Level_5__c,List_Price__c,SAP_Currency__c,SAP_Flag__c,
                           ADP_Price__c,Lead_Time__c,Material_Type__c
                           FROM GE_LGT_EM_MaterialMaster__c 
                           WHERE GE_LGT_EM_SAP_MaterialNumber__c IN:matMasterMap.keySet() AND GE_LGT_EM_SAP_MaterialNumber__c != NULL];
        }
        
        for(GE_LGT_EM_MaterialMaster__c m:matMasterMap.values())
        {
            for(GE_LGT_EM_MaterialMaster__c n:matMasterList)
            {
                if(m.GE_LGT_EM_SAP_MaterialNumber__c == n.GE_LGT_EM_SAP_MaterialNumber__c && m.ID != n.ID)
                {
                    if(m.GE_LGT_EM_ProductHierarchy__c != n.GE_LGT_EM_ProductHierarchy__c || m.GE_LGT_EM_MaterialDescription__c != n.GE_LGT_EM_MaterialDescription__c ||
                       m.GE_LGT_EM_Base_Unit_Measure__c != n.GE_LGT_EM_Base_Unit_Measure__c || m.GE_LGT_EM_Conversion_on_Unit__c!=n.GE_LGT_EM_Conversion_on_Unit__c ||
                       m.GE_LGT_EM_Distribution_Chain_Status__c != n.GE_LGT_EM_Distribution_Chain_Status__c || m.GE_LGT_EM_Distribution_Channel__c!=n.GE_LGT_EM_Distribution_Channel__c ||
                       m.GE_LGT_EM_ProductFamily__c != n.GE_LGT_EM_ProductFamily__c || m.GE_LGT_EM_PSICode__c != n.GE_LGT_EM_PSICode__c ||
                       m.GE_LGT_EM_Sales_Org__c != n.GE_LGT_EM_Sales_Org__c || m.Unit_cost__c!=n.Unit_cost__c || m.GE_LGT_Variable_cost__c!=n.GE_LGT_Variable_cost__c ||
                       m.GE_LGT_Unit_cost__c != n.GE_LGT_Unit_cost__c || m.Level_1__c != n.Level_1__c || m.Level_2__c != n.Level_2__c || m.Level_3__c != n.Level_3__c ||
                       m.Level_4__c != n.Level_4__c ||m.Level_5__c != n.Level_5__c ||m.List_Price__c != n.List_Price__c ||m.SAP_Currency__c != n.SAP_Currency__c || 
                       m.SAP_Flag__c != n.SAP_Flag__c ||  m.ADP_Price__c != n.ADP_Price__c ||  m.Lead_Time__c != n.Lead_Time__c ||  m.Material_Type__c != n.Material_Type__c)
                    {
                        matMasterToUpdate.put(n.ID, m);
                    }
                    matMasterToDelete.put(m.GE_LGT_EM_SAP_MaterialNumber__c, m.id);
                }
            }
        }
        if(matMasterToUpdate!=NULL)
        {
            helper.updatePH(matMasterToUpdate);
        }
        Database.delete(matMasterToDelete.values(),false);
    }  
    
    
    if(trigger.isBefore && (trigger.isUpdate ||trigger.isinsert))
    {
        //list<UnwantedLevels__c> levelsinfo= UnwantedLevels__c.getAll().values();
        list <GE_LGT_EM_MaterialMaster__c> mmllist= new list<GE_LGT_EM_MaterialMaster__c>();
        Map<string,UnwantedLevels__c> levelsinfo = UnwantedLevels__c.getAll(); 
        for(GE_LGT_EM_MaterialMaster__c m:Trigger.new)
        {
            //String Lvlstr = m.Level_1__c.beforesubstring('-');
            if(m.Level_1__c!=null)
            {
                String Lvlstr = m.Level_1__c.substringBefore('-');
                Lvlstr = Lvlstr.trim();
                system.debug('levelstring1'+Lvlstr);
                if(!levelsinfo.containskey(Lvlstr))
                {
                    system.debug('levelstring'+Lvlstr);
                    mmllist.add(m);
                }
            }
            //Below If condition code related to ticket 1766 and 1802.
            if(m.GE_LGT_EM_ProductHierarchy__c==null && m.SAP_Flag__c=='Yes' && m.Level_4__c==null)
            {
                m.GE_LGT_EM_ProductHierarchy__c='NPL000000000000';
                
                m.Level_1__c='NO PRODUCT LINE';    
                m.Level_2__c='NO PRODUCT GROUP';
                m.Level_3__c='NO PRODUCT FAMILY';
                m.Level_4__c='NO PRODUCT NAME';
                m.Level_5__c='NO LEVEL5 DESCRIPTION';
                mmllist.add(m);
            }

            if(m.GE_LGT_EM_ProductHierarchy__c!=null && m.SAP_Flag__c=='Yes' && m.Level_4__c==null)
            {
               
                
                m.Level_4__c=m.Level_3__c;
                m.Level_5__c='TOPCAT HIERARCHY';
                mmllist.add(m);
            }
        }
        helper.createProduct(mmllist);
        helper.createLevels(mmllist);
    }
}