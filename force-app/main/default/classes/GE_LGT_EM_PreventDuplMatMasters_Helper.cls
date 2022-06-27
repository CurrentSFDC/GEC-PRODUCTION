/***********************************************************************************************
*   Class Name      : GE_LGT_EM_PreventDuplMatMasters_Helper 
*   Date            : 09/14/2015
*   Author          : Shyam Prasad -- Tech Mahindra
*   Object          : GE_LGT_EM_MaterialMaster__c
*   Purpose         : Helper class for Trigger GE_LGT_EM_PreventDuplMatMasters
**************************************************************************************************/
public class GE_LGT_EM_PreventDuplMatMasters_Helper 
{
    
    public void updatePH(Map<ID,GE_LGT_EM_MaterialMaster__c> matMasterToUpdate)
    {
        List<GE_LGT_EM_MaterialMaster__c> matMasterList=[SELECT Id,GE_LGT_EM_SAP_MaterialNumber__c,GE_LGT_EM_ProductHierarchy__c,GE_LGT_EM_MaterialDescription__c,GE_LGT_EM_Base_Unit_Measure__c,GE_LGT_EM_Conversion_on_Unit__c,
                                                         GE_LGT_EM_Distribution_Chain_Status__c,GE_LGT_EM_Distribution_Channel__c,GE_LGT_EM_ProductFamily__c,GE_LGT_EM_PSICode__c,GE_LGT_EM_Sales_Org__c,Unit_cost__c,GE_LGT_Variable_cost__c,
                                                         GE_LGT_Unit_cost__c,CurrencyIsoCode,Level_1__c,Level_2__c,Level_3__c,Level_4__c,Level_5__c,List_Price__c,SAP_Currency__c,SAP_Flag__c,
                                                         ADP_Price__c,Lead_Time__c,Material_Type__c 
                                                         FROM GE_LGT_EM_MaterialMaster__c 
                                                         WHERE ID IN:matMasterToUpdate.keySet()];
        GE_LGT_EM_MaterialMaster__c matMaster=new GE_LGT_EM_MaterialMaster__c();
        for(GE_LGT_EM_MaterialMaster__c m:matMasterList)
        {
            matMaster=matMasterToUpdate.get(m.Id);
            m.GE_LGT_EM_ProductHierarchy__c=matMaster.GE_LGT_EM_ProductHierarchy__c;
            m.GE_LGT_EM_MaterialDescription__c=matMaster.GE_LGT_EM_MaterialDescription__c;
            m.GE_LGT_EM_Base_Unit_Measure__c=matMaster.GE_LGT_EM_Base_Unit_Measure__c;
            m.GE_LGT_EM_Conversion_on_Unit__c=matMaster.GE_LGT_EM_Conversion_on_Unit__c;
            m.GE_LGT_EM_Distribution_Chain_Status__c=matMaster.GE_LGT_EM_Distribution_Chain_Status__c;
            m.GE_LGT_EM_Distribution_Channel__c=matMaster.GE_LGT_EM_Distribution_Channel__c;
            m.GE_LGT_EM_ProductFamily__c=matMaster.GE_LGT_EM_ProductFamily__c;
            m.GE_LGT_EM_PSICode__c=matMaster.GE_LGT_EM_PSICode__c;
            m.GE_LGT_EM_Sales_Org__c=matMaster.GE_LGT_EM_Sales_Org__c;
            m.Unit_cost__c=matMaster.Unit_cost__c;
            m.GE_LGT_Unit_cost__c=matMaster.GE_LGT_Unit_cost__c;
            m.GE_LGT_Variable_cost__c=matMaster.GE_LGT_Variable_cost__c;
            m.Level_1__c=matMaster.Level_1__c;
            m.Level_2__c=matMaster.Level_2__c;
            m.Level_3__c=matMaster.Level_3__c;
            m.Level_4__c=matMaster.Level_4__c;
            m.Level_5__c=matMaster.Level_5__c;
            
            m.List_Price__c=matMaster.List_Price__c;
            m.SAP_Currency__c=matMaster.SAP_Currency__c;
            m.SAP_Flag__c=matMaster.SAP_Flag__c;
            m.Material_Type__c=matMaster.Material_Type__c;
            m.CurrencyIsoCode = matMaster.CurrencyIsoCode;
        }
        Database.SaveResult[] lsr = Database.update(matMasterList,false);
    }
    
    public void createProduct(List<GE_LGT_EM_MaterialMaster__c> matList)
    {
        Set<String> phCodes = new Set<String>();
        Set<Product2> newProducts=new Set<Product2>();
        Set<Product2> updateProducts=new Set<Product2>();
        List<Product2> productsList=new List<Product2>();
        map<id,Product2> prodtoupdate=new  map<id,Product2>();
        for(GE_LGT_EM_MaterialMaster__c m:matList)
        {
            if(m.GE_LGT_EM_ProductHierarchy__c!=NULL)
                //phCodes.add(m.GE_LGT_EM_ProductHierarchy__c);
                phCodes.add(m.GE_LGT_EM_ProductHierarchy__c);
        }
        List<Product2> prdList = [SELECT ID,Product_Hierarchy_Code__c FROM Product2 WHERE Product_Hierarchy_Code__c IN:phCodes AND Isactive = true];
        Map<String,Product2> prdMap=new Map<String,Product2>();
        for(Product2 p:prdList)
        {
            prdMap.put(p.Product_Hierarchy_Code__c, p);
        }
        for(GE_LGT_EM_MaterialMaster__c m:matList)
        {
            if((m.Level_4__c!=null || m.Level_4__c!= '') && m.GE_LGT_EM_ProductHierarchy__c!=NULL)
            {
                if(!prdMap.containsKey(m.GE_LGT_EM_ProductHierarchy__c))
                {
                    
                        Product2 prd=new Product2();
                        prd.Product_Hierarchy_Code__c=m.GE_LGT_EM_ProductHierarchy__c;
                        prd.Name = m.Level_4__c;
                        prd.Levels_3__c=m.Level_3__c;
                        prd.Levels_2__c=m.Level_2__c;
                        prd.levels_1__c=m.Level_1__c;
                        prd.CanUseQuantitySchedule=true;
                        prd.CanUseRevenueSchedule=true;
                        prd.IsActive=true;
                        if(m.SAP_Flag__c=='Yes'){
                            prd.SAP_product__c=true;
                        }
                        else {
                            prd.SAP_product__c=false;
                        }
                        newProducts.add(prd);
                    
                }
                else
                {
                    Product2 prd1=prdMap.get(m.GE_LGT_EM_ProductHierarchy__c);
                    prd1.Id=prdMap.get(m.GE_LGT_EM_ProductHierarchy__c).id;
                    prd1.Name=m.Level_4__c;
                    prd1.Levels_3__c=m.Level_3__c;
                    prd1.Levels_2__c=m.Level_2__c;
                    prd1.levels_1__c=m.Level_1__c;
                    prd1.CanUseQuantitySchedule=true;
                    prd1.CanUseRevenueSchedule=true;
                    prd1.IsActive=true;
                    if(m.SAP_Flag__c =='Yes'){
                        prd1.SAP_product__c=true;
                    }
                    else{
                        prd1.SAP_product__c=false;
                    }
                    if(!prodtoupdate.containsKey(prd1.id))
                        prodtoupdate.put(prd1.Id,prd1);
                } 
            }

          
            
        }
        
        productsList.addAll(newProducts);
        Database.insert(productsList,false);
        //productsList.clear();
        //productsList.addAll(prodtoupdate.values());
        Database.update(prodtoupdate.values(),false);
        prdList = [SELECT ID,Product_Hierarchy_Code__c FROM Product2 WHERE Product_Hierarchy_Code__c IN:phCodes AND Isactive = true];
        for(Product2 p:prdList)
        {
            prdMap.put(p.Product_Hierarchy_Code__c, p);
        }
        for(GE_LGT_EM_MaterialMaster__c m:matList)
        {
            if(m.GE_LGT_EM_ProductHierarchy__c!=NULL && prdMap.containsKey(m.GE_LGT_EM_ProductHierarchy__c))
                m.Product_Hierarchy_Code_2__c=prdMap.get(m.GE_LGT_EM_ProductHierarchy__c).id;
            else {
                m.Product_Hierarchy_Code_2__c=null;
            }
        }
        
    }
    public void createLevels(List<GE_LGT_EM_MaterialMaster__c> matList)
    {
        Set<String> phCodes = new Set<String>();
        Set<String> Unwantedlevels = new Set<String>{'NPL0000000000','SVC000000000000','NPL000000000000'};
            Set<MMobjectLevels__c> newLevels=new Set<MMobjectLevels__c>();
        List<MMobjectLevels__c> newLevelsList=new List<MMobjectLevels__c>();
        Map<ID,MMobjectLevels__c> levelsToUpdate=new Map<ID,MMobjectLevels__c>();
        for(GE_LGT_EM_MaterialMaster__c m:matList)
        {
            if(m.GE_LGT_EM_ProductHierarchy__c!=NULL)
                phCodes.add(m.GE_LGT_EM_ProductHierarchy__c);
        }
        List<MMobjectLevels__c> levelsList = [SELECT ID,Product_Hierarchy__c FROM MMobjectLevels__c WHERE Product_Hierarchy__c IN:phCodes];
        Map<String,MMobjectLevels__c> levelsMap=new Map<String,MMobjectLevels__c>();
        for(MMobjectLevels__c p:levelsList)
        {
            levelsMap.put(p.Product_Hierarchy__c, p);
        }
        for(GE_LGT_EM_MaterialMaster__c m:matList)
        {
            if(m.GE_LGT_EM_ProductHierarchy__c!=NULL && !Unwantedlevels.contains(m.GE_LGT_EM_ProductHierarchy__c)){
                if(!levelsMap.containsKey(m.GE_LGT_EM_ProductHierarchy__c) )
                {
                    MMobjectLevels__c level=new MMobjectLevels__c();
                    level.Product_Hierarchy__c=m.GE_LGT_EM_ProductHierarchy__c;
                    level.Level_1__c=m.Level_1__c;
                    level.Level_2__c=m.Level_2__c;
                    level.Level_3__c=m.Level_3__c;
                    
                        level.Level_4__c=m.Level_4__c;
                    
                    
                        level.Level_5__c=m.Level_5__c;
                    
                    
                    newLevels.add(level);
                }
                else if(levelsMap.containsKey(m.GE_LGT_EM_ProductHierarchy__c))
                {
                    MMobjectLevels__c level=levelsMap.get(m.GE_LGT_EM_ProductHierarchy__c);
                    level.Id=levelsMap.get(m.GE_LGT_EM_ProductHierarchy__c).id;
                    level.Product_Hierarchy__c=m.GE_LGT_EM_ProductHierarchy__c;
                    level.Level_1__c=m.Level_1__c;
                    level.Level_2__c=m.Level_2__c;
                    level.Level_3__c=m.Level_3__c;
                  
                        level.Level_4__c=m.Level_4__c;
                    
                   
                        level.Level_5__c=m.Level_5__c;
                    
                    if(!levelsToUpdate.containsKey(level.id))
                        levelsToUpdate.put(level.Id,level);
                }
            }
        }
        newLevelsList.addAll(newLevels);
        Database.insert(newLevelsList,false);
        Database.update(levelsToUpdate.values(),false);
    }
}