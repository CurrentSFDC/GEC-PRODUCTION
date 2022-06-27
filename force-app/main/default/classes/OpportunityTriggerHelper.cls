/***********************************************************************************************
*   Class Name      : OpportunityTriggerHelper 
*   Date            : 
*   Author          : 
*   Object          : Opportunity
*   Purpose         : These methods fire on Opportunity.
*   Test Class      :OpportunityTriggerHelper_Test
**************************************************************************************************/
public class OpportunityTriggerHelper 
{
    //getting all NA Profiles Ids
    public static Map<String,NA_Profiles__c> profiles_NA = NA_Profiles__c.getAll();
    public static  Map<String,EMEAProfiles__c>  profiles_EMEA = EMEAProfiles__c.getAll();
    public static  Map<String,LA_Profiles__c>  profiles_LATAM = LA_Profiles__c.getAll();
    public static Map<String,Super_Admin_Profiles__c> Profiles_Super =Super_Admin_Profiles__c.getAll();
    Public static Map<String , Channel_Partner_Acct__c> channel_Partners =Channel_Partner_Acct__c.getAll();
    //getting all record types of Opportunity with name as key and value as ID
    public static Map<String,id> mapRecTypeNameID=OpportunityConstantClass.mapRecTypeNameID();
    Public Static Boolean IsPBTriggerred = false;
    Static ID DaintreeRecId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Daintree').getRecordTypeId();
    Static ID StandardRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeID();
    Static ID IntEnvmtRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Intelligent Environments').getRecordTypeID();
    Static ID DaintAdvRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DaintreeAdvance').getRecordTypeId();
    Static ID StandAdvRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('StandardAdvance').getRecordTypeId();
    Static ID IEAdvnceRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
    //Static ID SolarEquRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Solar Equipment').getRecordTypeId(); --> COMMENTED OUT BY MG: RQT-1023
    //Static ID SolarEqAdRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SolarEquipmentAdvance').getRecordTypeId(); --> COMMENTED OUT BY MG: RQT-1023
    //<==========================fillFields()==========================>// 
    /*
@Request No   ::
@Description  :: Padding  Opportunity fields which are: 1 GE_LGT_End_User__c,2 Type,3 GE_LGT_Opportunity_Location__c
@Author       ::
@Event        :: Before Insert
*/ 
    public static void fillFields(List<Opportunity> newOppList)
    {
        String othertype='';
        for(Opportunity opp :newOppList)
        {
            //filling out Opportunity Location with Owner_Pole_Opp__c formula filed which contains owner pole
            
            System.debug('###opp.Owner_Pole_Opp__c:'+opp.Owner_Pole_Opp__c);
            opp.GE_LGT_Opportunity_Location__c = opp.Owner_Pole_Opp__c;
            
            // Filling out End User LookUp field on Opty
            System.debug('###opp.AccountID:'+opp.AccountID);
            if(opp.AccountID!=null){
                
                System.debug('###opp.Account_Type__c:'+opp.Account_Type__c);
                //Account_Type__c field is formula field which contains Type of the Account
                if(opp.Account_Type__c=='End User')
                {
                    //if Account type is End user then  End user of the Opty populate with Account on Opty  
                    opp.GE_LGT_End_User__c=opp.AccountID;
                }
            }
            // Move Oppty.Type2 to Opportunity.Type
            System.debug('###opp.GE_LGT_Oppty_Type2__c:'+opp.GE_LGT_Oppty_Type2__c);
            if(opp.GE_LGT_Oppty_Type2__c!=null)
            {
                opp.Type = opp.GE_LGT_Oppty_Type2__c;
                
            }
            if(opp.GE_LGT_Opportunity_ID__c!=NULL)
            {
                opp.Source_ID__c=opp.GE_LGT_Opportunity_ID__c;
                opp.Is_Cloned__c=TRUE;
                opp.StageName = 'S1 Consult';
                opp.Total_Order_Amount__c=0;
                opp.Estimated_Orders_to_go__c=0;
                opp.Total_Orders_Received_TD__c=0;
            }
            if(opp.GE_LGT_GE_Opportunity_Id__c!=NULL)
            {
                opp.GE_LGT_GE_Opportunity_Id__c=NULL;
            }  
            if(channel_Partners.containsKey(opp.AccountId))
            {   
                opp.Other_Partner_Type__c=channel_Partners.get(opp.AccountId).Cust_Partner_Acct__c;
                //opp.Channel_Partner__c=opp.AccountId;
                opp.Channel_Partner__c=channel_Partners.get(opp.Other_Partner_Type__c).Cust_Partner_Acct__c;  
            }
            else
            {
                if(opp.Other_Partner_Type__c!=null)
                opp.Channel_Partner__c=channel_Partners.get(opp.Other_Partner_Type__c).Cust_Partner_Acct__c;  
            }
        }
    }
    //<==========================OptyOrderProductValidations()==========================>// 
    
    /*
@Request No   ::
@Description  :: Below method will check validations related to Order and Opty Product
@Author       ::
@Event        :: Before Update
*/ 
    public static void optyOrderProductValidations(List<Opportunity> newOppList,Map<id,Opportunity> oldOppMap)
    {
        ID recStdAdvTypeID=mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
        ID recStdTypeID=mapRecTypeNameID.get(OpportunityConstantClass.STANDARD);
        ID recDainTypeID=mapRecTypeNameID.get(OpportunityConstantClass.DAINTREE);
        ID recDainAdvTypeID=mapRecTypeNameID.get(OpportunityConstantClass.DAINTREE_ADV); 
        set<id> ownerIds=new set<id>();
        //getting Order recordType ids
        ID estOrderTypeID=Schema.SObjectType.order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
        ID sapOrderTypeID=Schema.SObjectType.order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();
        //Below set will contain Opty ids which  products have SKU_Number__c and Description or null
        Set<id> errorProdOptysIds=new Set<id>();
        //Below set will contain Opty ids which have Estimated orders
        Set<id> errorEstOrdOptysIds=new Set<id>();
        //Below set will contain Opty ids which have Sap orders
        Set<id> errorSapOrdOptysIds=new Set<id>();
        // set for to add opty ids for Product base validations on Opty
        Set<id> optyProdList = new Set<id>();
        // set for to add opty ids for order base validations on Opty
        Set<id> optyOrderList = new Set<id>();
        //set for to add opty ids for Closed lost Optys
        Set<id> closedoptyOrderList = new Set<id>();
        //Below set will contain Opty ids which have PO orders
        Set<id> errorPO_OrdOptysIds=new Set<id>();
        for(opportunity opp : newOppList){
            //filtering optys for Product base validations --> IF CONDITION COMMENT --> MG: RQT-1023
            if( opp.RecordTypeId!=mapRecTypeNameID.get(OpportunityConstantClass.ENERGY_ADV) /*&& opp.RecordTypeId!=mapRecTypeNameID.get(OpportunityConstantClass.SOLAR_ADV)*/ 
               && opp.RecordTypeId!=mapRecTypeNameID.get(OpportunityConstantClass.EV_ADV)  &&(opp.StageName=='S5 Close'||opp.StageName=='PO Received')){
                   
                   System.debug('###optyProdList##:'+opp.id);
                   optyProdList.add(opp.id);
               }
            //filtering optys for Order base validations
            if(opp.StageName!=oldOppMap.get(opp.id).StageName && opp.recordtypeid==recStdAdvTypeID && (opp.stagename=='S3 Solve' ||opp.StageName=='S4 Negotiate'||opp.stagename=='S5 Close'||opp.stagename=='PO Received')){
                System.debug('###optyOrderList##:'+opp.id);
                optyOrderList.add(opp.id);
                if(profiles_EMEA.containskey(opp.Owner_ProfileId__c)){
                    ownerIds.add(opp.ownerid);
                }
            }
            //filtering optys for Order base validations if Opty moving to Closed lost stage
            
            else{
                errorEstOrdOptysIds.add(opp.id);
                errorSapOrdOptysIds.add(opp.id);
            }
            if(opp.StageName!=oldOppMap.get(opp.id).StageName && opp.stagename=='Closed Lost'){
                closedoptyOrderList.add(opp.id);
            }
        }
        
        if(closedoptyOrderList.size()>0){
            //query to get count of Po Orders 
            AggregateResult[] POorderCountAggs =[select Opportunityid oppId,COUNT(id) con from order where Opportunityid in:closedoptyOrderList and PO_Received_Formula__c=true  GROUP BY  Opportunityid ORDER BY Opportunityid ASC];
            if(POorderCountAggs!=null){
                for(AggregateResult ar:POorderCountAggs){
                    if((integer)ar.get('con')>0){
                        System.debug('###errorPO_OrdOptysIds:'+(id)ar.get('oppId'));
                        errorPO_OrdOptysIds.add((id)ar.get('oppId'));
                    }
                }
            }
            
        }
        System.debug('###optyProdList.size()'+optyProdList.size());
        if(optyProdList.size()>0){
            //query to get count of Products which doest have  SKU_Number__c and Description
            AggregateResult[] prodCountAggs = [ SELECT Opportunityid oppId, COUNT(id) con FROM opportunitylineitem where Description = null and SKU_Number__c =null and Opportunityid in:optyProdList GROUP BY Opportunityid ORDER BY Opportunityid ASC ] ;
            
            if(prodCountAggs!=null){
                for(AggregateResult ar:prodCountAggs){
                    if((integer)ar.get('con')>0){
                        System.debug('###errorProdOptysId:'+(id)ar.get('oppId'));
                        errorProdOptysIds.add((id)ar.get('oppId'));
                    }
                }
            }
        }
        System.debug('###optyOrderList.size()'+optyOrderList.size());
        if(optyOrderList.size()>0){
            //query to get count of orders group by record type 
            AggregateResult[] orderCountAggs =[select Opportunityid oppId,COUNT(id) con,RecordTypeid recid from order where Opportunityid in:optyOrderList  GROUP BY ROLLUP(RecordTypeid, Opportunityid) ORDER BY Opportunityid ASC];
            
            if(orderCountAggs!=null){
                for(AggregateResult ar:orderCountAggs){
                    //condition for count Estimated orders
                    if((integer)ar.get('con')>0 && (id)ar.get('oppId')!=null && (id)ar.get('recid')==estOrderTypeID){
                        System.debug('###errorEstOrdOptysIds:'+(id)ar.get('oppId'));
                        errorEstOrdOptysIds.add((id)ar.get('oppId'));
                    }
                    //condition for count Sap orders
                    if((integer)ar.get('con')>0 && (id)ar.get('oppId')!=null && (id)ar.get('recid')==sapOrderTypeID){
                        System.debug('###errorSapOrdOptysIds:'+(id)ar.get('oppId'));
                        errorSapOrdOptysIds.add((id)ar.get('oppId'));
                    }
                }
            }
        }
        Map<id,user> ownerWithRegion;
        if(ownerIds.size()>0){
            ownerWithRegion=new map<id,user>([SELECT Id,ProfileId,GE_LGT_Region__c FROM User where id in:ownerIds]);
        }
        System.debug('###optyOrderList.size()'+optyOrderList.size());
        System.debug('###optyProdList.size()'+optyProdList.size());
        if(optyOrderList.size()>0||optyProdList.size()>0||errorPO_OrdOptysIds.size()>0){
            for(opportunity oppVar : newOppList){
                //
                system.debug('Synced Quote Id -test ::'+oppVar.SyncedQuoteId);
                if((oppVar.stagename=='S3 Solve' ||oppVar.StageName=='S4 Negotiate'||oppVar.stagename=='S5 Close'||oppVar.stagename=='PO Received')&&oppVar.recordtypeid==recStdAdvTypeID  && !errorEstOrdOptysIds.contains(oppVar.id)){
                    oppVar.addError('S3 Solve – Estimated PO orders  must be Entered');
                }
                else if( oppVar.stagename=='PO Received' && oppVar.recordtypeid==recStdAdvTypeID && !errorSapOrdOptysIds.contains(oppVar.id) && profiles_EMEA.containskey(oppVar.Owner_ProfileId__c) && ownerWithRegion.get(oppVar.Ownerid).GE_LGT_Region__c!='EU Distribution'){
                    
                    
                    oppVar.addError('PO Received – Opportunity must have an SAP Order linked to it');
                    
                }
                
                else if(oppVar.Total_Order_Amount__c >=50000 && oppVar.StageName!=oldOppMap.get(oppVar.id).StageName && oppVar.SyncedQuoteId==null  && (profiles_NA.containskey(oppVar.Owner_ProfileId__c)|| profiles_LATAM.containskey(oppVar.Owner_ProfileId__c)) && errorProdOptysIds.contains(oppVar.id) && (oppVar.stagename=='S5 Close'||oppVar.stagename=='PO Received') && oppVar.recordtypeid==recStdAdvTypeID){
                    
                    oppVar.addError('1--For Stages S5 Close,PO Received – Cat Logic OR Product Code/SKU/Material # must be Entered');
                    
                }
                else if(profiles_EMEA.containskey(oppVar.Owner_ProfileId__c) && oppVar.StageName!=oldOppMap.get(oppVar.id).StageName && oppVar.SyncedQuoteId==null && errorProdOptysIds.contains(oppVar.id) && (oppVar.stagename=='S5 Close'||oppVar.stagename=='PO Received')  && oppVar.recordtypeid==recStdAdvTypeID ){
                    
                    oppVar.addError('2--For Stages S5 Close,PO Received – Cat Logic OR Product Code/SKU/Material # must be Entered');
                    
                }
                //should not allow user to move "closed lost if opty have PO orders "
                else if(errorPO_OrdOptysIds.contains(oppVar.id)){
                    oppVar.addError('Cannot mark an opportunity to Closed Lost when orders have been received.');
                }
            }
        }
    }
    
    //<==========================calculatePushCount()<==========================>// 
    /*
@Request No ::
@Description::Calculate PushCount__c value based on Opportunity PO_Receipt_Date__c 
@Author     ::
@Event      :: Before Update
*/
    public static void calculatePushCount(List<Opportunity> newOppList,Map<id,Opportunity> oldOppMap)
    {
        Date dNewPODate;
        Date dOldPODate;
        Boolean bPushed=false;
        //Iterating new Opty List
        for (Opportunity opp : newOppList) { 
            // gets new values for updated rows
            if(opp.PO_Receipt_Date__c!=oldOppMap.get(opp.Id).PO_Receipt_Date__c){
                dNewPODate = opp.PO_Receipt_Date__c; // get the new PO_Receipt_Date__c 
                dOldPODate = oldOppMap.get(opp.Id).PO_Receipt_Date__c; //get the old PO_Receipt_Date__c for this opportunity
                System.debug('###New PO Date:'+dNewPODate);
                System.debug('###Old PO Date:'+dOldPODate);
                if (dOldPODate<dNewPODate) { //if the new date is after the old one, look if the month numbers are different
                    if (dOldPODate.month()<dNewPODate.month()) { // the month number is higher, it's been pushed out
                        bPushed=true;
                    }
                    else {
                        if (dOldPODate.year()<dNewPODate.year()) { // the month wasn't higher, but the year was, pushed!
                            bPushed=true;
                        }
                    }
                    
                }
                if (bPushed==true) { // let's go make them sorry
                    if (opp.PushCount__c==null) {
                        opp.PushCount__c=1;
                    }
                    else {
                        opp.PushCount__c++;           
                    }
                }
                System.debug('###PushCount:'+opp.PushCount__c);
            }
        }
    }
    
    //<==========================createContactRole()<==========================>// 
    
    /*
@Request No   ::
@Description  :: Creating OpportunityContactRole for Opportunity if GE_LGT_Contact__c changes. 
@Author       ::
@Event        :: After Update,after Insert
*/
    public static void createContactRole(List<Opportunity> newOppList,Map<id,Opportunity> oldOppMap)
    {
        //below list contain list of OpportunityContactRole to create
        List<OpportunityContactRole> lstOpptyRoles = new List<OpportunityContactRole>();
        for(Opportunity opp :newOppList)
        {
            //Checking is GE_LGT_Contact__c in Null or not
            if(opp.GE_LGT_Contact__c != null)
            {
                System.debug('###opp.GE_LGT_Contact__c:'+opp.GE_LGT_Contact__c );
                //logic to execute in update event
                if(trigger.isupdate){
                    //checking whether  GE_LGT_Contact__c is changed or Not while updating 
                    if(opp.GE_LGT_Contact__c != oldOppMap.get(opp.Id).GE_LGT_Contact__c)
                    {
                        //creating OpportunityContactRole  under the Opty and Contact in Update Operation 
                        OpportunityContactRole OppRole = new OpportunityContactRole(OpportunityID = opp.ID,Role = 'Other',ContactID =opp.GE_LGT_Contact__c);
                        lstOpptyRoles.add(OppRole);
                    }
                }
                //logic to execute in insert event
                if(trigger.isInsert){
                    //creating OpportunityContactRole  under the Opty and Contact  in Insert Operation
                    OpportunityContactRole OppRole = new OpportunityContactRole(OpportunityID = opp.ID,ContactID =opp.GE_LGT_Contact__c);
                    lstOpptyRoles.add(OppRole);
                }
            }   
        }
        System.debug('###lstOpptyRoles.size:'+lstOpptyRoles.size());
        if(lstOpptyRoles.size() > 0)
            upsert lstOpptyRoles;
        
    }
    //<==========================mapRecordTypeToOpty()<==========================>// 
    
    /*
@Request No   ::
@Description  :: Mapping recordType to Opty which are crated while Lead Conversion and Mapping PriceBook
@Author       ::
@support Class:: Opportunity_PriceBook_Handler
@Event        :: Before Insert
*/
    
    public static void mapRecordTypeToOpty(List<Opportunity> newOppList)
    {
        
        for(opportunity o : newOppList){
            //GE_LGT_Oppty_Type2__c field represents type of the opty is coming from Lead
            System.debug('###o.GE_LGT_Oppty_Type2__c:'+o.GE_LGT_Oppty_Type2__c);
            //Originated_from_Lead__c field represents opty is coming from Lead
            System.debug('###o.Originated_from_Lead__c:'+o.Originated_from_Lead__c);
            if(o.Originated_from_Lead__c==true){
                /*if(o.GE_LGT_Oppty_Type2__c=='Solar'){
                    o.RecordTypeId =  o.RecordTypeId=mapRecTypeNameID.get(OpportunityConstantClass.SOLAR_ADV) ;
                }*/ // --> COMMENTED OUT BY MG: RQT-1023
                if(o.GE_LGT_Oppty_Type2__c=='Storage'){
                    o.RecordTypeId =  o.RecordTypeId=mapRecTypeNameID.get(OpportunityConstantClass.ENERGY_ADV) ;
                }
                if(o.GE_LGT_Oppty_Type2__c=='EV'){
                    o.RecordTypeId =  o.RecordTypeId=mapRecTypeNameID.get(OpportunityConstantClass.EV_ADV) ;
                }
                if(o.GE_LGT_Oppty_Type2__c=='OPS'){
                    o.RecordTypeId =  o.RecordTypeId=mapRecTypeNameID.get(OpportunityConstantClass.OPS_ADV) ;
                }
                if(o.GE_LGT_Oppty_Type2__c=='Standard'){
                    o.RecordTypeId =  o.RecordTypeId=mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV) ;
                }
                if(o.GE_LGT_Oppty_Type2__c=='Intelligent City'){
                    o.RecordTypeId =  o.RecordTypeId=mapRecTypeNameID.get(OpportunityConstantClass.INTELLIGENT_ADV) ;
                }
                if(o.GE_LGT_Oppty_Type2__c=='Daintree'){
                    o.RecordTypeId =  o.RecordTypeId=mapRecTypeNameID.get(OpportunityConstantClass.DAINTREE) ;
                }
            }
            System.debug('###o.RecordTypeId:'+o.RecordTypeId);
        }
        // After assigning Record type assigning Pricbook2id to the Opty based on Record type 
        Opportunity_PriceBook_Handler.setPriceBook(newOppList);
    }
    
    //<==========================mapPriceBookToOpty()<==========================>// 
    
    /*
@Request No   ::
@Description  :: Mapping Price book to the Opportunity based on Record type if CurrencyIsoCode changes and Opty doesn't have line items
@Author       ::
@support Class:: Opportunity_PriceBook_Handler
@Event        :: before Update
*/
    
    public static void mapPriceBookToOpty(List<Opportunity> newOppList,Map<id,Opportunity> oldOppMap)
    {
        //filtered optys which need to change the price book 
        List<opportunity> FilterOppList = new List<opportunity>();
        for(opportunity opp : newOppList){
            System.debug('###opp.CurrencyIsoCode:'+opp.CurrencyIsoCode);
            System.debug('###opp.pricebook2id:'+opp.pricebook2id);
            
            if(( opp.pricebook2id==null || (oldOppMap.get(opp.id).hasopportunitylineitem!= opp.hasopportunitylineitem && opp.hasopportunitylineitem==false)) ){
                FilterOppList.add(opp);
                
            }
            
        }
        System.debug('###FilterOppList.size():'+FilterOppList.size());
        if(FilterOppList.size()>0){
            //Setting up price book
            Opportunity_PriceBook_Handler.setPriceBook(FilterOppList);
        }
        
        
    }
    
    //<==========================updateSKUFromQuoteLineItem()==========================>// 
    
    /*
@Request No   :: KAFZY-1995
@Description  :: 
@Author       ::
@Event        :: AfterUpdate
*/ 
    
    public static void updateSKUFromQuoteLineItem(List<Opportunity> oppList)
    {
        //below Set contain quote id's which opportunity SyncedQuoteID not null
        Set<ID> quoteIds=new Set<ID>();
        List<OpportunityLineItem> oppItemsToUpdate=new List<OpportunityLineItem>();
        for(Opportunity opp:oppList)
        {
            if(opp.SyncedQuoteID!=NULL)
                quoteIds.add(opp.SyncedQuoteID);
        }
        System.debug('quoteIds:'+quoteIds);
        if(quoteIds.size()>0)
        {
            //below query to get the quotelineitems items unser opty quotes 
            List<QuoteLineItem> quoteLineItems=[SELECT ID,Opportunity_Line_Item_ID__c,SKU__c,SKU_Description_Cat_Logic__c,Alternate_Description__c,Item_Alternate_Description__c
                                                FROM QuoteLineItem WHERE QuoteID IN:quoteIds 
                                                AND Opportunity_Line_Item_ID__c!=NULL];
            System.debug('quoteLineItems:'+quoteLineItems);
            Map<ID,QuoteLineItem> qlItemMap=new Map<ID,QuoteLineItem>();
            Map<String,String> skuMap=new Map<String,String>();
            Set<String> catLogicDesc=new Set<String>();
            Set<String> skuSet=new Set<String>();
            for(QuoteLineItem qlitem:quoteLineItems)
            {
                qlItemMap.put(qlitem.Opportunity_Line_Item_ID__c,qlitem);
                catLogicDesc.add(qlitem.SKU_Description_Cat_Logic__c);
                if(qlitem.SKU__c!=NULL)
                    skuSet.add(qlitem.SKU__c);
            }
            /******** Added by Shyam - KAFZY-1995 - START *********/
            //Added below code - for fetching CAT Logic of the SKU's if SAP Quote Items didn't receive CAT Logic from SAP
            if(catLogicDesc.contains(NULL) || catLogicDesc.contains(''))
            {
                List<GE_LGT_EM_MaterialMaster__c> matMasters=[SELECT ID,GE_LGT_EM_MaterialDescription__c,GE_LGT_EM_SAP_MaterialNumber__c
                                                              FROM GE_LGT_EM_MaterialMaster__c WHERE GE_LGT_EM_SAP_MaterialNumber__c IN:skuSet AND GE_LGT_EM_SAP_MaterialNumber__c!=NULL];
                for(GE_LGT_EM_MaterialMaster__c matMaster:matMasters)
                {
                    skuMap.put(matMaster.GE_LGT_EM_SAP_MaterialNumber__c,matMaster.GE_LGT_EM_MaterialDescription__c);
                }
            }
            /******** Added by Shyam - KAFZY-1995 - END *********/
            for(OpportunityLineItem olitem:[SELECT ID FROM OpportunityLineItem WHERE OpportunityID IN:oppList])
            {
                if(qlItemMap.containsKey(olitem.ID))
                {
                    if(qlItemMap.get(olitem.ID).SKU__c!=NULL)
                        olitem.SKUNumber__c=qlItemMap.get(olitem.ID).SKU__c;
                    if(qlItemMap.get(olitem.ID).SKU_Description_Cat_Logic__c!=NULL)
                        olitem.Description=qlItemMap.get(olitem.ID).SKU_Description_Cat_Logic__c;
                    else
                        olitem.Description=skuMap.get(qlItemMap.get(olitem.ID).SKU__c);
                    if(qlItemMap.get(olitem.ID).Alternate_Description__c!=NULL)
                        olitem.Alternate_Description__c=qlItemMap.get(olitem.ID).Alternate_Description__c;
                    else
                        olitem.Alternate_Description__c=NULL;
                    if(qlItemMap.get(olitem.ID).Item_Alternate_Description__c!=NULL)
                        olitem.Alternate_Description__c=qlItemMap.get(olitem.ID).Item_Alternate_Description__c;
                    else
                        olitem.Alternate_Description__c=NULL;    
                    oppItemsToUpdate.add(olitem);
                }
            }
            System.debug('oppItemsToUpdate:'+oppItemsToUpdate);
            if(oppItemsToUpdate!=NULL && !oppItemsToUpdate.isEmpty())
                Database.update(oppItemsToUpdate,False);
        }
    }
    //<==========================insOppTeamMemberFromOpp()==========================>// 
    
    /*
@Request No   :: 
@Description  :: 
@Author       ::
@Event        :: AfterInsert,AfterUpdate
*/ 
    public static void insOppTeamMemberFromOpp ( List<Opportunity> OppList, Map<id, Opportunity> oOppMap, Map<id, Opportunity> nOppMap){
        //below list contain strings that map Opty id and owner id
        set<string> reqOppTeamMemberSet = new Set<string>();
        ////below list contain strings that map Opty id and account owner id
        set<string> addAccOwnerSet = new Set<string>();
        //below list contain opty ids
        set<string> addOppOwnerSet = new Set<string>();
        //below list contain opty account ids
        set<string> accIdSet = new Set<string>();
        
        for ( Opportunity opp : OppList ){
            
            if ( trigger.isInsert ){
                addAccOwnerSet.add(opp.id);
                addOppOwnerSet.add(opp.id);
                accIdSet.add(opp.AccountId);
            }
            
            if ( trigger.isUpdate ){
                //checking whether account id Opty changed or not in update event 
                if ( oOppMap.get(opp.id).AccountId != nOppMap.get(opp.id).AccountId ) {
                    addAccOwnerSet.add(opp.id);
                    accIdSet.add(opp.AccountId);
                }
                //checking whether owner id Opty changed or not in update event 
                if ( oOppMap.get(opp.id).OwnerId != nOppMap.get(opp.id).OwnerId ){
                    addOppOwnerSet.add(opp.id);
                    accIdSet.add(opp.AccountId);
                }
            }
        }
        //checking Owner id or account id changed optys have in list or not
        if ( addAccOwnerSet.size() > 0 || addOppOwnerSet.size() > 0 ) {
            //getting Optys along with OpportunityTeamMembers
            List<Opportunity> OppWithTeamMemberList = [ SELECT Id, AccountId, OwnerId, recordType.DeveloperName,Account.OwnerId, ( SELECT Id, Opportunity.AccountId, OpportunityId, UserId, TeamMemberRole, OpportunityAccessLevel FROM OpportunityTeamMembers WHERE Opportunity.AccountId in : accIdSet ) FROM Opportunity WHERE AccountId in : accIdSet ] ;
            if(OppWithTeamMemberList.size()>0)
            {
                system.debug('OppWithTeamMemberList'+OppWithTeamMemberList);
                for ( Opportunity opp : OppWithTeamMemberList ){
                    system.debug('opp.recordType.DeveloperName'+opp.recordType.DeveloperName);
                    if(opp.recordType.DeveloperName != 'Daintree_Renewals')
                    {
                        if ( addOppOwnerSet.contains(opp.id)){
                            //combining opty id and owner id with '-' separator
                            reqOppTeamMemberSet.add(opp.id + '-' + opp.OwnerId);
                        }
                        
                        if ( addAccOwnerSet.contains(opp.id)){
                            //combining opty id and account id with '-' separator
                            reqOppTeamMemberSet.add(opp.id + '-' + opp.Account.OwnerId);
                        }
                    }
                    
                    
                    for ( OpportunityTeamMember oppTeamMember : opp.OpportunityTeamMembers ) {
                        //combining opty id and Team member user id  with '-' separator
                        string OppTeamMemberKey = oppTeamMember.OpportunityId + '-' + oppTeamMember.UserId ;
                        
                        if ( reqOppTeamMemberSet.contains(OppTeamMemberKey)) {
                            reqOppTeamMemberSet.remove(OppTeamMemberKey);
                        }
                    }
                }
            }
        }
        
        if ( reqOppTeamMemberSet.size() > 0 ) {
            OpportunityTriggerHelper.insOppTeamMember(reqOppTeamMemberSet);
        }
    }
    //Helper Method for insOppTeamMemberFromOpp method to insert Opportunity Team Members
    public static void insOppTeamMember ( set<string> reqOppTeamMemberSet ) {
        
        //list to insert OpportunityTeamMembers
        List<OpportunityTeamMember> OppTeamMemberInsList = new List<OpportunityTeamMember>();
        
        //list to update OpportunityShare access
        List<OpportunityShare> OppShareUpdList = new List<OpportunityShare>();      
        
        //contain Optyids which need to crate new Opty Team Member
        set<string> oppIdSet = new set<string>();
        
        //contain user ids which need to crate new Opty Team Member
        set<string> tmIdSet = new set<string>();
        system.debug('reqOppTeamMemberSet'+reqOppTeamMemberSet);
        for ( String reqOppTeamMember : reqOppTeamMemberSet ) {
            system.debug('reqOppTeamMember1'+reqOppTeamMember);           
            string oppId = reqOppTeamMember.left(18);
            string tmId = reqOppTeamMember.right(18);
            system.debug('oppId'+oppId);
            system.debug('tmId'+tmId);
            oppIdSet.add(oppId);
            tmIdSet.add(tmId);
            //creating new OptyTeamMember
            OppTeamMemberInsList.add ( new OpportunityTeamMember (
                OpportunityId = oppId,
                UserId = tmId,
                TeamMemberRole = 'Account Manager' ));
        }
        system.debug('OppTeamMemberInsList'+OppTeamMemberInsList);
        //inerting 
        insert oppTeamMemberInsList;
        //getting OpportunityShare records to modify sharing access for new OptyTeamMembers
        List<OpportunityShare> OppShareList = [select Id, OpportunityAccessLevel, UserOrGroupId, OpportunityId, RowCause from OpportunityShare where OpportunityId IN :oppIdSet AND UserOrGroupId in : tmIdSet and RowCause = 'Team'];
        
        for ( OpportunityShare oppShare : oppShareList ) {
            string OppTeamMemberKey = oppShare.OpportunityId + '-' + oppShare.UserOrGroupId ;
            if ( reqOppTeamMemberSet.contains(OppTeamMemberKey)){
                //giving edit access a new Opty team member  
                oppShare.OpportunityAccessLevel = 'Edit';
                OppShareUpdList.add(oppShare);
            }
        }
        //updating OpportunityShare asesss
        update oppShareUpdList;
    }
    //<==========================preventStageAdvancement()==========================>// 
    
    /*
@Request No   :: 116 (May-2017)
@Description  :: To prevent stage advancement to S2 or above if oppty does not have Contact roles
@Author       :: Neel (TechM)
@Event        :: BeforeUpdate
*/ 
    
    public static void preventStageAdvancement(List<Opportunity> newOppList,Map<id,Opportunity> oldOppMap){
        // pull RecTypeIds from Utility class
        ID recTypeID_STDADV=mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
        ID recTypeID_STD=mapRecTypeNameID.get(OpportunityConstantClass.STANDARD); 
        ID recTypeID_DAINTREE=mapRecTypeNameID.get(OpportunityConstantClass.DAINTREE);
        ID recTypeID_DAINTREE_ADV=mapRecTypeNameID.get(OpportunityConstantClass.DAINTREE_ADV); 
        ID recTypeID_INTELLIGENT=mapRecTypeNameID.get(OpportunityConstantClass.INTELLIGENT);
        ID recTypeID_INTELLIGENT_ADV=mapRecTypeNameID.get(OpportunityConstantClass.INTELLIGENT_ADV); 
        // Store above RecType ids into a set
        Set<Id> setRecTypeIds = new Set<Id>{recTypeID_STDADV,recTypeID_STD,recTypeID_DAINTREE,recTypeID_DAINTREE_ADV,recTypeID_INTELLIGENT,recTypeID_INTELLIGENT_ADV};
            Set<Id> OptyIds=new Set<Id>();
        for(Opportunity opp:newOppList){
            if(setRecTypeIds.contains(opp.RecordTypeId) && opp.StageName!='S1 Consult' && opp.StageName!='Closed Lost' && opp.StageName!=oldOppMap.get(opp.id).StageName){
                OptyIds.add(opp.id);
            }
        }
        if(OptyIds.size()>0){
            //below map will store opptyid,contactcount - to be used for displaying error to user when stage moves to S2 or above.
            Map<Id,Integer> oppContRoleMap = new Map<Id,Integer>();
            
            // below list will pull opptyid and contact count from table, which will be stored into a map 
            List<AggregateResult> lstOppConRole = [SELECT OpportunityId Id , count(Id) ContactCount 
                                                   FROM OpportunityContactRole 
                                                   WHERE Role !=null 
                                                   AND Opportunityid IN:newOppList 
                                                   GROUP BY Opportunityid];
            //put each of the result rows into map
            for(AggregateResult agrVar : lstOppConRole ){
                oppContRoleMap.put((Id)agrVar.get('Id'), (Integer)agrVar.get('ContactCount'));
            }
            
            //validating if the stage is moved upwards without having contact role 
            for(Opportunity oppVar : newOppList){
                system.debug('Contact count for this oppty :'+oppContRoleMap.get(oppVar.id));
                
                if( OptyIds.contains(oppVar.id) && (oppContRoleMap.get(oppVar.id)==null) ){
                    oppVar.addError('You will need to add a contact with role in order to save the opportunity');
                }
            }
        }
        
    }
    
    /*
* Author : Shyam Prasad Nayakula
* Date : June - 2017
* This method clones the Contact Roles along with the Opportunity when an Opportunity is being cloned
*/
    public static void cloneOppContactRoles(List<Opportunity> newList)
    {
        ID recTypeID_STDADV=mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
        ID recTypeID_STD=mapRecTypeNameID.get(OpportunityConstantClass.STANDARD); 
        ID recTypeID_DAINTREE=mapRecTypeNameID.get(OpportunityConstantClass.DAINTREE);
        ID recTypeID_DAINTREE_ADV=mapRecTypeNameID.get(OpportunityConstantClass.DAINTREE_ADV); 
        ID recTypeID_INTELLIGENT=mapRecTypeNameID.get(OpportunityConstantClass.INTELLIGENT);
        ID recTypeID_INTELLIGENT_ADV=mapRecTypeNameID.get(OpportunityConstantClass.INTELLIGENT_ADV); 
        // Store above RecType ids into a set
        Set<Id> recTypeIDSet = new Set<Id>{recTypeID_STDADV,recTypeID_STD,recTypeID_DAINTREE,recTypeID_DAINTREE_ADV,recTypeID_INTELLIGENT,recTypeID_INTELLIGENT_ADV};
            
            Map<ID,ID> oppIDMap = new Map<ID,ID>();
        for(Opportunity oppVar:newList)
        {
            if(oppVar.GE_LGT_Opportunity_ID__c!=NULL && recTypeIDSet.contains(oppvar.RecordTypeID))
            {
                oppIDMap.put(oppVar.GE_LGT_Opportunity_ID__c,oppVar.ID);
            }
        }
        System.debug('MAKING NULL MAP:'+oppIDMap);
        if(!oppIDMap.isEmpty())
        {
            List<OpportunityContactRole> rolesToInsert = new List<OpportunityContactRole>();
            for(Opportunity oppVar:[SELECT ID,(SELECT ID,ContactID,OpportunityID,Role,IsPrimary FROM OpportunityContactRoles)
                                    FROM Opportunity WHERE ID IN:oppIDMap.keySet()])
            {
                for(OpportunityContactRole roleVar:oppVar.OpportunityContactRoles)
                {
                    OpportunityContactRole contactRoleVar=roleVar.clone(false,true);
                    contactRoleVar.OpportunityID=oppIDMap.get(oppVar.ID);
                    rolesToInsert.add(contactRoleVar);
                }
            }
            if(!rolesToInsert.isEmpty())
                insert rolesToInsert;
        }
    }
    
    /*
* Author : SaiKrishna Tandra
* Date : Sep - 2017
* This method is for validations on IE opportunities
*/
    public static void validationsOnIE(List<Opportunity> newIEList){
        ID recTypeID_INTELLIGENT=mapRecTypeNameID.get(OpportunityConstantClass.INTELLIGENT);
        ID recTypeID_INTELLIGENT_ADV=mapRecTypeNameID.get(OpportunityConstantClass.INTELLIGENT_ADV);
        // Store above RecType id's into a set
        Set<Id> recTypeIEIDSet = new Set<Id>{recTypeID_INTELLIGENT,recTypeID_INTELLIGENT_ADV};
            Set<id> Oppid = new Set<id>();
        for(Opportunity oppVar:newIEList){
            Oppid.add(oppVar.id);
        }
        Map<Id, Opportunity> mapKeyPlayers = new Map<Id, Opportunity>([select id,(select id,Account__c, Account__r.Name,Account__r.Alliance_Partner_Type_Primary__c, Key_Role_Auto__c from Opportunity_Key_Players__r) from opportunity where id IN: Oppid]);
        for(Opportunity oppVar:newIEList){
            Opportunity tempOpp = mapKeyPlayers.get(oppVar.Id);
            
            //IE_(Sell Through and Sell With) must be selected “Yes” 
            if(oppVar.Intelligent_Environments_Segment__c=='ISV Productivity Segment'&& recTypeIEIDSet.contains(oppvar.RecordTypeID) &&(oppVar.Sell_Through__c!='Yes' && oppVar.Sell_With__c!='Yes')&& (oppVar.StageName!='S1 Consult'&& oppVar.StageName!='Closed Lost')){
                oppVar.addError('At least one of the two picklist fields (Sell Through and Sell With) must be selected “Yes” for opportunity to proceed to stages S2 and above');
            }
            //IE_ISV Partner Notified of Opportunity? is Required
            else if(oppVar.Intelligent_Environments_Segment__c=='ISV Productivity Segment'&& recTypeIEIDSet.contains(oppvar.RecordTypeID) &&oppVar.ISV_Partner_Notified_of_Opportunity__c==null&& (oppVar.StageName!='S1 Consult'&& oppVar.StageName!='Closed Lost')){
                oppVar.ISV_Partner_Notified_of_Opportunity__c.addError('ISV Partner Notified of Opportunity?  is mandatory for stages S2 and above');
            }
            //IE_ISV Partner Notified Date is Required
            else if(oppVar.Intelligent_Environments_Segment__c=='ISV Productivity Segment'&& recTypeIEIDSet.contains(oppvar.RecordTypeID) &&oppVar.ISV_Partner_Notified_of_Opportunity__c=='Yes'&& oppVar.ISV_Partner_Notified_Date__c==null && (oppVar.StageName!='S1 Consult'&& oppVar.StageName!='Closed Lost') ){
                oppVar.ISV_Partner_Notified_Date__c.addError('If “Yes” is selected in the “ISV Partner Notified of Opportunity?” field, then "ISV Partner Notified Date" field will be mandatory for stages S2 and above');
            }
            //IE_Held First Meeting is Required
            else if(oppVar.Intelligent_Environments_Segment__c=='ISV Productivity Segment'&& recTypeIEIDSet.contains(oppvar.RecordTypeID) &&oppVar.Held_First_Meeting__c==null&& (oppVar.StageName!='S1 Consult'&& oppVar.StageName!='S2 Evaluate'&& oppVar.StageName!='Closed Lost')){
                oppVar.Held_First_Meeting__c.addError('Held First Meeting  is mandatory for stages S3 and above');
            }
            //IE_Others % is Required
            else if(oppVar.Intelligent_Environments_Segment__c=='ISV Productivity Segment'&& recTypeIEIDSet.contains(oppvar.RecordTypeID) &&oppVar.OtherIE__c==null &&oppVar.ISV_Commission_Rate__c=='Other %'){
                oppVar.OtherIE__c.addError('Other %  is required'); 
            }
            //ISV Commission Rate % is Required
            else if(oppVar.Intelligent_Environments_Segment__c=='ISV Productivity Segment'&& recTypeIEIDSet.contains(oppvar.RecordTypeID) &&oppVar.ISV_Commission_Rate__c==null &&(oppVar.StageName!='S1 Consult'&& oppVar.StageName!='S2 Evaluate'&& oppVar.StageName!='Closed Lost')){
                oppVar.ISV_Commission_Rate__c.addError('ISV Commission Rate  is mandatory for stages S3 and above');  
            }
            //IE_Held joint First Meeting date is Required
            else if(oppVar.Intelligent_Environments_Segment__c=='ISV Productivity Segment'&& recTypeIEIDSet.contains(oppvar.RecordTypeID) && oppVar.Held_First_Meeting__c=='Yes'&& oppVar.Held_joint_First_Meeting_date__c==null && (oppVar.StageName!='S1 Consult'&& oppVar.StageName!='S2 Evaluate'&& oppVar.StageName!='Closed Lost')){
                oppVar.Held_joint_First_Meeting_date__c.addError('If Yes is selected in the “Held First Meeting” field, then "Held joint First Meeting date" field will be mandatory for stages S3 and above');
            }
            //IE_Partner Pricing Submitted to Customer is Required
            else if(oppVar.Intelligent_Environments_Segment__c=='ISV Productivity Segment'&& recTypeIEIDSet.contains(oppvar.RecordTypeID) && oppVar.Partner_Pricing_Submitted_to_Customer__c!='Yes' && (oppVar.StageName=='S4 Negotiate'||oppVar.StageName=='S5 Close'|| oppVar.StageName=='PO Received') ){
                oppVar.Partner_Pricing_Submitted_to_Customer__c.addError('“Partner Pricing Submitted to Customer” is required for stages S4 and above');  
                
            }
            //IE_Quote/Pricing Submitted date is Required
            else if(oppVar.Intelligent_Environments_Segment__c=='ISV Productivity Segment'&& recTypeIEIDSet.contains(oppvar.RecordTypeID) &&  oppVar.Quote_Pricing_Submitted_date__c==null && (oppVar.StageName=='S4 Negotiate'||oppVar.StageName=='S5 Close'|| oppVar.StageName=='PO Received') ){
                oppVar.Quote_Pricing_Submitted_date__c.addError('"Quote/Pricing Submitted date"  is required for stages S4 and above');  
                
            } else if(oppVar.Intelligent_Environments_Segment__c=='ISV Productivity Segment'&& recTypeIEIDSet.contains(oppvar.RecordTypeID) && (oppVar.StageName!='S1 Consult'&& oppVar.StageName!='Closed Lost') && tempOpp.Opportunity_Key_Players__r.size()==0){
                oppVar.addError('Opportunity key players are required for stages S2 and above');
            }
            for (CDT_Opportunity_Key_Player__c okpVar : tempOpp.Opportunity_Key_Players__r) {
                if(okpVar.Account__r.Alliance_Partner_Type_Primary__c == 'Independent Software Vendor'&&oppVar.Intelligent_Environments_Segment__c=='ISV Productivity Segment'&& recTypeIEIDSet.contains(oppvar.RecordTypeID)) {
                    oppVar.Alliance_ISV_Partner_Account_Name__c = okpVar.Account__r.Name;
                }
                
            }
            
        }   
        
    }
    /*
* Author : Satish k
* Date : Aug - 2017
* This method will throw error message when user edit the PO received/Closed lost Opportunity
*/
    public static void ClosedlostPOvalidation(List<Opportunity> newOppList,Map<id,Opportunity> oldOppMap)
    {
        //Map<Id,Profile> profileMap=new Map<Id,Profile>([Select ID, Name from Profile Where Name like :'%Super%' or name like:'%Administrator%' or name like:'%Integration%']);
        
        for(Opportunity opp:newOppList)
        {
            
            if((oldOppMap.get(opp.id).StageName == 'Closed Lost' || oldOppMap.get(opp.id).StageName == 'PO Received') &&!IsPBTriggerred && !Profiles_Super.containsKey(UserInfo.getProfileId()))
                opp.addError('User can not edit the record when Opportunity Stage is PO Received/Closed Lost');
        }
        IsPBTriggerred=True; 
    }  
    /*
* Author : Satish k
* Date : Feb - 2018 RQT-0000933
* This method will update the type of the opp when opp recordtype is updated on cloned
*/
    public static void UpdateTypeonOpp(List<Opportunity> newOppList,Map<id,Opportunity> oldOppMap)
    {
        
        for(Opportunity opp:newOppList)
        {
            if(opp.Is_Cloned__c)   
            {
                if(opp.RecordTypeId!=oldOppMap.get(opp.Id).RecordTypeId)
                {
                    if(opp.RecordTypeId==DaintreeRecId || opp.RecordTypeId==DaintAdvRecID)
                        opp.Type='Daintree';
                    System.debug('Daintree opp type'+opp.Type);
                    if(opp.RecordTypeId==StandardRecID || opp.RecordTypeId==StandAdvRecID)
                        opp.Type='Standard';
                    System.debug('IE opp type'+opp.Type);
                    if(opp.RecordTypeId==IntEnvmtRecID || opp.RecordTypeId==IEAdvnceRecID)
                        opp.Type='Intelligent Environments';
                    System.debug('IE opp type'+opp.Type);
                    /*if(opp.RecordTypeId==SolarEquRecID || opp.RecordTypeId==SolarEqAdRecID)
                        opp.Type='Solar';
                    System.debug('Solar opp type'+opp.Type);*/ // --> COMMENTED OUT BY MG: RQT-1023
                }
            }
            if(oldOppMap.get(opp.Id).Other_Partner_Type__c !=opp.Other_Partner_Type__c && channel_Partners.containsKey(opp.Other_Partner_Type__c))
            {
                System.debug('channel partner--' +channel_Partners.get(opp.Other_Partner_Type__c).Cust_Partner_Acct__c);   
                opp.Channel_Partner__c=channel_Partners.get(opp.Other_Partner_Type__c).Cust_Partner_Acct__c;  
                
            }
            
        }
    }    
    
     /*
@Request No   :: 1597
@Description  :: When Sales Users Clones a closed Opportunity the "Closing Requirements/Details" section values should be cleared on the newly opened Opportunity.
@Author       ::
@support Class:: 
@Event        :: Before Insert
*/
    
    public static void nullifyclosingRequirements(List<Opportunity> newOppList)
    {
        for(Opportunity opp:newOppList)
        {
             if (opp.isClone()) 
             {
                 opp.GE_LGT_Reason_Won_Lost__c='';
                 opp.Competitor__c='';
                 opp.Other_Competitor__c='';
                 opp.GE_LGT_PO_Number__c='';
                 opp.Reason_Won_Lost_Comments__c='';
             }
        }
    }
    
    
}