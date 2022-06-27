public class GE_LGT_ProductsSearch{
    public string saveErrorMessage;
    public boolean flagrecordupsert{get; set;}
    public boolean flagrecordupsert1{get; set;}
    public boolean check1scdule{get; set;}
    public boolean allBool{get; set;}
    public string delopptyid{get; set;}
    public List<Product2> productSearchList {set; get;}
    public List<Product2> productList {set; get;}
    public Boolean addb {get;set;}
    public Boolean editpbrender {get;set;}
    public integer inte{get; set;}
    public integer integ{get; set;}
    public string stri{get; set;}
    public String csvfile{get;set;}
    public static integer InsertRec=0;
    public static integer UpdateRec=0;
    public Blob contentFile{get;set;}
    @TestVisible String[] filelines = new String[]{}; 
        Public List<OpportunityLineItem> oltoupload;
    public Transient List<GE_LGT_EM_MaterialMaster__c>  matMasList{get;set;}
    public  List<GE_LGT_EM_MaterialMaster__c>  matMasListSearchresult{get;set;}
    public  Map<id,GE_LGT_EM_MaterialMaster__c>  matMasListSearchresultNext;
    public string searchStr{get;set;}
    public Opportunity opp {get;set;}
    public String OppId;
    public Boolean check {get;set;}
    public Boolean check1 {get;set;}
    public Boolean checkResults {get;set;}
    public Boolean checksave1 {get;set;}
    public Boolean checksave2 {get;set;}
    public Boolean check2 {get;set;}
    public List<OpportunityLineItem> multiLines {get;set;}
    Public List<OpportunityLineItem> Opptyline {get;set;}
    public list<oliwrapper> lstwrapper{get; set;}
    Public List<OpportunityLineItem> Opptyline1 {get;set;}
    public OpportunityLineItem oline{get; set;}
    public List<PriceBookEntry> lstEntryID {get;set;}
    public  string JSONString {get;set;}
    public  string JSONString1 {get;set;}
    transient String[] ProductNames;
    public Set < Integer > InvalidRows;
    public string prdName {set; get;}
    public List<Product2> prdList {set; get;}
    public List<PricebookEntry> prdList1 {set; get;}
    public   Product2 fblist {set; get;}
    public string fName {set; get;}
    public boolean d {set; get;}
    public boolean bbva{get; set;}
    public String testString{get;set;}
    public List<Product2> prdListSet {set; get;}
    public boolean flag{get;set;}
    public boolean falgtoshowproductsearchlist{get;set;}
    public boolean falgtoshowMMobjectsearchlist{get;set;}
    public Integer qty{get;set;}
    public string userlocale{get;set;}
    public List<User> userDetails;
    public List<GE_LGT_EM_MaterialMaster__c> matMasListReadFile1;
    public List<GE_LGT_EM_MaterialMaster__c> matMasListReadFile2;
    public boolean IsNAprofiles{get;set;}
    transient String[] MatMasterDetails;
    public Map<String,Super_Admin_Profiles__c> profileMap;
    public Boolean syncedQuoteFlag{get;set;}
    public Map<string,UnwantedLevels__c> blockedProducts = new Map<string,UnwantedLevels__c>(); 
    public Set<String> filters =new Set<String>() ; 
    List<ID> matMap=new List<ID>();
    public transient Map<Integer, Set<String>> rowNum_ColumnNums_Map;   
    
    public GE_LGT_ProductsSearch(ApexPages.StandardController controller) {
        if(ApexPages.currentPage().getParameters().get('bbvar') == 'true'){
            bbva = true;
        }
        
        profileMap =Super_Admin_Profiles__c.getAll();
        blockedProducts= UnwantedLevels__c.getAll();
        for(String str: blockedProducts.keyset())
        {
            //system.debug('str'+str+'%');
            filters.add(str+'%');
        }
        
        system.debug('blockedProducts'+blockedProducts);
        system.debug('filters'+filters);
        userDetails=[SELECT ID,GE_LGT_Business_Division__c FROM User WHERE ID=:UserInfo.getUserID()];
        matMasListReadFile1=new list<GE_LGT_EM_MaterialMaster__c>();
        matMasListReadFile2=new list<GE_LGT_EM_MaterialMaster__c>();
        setPHLevels();
        testString = ' ';
        inte = 0;
        flag=false;
        addb=False;
        productSearchList = new list<product2>();
        productList = new list<product2>();
        prdListSet=new List<Product2>();
        Opptyline = new list<OpportunityLineItem>();
        Opptyline1 = new list<OpportunityLineItem>();
        matMasListSearchresult=new list<GE_LGT_EM_MaterialMaster__c>();
        oline = new OpportunityLineItem();
        fblist = new Product2();
        userlocale=userinfo.getLocale();
        check = False;
        check2 = True;
        flagrecordupsert = False;
        flagrecordupsert1 = False;
        falgtoshowproductsearchlist=false;
        falgtoshowMMobjectsearchlist=false;
        matMasListSearchresultNext=new Map<id,GE_LGT_EM_MaterialMaster__c>(); 
        check1scdule=False;
        d= false; 
        OppId = controller.getID();
        syncedQuoteFlag = FALSE;
        opp = [SELECT  ID,SyncedQuoteID,GE_LGT_Expected_PO_Receipt_Date__c,Owner_Pole_Opp__c,PriceBook2ID,StageName,CloseDate,PO_Receipt_Date__c,CurrencyIsoCode,RecordTypeid, (SELECT Id, PricebookEntry.Name, Product2.Material_No__c,
                                                                                                                                                                                Quantity, OPPORTUNITY.CurrencyIsoCode,Unit_of_measure__c,GE_LGT_Requested_Price__c,PRICEBOOKENTRY.CurrencyIsoCode,ListPrice,product2.Hierarchy_Level_4_Description__c,product2.Hierarchy_Level_3_Description__c,product2.Hierarchy_Level_1_Description__c,product2.Hierarchy_Level_2_Description__c 
                                                                                                                                                                                FROM   OpportunityLineItems),(SELECT ID,Last_Quote_Synced__c FROM Quotes WHERE Last_Quote_Synced__c=TRUE) FROM Opportunity o WHERE o.Id =: OppId];
        if(!opp.Quotes.isEmpty())
            syncedQuoteFlag = TRUE;
        date d = system.today().addDays(-30);
        //By Neel - aded Product2.Name - to display ProductName(existing line items) on the vf page
        Opptyline = [SELECT ID,product2.name,Product2.Material_No__c,product2ID,SKUNumber__c,product2.Levels_1__c,product2.Levels_2__c,TotalPrice,Unit_of_measure__c,SKU_Number__r.GE_LGT_EM_SAP_MaterialNumber__c,SKU_Number__r.GE_LGT_EM_MaterialDescription__c, Product_Hierarchy_Code__c,OPPORTUNITYID,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,product2.Hierarchy_Level_4_Description__c,product2.Hierarchy_Level_3_Description__c,product2.Hierarchy_Level_1_Description__c,product2.Hierarchy_Level_2_Description__c,GE_LGT_Level1__c,GE_LGT_Level2__c,GE_LGT_Level3__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,Confirmed__c,Cut_off_date__c,(SELECT Id,Description,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type FROM OpportunityLineItemSchedules ORDER BY ScheduleDate ASC)   FROM OPPORTUNITYLINEITEM where OPPORTUNITYID =:OppId ];
        
        lstwrapper = new list<oliwrapper>();
        for(opportunitylineitem oli : Opptyline){
            lstwrapper.add(new oliwrapper(false,oli));
        }
        list<OPPORTUNITYLINEITEM> vrlist = [SELECT ID,OPPORTUNITYID,Product2.Material_No__c,product2.name,product2.Levels_1__c,product2.Levels_2__c,product2.Hierarchy_Level_4_Description__c,product2.Hierarchy_Level_3_Description__c,product2.Hierarchy_Level_1_Description__c,product2.Hierarchy_Level_2_Description__c,TotalPrice, Unit_of_measure__c,SKU_Number__c,SKU_Number__r.GE_LGT_EM_MaterialDescription__c, SKU_Number__r.GE_LGT_EM_SAP_MaterialNumber__c, Product_Hierarchy_Code__c, Product2.IsActive,Product2.Level_1__c,Product2.Level_2__c,Product2.Level_3__c,Product2.GE_LGT_Product_Line__c,Product2.GE_LGT_Product_Group__c,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,GE_LGT_Level1__c,GE_LGT_Level2__c,GE_LGT_Level3__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,Confirmed__c,Cut_off_date__c  FROM OPPORTUNITYLINEITEM where Product2.IsActive=True AND Product2.Product_Hierarchy_Code__c!=NULL and (SKU_Number__r.Level_4__c!=NULL AND SKU_Number__r.Level_4__c!='0') AND (NOT SKU_Number__r.Level_1__c LIKE :filters) AND (NOT SKU_Number__r.GE_LGT_EM_ProductHierarchy__c LIKE :filters) order by CreatedDate desc limit 10];
        Map<id,OPPORTUNITYLINEITEM> mapidByp=new Map<id,OPPORTUNITYLINEITEM>();
        for(OPPORTUNITYLINEITEM o1:vrlist){
            
            mapidByp.put(o1.Product2id,o1);
            o1.Product2.IsActive=FALSE;
        } 
        for(id o1:mapidByp.keyset()){
            Opptyline1.add(mapidByp.get(o1));
            
        }
        multiLines = opp.OpportunityLineItems;  
        datetime dt = Opp.GE_LGT_Expected_PO_Receipt_Date__c;
    }
    
    public GE_LGT_ProductsSearch(ApexPages.StandardSetController controller) 
    {    
    }
    public void deloli() {
        List<opportunitylineitem> listForDel = new List<opportunitylineitem>();
        List<oliwrapper> listTempWrapper = new List<oliwrapper>();
        map<id,OpportunityLineItem> listbfrdel = new map<id,OpportunityLineItem>([select id,Product2.Material_No__c,UnitPrice,Quantity,SKU_Number__r.GE_LGT_EM_SAP_MaterialNumber__c,SKU_Number__r.GE_LGT_EM_MaterialDescription__c,product2.Hierarchy_Level_4_Description__c,product2.Hierarchy_Level_3_Description__c,product2.Hierarchy_Level_1_Description__c,product2.Hierarchy_Level_2_Description__c,(SELECT id,OpportunityLineItemId,Description   FROM OpportunityLineItemSchedules) from OpportunityLineItem where Id in: Opptyline]);
        List<OpportunityLineItem> listopptyl1 = new List<OpportunityLineItem>();
        //only admin/super user can edit the opp product .
        
        if((opp.stagename=='Closed Lost' || opp.stagename=='PO Received') && !profileMap.containsKey(UserInfo.getProfileId()))
        {
            ApexPages.Message errormsg =new ApexPages.Message(ApexPages.severity.Error,'Users cannot modify an opportunity Products that are PO Received or Closed Lost');
            ApexPages.addMessage(errormsg);  
            checksave1=true;
        }
        
        else {
            
            boolean delprd=false;
            addb=False;
            for(oliwrapper w : lstWrapper) {
                if(w.b ){
                    if(listbfrdel.containskey(w.oli.id)){
                        listForDel.add(w.oli);  
                    }
                    listopptyl1.add(w.oli);
                }
                else {
                    delprd=true;
                    listTempWrapper.add(w);
                } 
            }
            
            if(listTempWrapper.size()>0){
                opptyline.clear();
                lstWrapper.clear();
                lstWrapper.addall(listTempWrapper);
                for(oliwrapper wcheck :listTempWrapper){
                    opptyline.add(wcheck.oli);
                }
            }
            if(listForDel.size() > 0) {
                try{
                    checksave1=true;
                    if(listForDel.size()==lstwrapper.size() && (opp.stagename=='S4 Negotiate'||opp.stagename=='S5 Close'||opp.stagename=='S3 Solve') && opp.Owner_Pole_Opp__c=='North America'){
                        opp.stagename='S2 Evaluate';
                        update opp;
                    }
                    
                    delete listForDel;
                    if(delprd==false){
                        opptyline.clear();
                    }
                    if(listTempWrapper.size()>0){
                        opptyline.clear();
                        lstWrapper.clear();
                        lstWrapper.addall(listTempWrapper);
                        for(oliwrapper wcheck :listTempWrapper){
                            opptyline.add(wcheck.oli);
                        }
                    }
                    flagrecordupsert=false;
                    flagrecordupsert1=false;
                    check1scdule=false;
                    d=true;
                }
                catch(exception e){
                    checksave1=true;
                }
                
                lstWrapper = listTempWrapper;
            } else if(listForDel.size()==0 && listopptyl1.size()==0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select atleast one Product to delete'));
                checksave1=false;
            }
        }
    }
    
    
    
    // First Page Method
    public void firstcmd(){
        productSearchList = new list<product2>();
        inte = 0;
        addb=False;
        for(integer i = inte;  i < inte + 25; i++){
            productSearchList.add(prdlist[i]);
        }
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
    }
    // Last Page Method
    public void lastcmd(){
        productSearchList = new list<product2>();
        addb=False;
        inte = prdlist.size()-25;
        for(integer i = inte;  i < inte + 25; i++){
            productSearchList.add(prdlist[i]);
        }
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
    }
    
    
    // Prev Page Method
    public void prevcmd(){
        productSearchList = new list<product2>();
        addb=False;
        inte = inte - 25;
        for(integer i = inte;  i < inte + 25; i++){
            productSearchList.add(prdlist[i]);
        }
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
    }
    
    // Next Page Method
    public void nextcmd(){
        productSearchList = new list<product2>();
        inte = inte + 25;
        addb=False;
        for(integer i = inte;  i < inte + 25; i++){
            productSearchList.add(prdlist[i]);
        }
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
    }
    
    
    //Below Code for Search for Products by Name
    public void searchProduct(){
        falgtoshowproductsearchlist=true;
        falgtoshowMMobjectsearchlist=false;
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
        addb=False;
        if(searchStr!=Null)
        {
            check =true;
            prdList =[select Name,Hierarchy_Level_4_Description__c,Hierarchy_Level_3_Description__c,Hierarchy_Level_2_Description__c,Hierarchy_Level_1_Description__c,(SELECT ID,Name,CurrencyIsoCode,Product2Id FROM pricebookentries  WHERE PRICEBOOK2ID=:opp.PRICEBOOK2ID AND CurrencyIsoCode=:opp.CurrencyIsoCode),Description,Level_1__c,Level_2__c,Level_3__c,Levels_1__c,Levels_2__c,Levels_3__c,GE_LGT_Product_Group__c,GE_LGT_Product_Line__c,GE_LGT_Product_Family__c,IsActive from Product2 where (Levels_3__c Like : '%'+ searchStr +'%' or Name Like : '%'+ searchStr +'%') AND isactive=true AND  (NOT Product_Hierarchy_Code__c LIKE :filters) limit 100];
            for(Product2 prd :prdList) {
                
                prd.isActive = false;
            }
        }
        
        productSearchList = new list<product2>();
        inte = 0;
        if(prdlist.size() > 25){
            prdlistSet.addAll(prdlist);
            for(integer i = inte;  i < inte + 25; i++){
                productSearchList.add(prdlist[i]);
            }
            integ = prdlist.size()- 25; 
        }
        else{
            productSearchList = prdlist;
            prdlistSet.addAll(prdlist);
            integ = -1;
        }
        flag=false;
        if(productSearchList.isempty()){
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.WARNING,'SKU/CAT Logic/Description/Product is not found');
            ApexPages.addMessage(errormsg);
            checkResults=true;
            check1=false;
        }
        
    }
    public boolean b{get;set;}
    // save Method 
    public void  Saveoli()
    {
        boolean flagCheck = false;
        if((opp.stagename=='Closed Lost' || opp.stagename=='PO Received') && !profileMap.containsKey(UserInfo.getProfileId()))
        {
            ApexPages.Message errormsg =new ApexPages.Message(ApexPages.severity.Error,'Users cannot modify an opportunity Products that are PO Received or Closed Lost');
            ApexPages.addMessage(errormsg);  
            checksave1=true;
            flagCheck = true;
        }
        
        else{ 
            
            for(oliwrapper wc: lstwrapper) 
            {
                if(wc.oli.Quantity==0 || wc.oli.UnitPrice==0)
                {
                    ApexPages.Message errormsg =new ApexPages.Message(ApexPages.severity.Error,'To save a product Quantity,Sales Price per Unit are mandatory');
                    ApexPages.addMessage(errormsg);  
                    checksave1=true;
                    flagCheck = true;
                }
                
            }
            
            if(flagCheck == false){
                try{
                    d=false;
                    addb=False;
                    checksave1=true;
                    system.debug('Opptylinesaveoli:'+Opptyline);
                    flagrecordupsert=true;
                    flagrecordupsert1=true;
                    upsert Opptyline;
                    
                    flagrecordupsert1=false;
                    
                }
                catch(exception e)
                {
                    flagrecordupsert = false;
                    flagrecordupsert1=false;
                    b=false;
                    d = False;
                    
                }
                check = false;
                
            }
        }      
        prdListSet=new list<product2>();
        keyword =null;
        searchStr=null;
        flag=false;
    }
    
    // Cancel pagereference method
    public pageReference cancelprod()
    {  
        d = False;
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
        addb=False;
        PageReference pf = new PageReference('/' + OppID);
        pf.setRedirect(true);
        return pf;
        
    }
    
    // Save & Go To Oppty pagereference method
    public pageReference savegtooppty()
    {
        Saveoli();
        if (!ApexPages.hasMessages()){
            PageReference pf = new PageReference('/' + OppID);
            pf.setRedirect(true);
            return pf;
        }
        return null;
        
        
    }
    public void prevc(){
        system.debug('inte ==== '+inte);
        productSearchList = new list<product2>();
        addb=False;
        
        for(integer i = inte;  i <= inte; i++){
            productSearchList.add(prdlist[i]);
        }
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
    }
    public void nextc(){
        system.debug('inte ==== '+inte);
        productSearchList = new list<product2>();
        inte = inte + 25;
        addb=False;
        for(integer i = inte;  i < inte + 25; i++){
            productSearchList.add(prdlist[i]);
        }
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
    }
    
    // Extension Page Reference Method
    public void onLoadPage_Products(){
        addb=False;
        fblist = new Product2();
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
        ProductNames = new List<String>();
        prdList  = [Select Id, Name,Description,Levels_3__c,IsActive from  Product2 where isactive=true AND Product_Hierarchy_Code__c!=NULL];
        for( Product2 pname :  prdList){
            if(pname.Levels_3__c!= null)
                ProductNames.add(pname.Levels_3__c.substringafter('-').removeEndIgnoreCase('-3'));
            else if(pname.Name!= null)
                ProductNames.add(pname.Name.substringafter('-').removeEndIgnoreCase('-4'));    
        }
        prdList.clear();
        JSONString = JSON.serialize(ProductNames);
        MatMasterDetails=new List<String>();
        matMasList=[SELECT ID,GE_LGT_EM_MaterialDescription__c,GE_LGT_EM_SAP_MaterialNumber__c,GE_LGT_EM_ProductHierarchy__c,Material_Type__c  FROM GE_LGT_EM_MaterialMaster__c where  (Level_4__c!=NULL AND Level_4__c!='0') AND (Product_Hierarchy_Code_2__C!=NULL) 
                            AND  (NOT Level_1__c LIKE :filters) AND (NOT GE_LGT_EM_ProductHierarchy__c LIKE :filters) 
                             limit 1000];
        for(GE_LGT_EM_MaterialMaster__c m:matMasList)
        {
            if(m.GE_LGT_EM_MaterialDescription__c!=Null)
                MatMasterDetails.add(m.GE_LGT_EM_SAP_MaterialNumber__c+'::'+m.GE_LGT_EM_MaterialDescription__c);
        }
        matMasList.clear();
        JSONString1 = JSON.serialize(MatMasterDetails);
    }
    
    public string strind{get; set;}
    // Add Method for Search by Product Name/ Product Family
    public void addLines() {
        d = false;
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
        addb=True;
        Set<String> setProdID = new Set<String>();
        Map<string,string> mapPrdEnt = new Map<string,string>();
        for(Product2 pd :productList) {
            setProdID.add(pd.ID);
        }
        for(Product2 pd :prdListSet) {  
            setProdID.add(pd.ID);
        }
        lstEntryID =[SELECT ID,Name,Product2Id,CurrencyIsoCode FROM PRICEBOOKENTRY WHERE PRICEBOOK2ID=:opp.PRICEBOOK2ID AND CurrencyIsoCode=:opp.CurrencyIsoCode AND PRODUCT2ID IN :setProdID];
        OpportunityLineItem li = new OpportunityLineItem();
        for(PriceBookEntry pe:lstEntryID) {
            mapPrdEnt.put(pe.PRODUCT2ID,pe.id);
        }
        if(flag==false)
        {
            Opptyline = [SELECT ID,product2.name,SKUNumber__c,product2.Levels_1__c,product2.Levels_2__c,product2.Hierarchy_Level_4_Description__c,product2.Hierarchy_Level_3_Description__c,product2.Hierarchy_Level_1_Description__c,product2.Hierarchy_Level_2_Description__c,Unit_of_measure__c,SKU_Number__r.GE_LGT_EM_SAP_MaterialNumber__c,SKU_Number__r.GE_LGT_EM_MaterialDescription__c,TotalPrice,SKU_Number__c,OPPORTUNITYID,Product_Hierarchy_Code__c,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,GE_LGT_Level1__c,GE_LGT_Level2__c,GE_LGT_Level3__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,Confirmed__c,Cut_off_date__c,Product2.Material_No__c,(SELECT Id,OpportunityLineItemId,Description,Quantity,Revenue,ScheduleDate,Type FROM OpportunityLineItemSchedules ORDER BY ScheduleDate ASC)  FROM OPPORTUNITYLINEITEM where OPPORTUNITYID =:OppId ];
            for(Product2 pd :prdListSet) {
                if(pd.IsActive || test.isrunningtest()) {
                    li = new OpportunityLineItem();
                    if(li.OPPORTUNITY.CurrencyIsoCode ==li.PRICEBOOKENTRY.CurrencyIsoCode) 
                    {
                        li.OpportunityID = opp.ID;
                        li.PricebookEntryID = mapPrdEnt.get(pd.ID); 
                        li.GE_LGT_Product_Name__c=pd.Hierarchy_Level_4_Description__c;
                        li.GE_LGT_Level1__c=pd.Hierarchy_Level_1_Description__c;
                        li.GE_LGT_Level2__c=pd.Hierarchy_Level_2_Description__c;
                        li.GE_LGT_Level3__c=pd.Hierarchy_Level_3_Description__c;
                        li.Quantity =0;
                        li.UnitPrice =0;
                        li.Unit_of_measure__c='piece(s)';
                        if(matMap!=NULL && matMap.size()>0)
                        {
                            li.SKU_Number__c=matMap.get(0);
                            matMap.clear();
                        }        
                        Opptyline.add(li);
                    }
                }
            }
            lstwrapper = new list<oliwrapper>();
            for(opportunitylineitem oli : Opptyline){
                lstwrapper.add(new oliwrapper(false,oli));
            }
            flag=true;
        }
        else
        {
            Set<OpportunityLineItem> oppLines=new Set<OpportunityLineItem>();
            List<Product2> dupProducts1=new List<Product2>();
            for(Product2 pd :prdListSet) 
            {
                for(Product2 pd1 :prdList) 
                {
                    if(pd1.IsActive && pd.Name==pd1.Name) 
                    {
                        
                        li = new OpportunityLineItem();
                        if(li.OPPORTUNITY.CurrencyIsoCode ==li.PRICEBOOKENTRY.CurrencyIsoCode) 
                        {
                            li.OpportunityID = opp.ID;
                            li.PricebookEntryID = mapPrdEnt.get(pd.ID);                    
                            li.GE_LGT_Product_Name__c=pd.Hierarchy_Level_4_Description__c;
                            li.GE_LGT_Level1__c=pd.Hierarchy_Level_1_Description__c;
                            li.GE_LGT_Level2__c=pd.Hierarchy_Level_2_Description__c;
                            li.GE_LGT_Level3__c=pd.Hierarchy_Level_3_Description__c;
                            li.Quantity =0;
                            li.UnitPrice =0; 
                            li.Unit_of_measure__c='piece(s)';
                            if(matMap!=NULL && matMap.size()>0)
                            {
                                li.SKU_Number__c=matMap.get(0);
                                matMap.clear();
                            }        
                            oppLines.add(li);
                            dupProducts1.add(pd);
                        }
                    }
                }
            }
            Set<Product2> dupProducts=new Set<Product2>();
            for(oliwrapper o:lstwrapper)
            {
                for(Product2 pd :dupProducts1) 
                {
                    if(pd.IsActive && pd.Name==o.oli.GE_LGT_Product_Name__c) 
                    {
                        dupProducts.add(pd);
                    }
                }
            }
            prdListSet.addAll(dupProducts);
            dupProducts.clear();
            dupProducts1.clear();
            opptyline.addall(oppLines);
            oppLines.clear();
        }
    }
    public void addLinesforMMsearchresults() {
        d = false;
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
        addb=True;
        Set<String> setProdID = new Set<String>();
        Map<string,string> mapPrdEnt = new Map<string,string>();
        for(Product2 pd :productList) {    
            setProdID.add(pd.ID);
        }
        for(GE_LGT_EM_MaterialMaster__c mm:matMasListSearchresult){
            if(matMasListSearchresultNext.containsKey(mm.id) && mm.Is_Active_Internal__c){
                matMasListSearchresultNext.remove(mm.id);
            }
        }
        matMasListSearchresult.addall(matMasListSearchresultNext.values()); 
        for(GE_LGT_EM_MaterialMaster__c mm:matMasListSearchresult){
            if(mm != null&& mm.Product_Hierarchy_Code_2__c != null && mm.Is_Active_Internal__c){
                setProdID.add(mm.Product_Hierarchy_Code_2__r.id);   
            }
            
        }
        lstEntryID =[SELECT ID,Name,Product2Id,CurrencyIsoCode FROM PRICEBOOKENTRY WHERE PRICEBOOK2ID=:opp.PRICEBOOK2ID AND CurrencyIsoCode=:opp.CurrencyIsoCode AND PRODUCT2ID IN :setProdID];
        OpportunityLineItem li = new OpportunityLineItem();
        map<id,product2> prdListSet1=new map<id,product2>([select id,levels_1__c,Levels_2__c,Levels_3__c,Hierarchy_Level_4_Description__c,Hierarchy_Level_1_Description__c,Hierarchy_Level_2_Description__c,Hierarchy_Level_3_Description__c,name from product2 where id in:setProdID]);
        for(PriceBookEntry pe:lstEntryID) {
            
            mapPrdEnt.put(pe.PRODUCT2ID,pe.id);
            
        }
        if(flag==false)
        {
            Opptyline = [SELECT ID,product2.name,SKUNumber__c,product2.Levels_1__c,product2.Levels_2__c,product2.Hierarchy_Level_4_Description__c,product2.Hierarchy_Level_3_Description__c,product2.Hierarchy_Level_1_Description__c,product2.Hierarchy_Level_2_Description__c,Unit_of_measure__c,SKU_Number__r.GE_LGT_EM_SAP_MaterialNumber__c,SKU_Number__r.GE_LGT_EM_MaterialDescription__c,TotalPrice,SKU_Number__c,OPPORTUNITYID,Product_Hierarchy_Code__c,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,GE_LGT_Level1__c,GE_LGT_Level2__c,GE_LGT_Level3__c,Product2.Material_No__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,Confirmed__c,Cut_off_date__c,(SELECT Id,OpportunityLineItemId,Description,Quantity,Revenue,ScheduleDate,Type FROM OpportunityLineItemSchedules ORDER BY ScheduleDate ASC)  FROM OPPORTUNITYLINEITEM where OPPORTUNITYID =:OppId ];
            for(GE_LGT_EM_MaterialMaster__c pd:matMasListSearchresult) {
                if(pd.Product_Hierarchy_Code_2__r.isActive && pd.Is_Active_Internal__c) {
                    li = new OpportunityLineItem();
                    if(li.OPPORTUNITY.CurrencyIsoCode ==li.PRICEBOOKENTRY.CurrencyIsoCode) 
                    {
                        li.OpportunityID = opp.ID;
                        li.PricebookEntryID = mapPrdEnt.get(pd.Product_Hierarchy_Code_2__r.id); 
                        li.GE_LGT_Product_Name__c=prdListSet1.get(pd.Product_Hierarchy_Code_2__r.id).Hierarchy_Level_4_Description__c;
                        li.GE_LGT_Level1__c=prdListSet1.get(pd.Product_Hierarchy_Code_2__r.id).Hierarchy_Level_1_Description__c;
                        li.GE_LGT_Level2__c=prdListSet1.get(pd.Product_Hierarchy_Code_2__r.id).Hierarchy_Level_2_Description__c;
                        li.GE_LGT_Level3__c=prdListSet1.get(pd.Product_Hierarchy_Code_2__r.id).Hierarchy_Level_3_Description__c;
                        li.description=pd.GE_LGT_EM_MaterialDescription__c;
                        li.Quantity =0;
                        li.UnitPrice =0;
                        li.Unit_of_measure__c='piece(s)';
                        li.SKU_Number__c=pd.id; 
                        
                        li.SKUNumber__c =pd.GE_LGT_EM_SAP_MaterialNumber__c;                    
                        Opptyline.add(li);
                    }
                }
            }
            lstwrapper = new list<oliwrapper>();
            for(opportunitylineitem oli : Opptyline){
                lstwrapper.add(new oliwrapper(false,oli));
            }
            //  flag=true; commented this because of RQT-0000991
        }
        else
        {
            Set<OpportunityLineItem> oppLines=new Set<OpportunityLineItem>();
            List<Product2> dupProducts1=new List<Product2>();
            for(GE_LGT_EM_MaterialMaster__c pd:matMasListSearchresult) 
            {
                if(pd.Product_Hierarchy_Code_2__r.isActive && pd.Is_Active_Internal__c)                        
                {
                    li = new OpportunityLineItem();
                    if(li.OPPORTUNITY.CurrencyIsoCode ==li.PRICEBOOKENTRY.CurrencyIsoCode) 
                    {
                        li.OpportunityID = opp.ID;
                        li.PricebookEntryID = mapPrdEnt.get(pd.Product_Hierarchy_Code_2__r.id);                    
                        li.GE_LGT_Product_Name__c=prdListSet1.get(pd.Product_Hierarchy_Code_2__r.id).Hierarchy_Level_4_Description__c;
                        li.GE_LGT_Level1__c=prdListSet1.get(pd.Product_Hierarchy_Code_2__r.id).Hierarchy_Level_1_Description__c;
                        li.GE_LGT_Level2__c=prdListSet1.get(pd.Product_Hierarchy_Code_2__r.id).Hierarchy_Level_2_Description__c;
                        li.GE_LGT_Level3__c=prdListSet1.get(pd.Product_Hierarchy_Code_2__r.id).Hierarchy_Level_3_Description__c;
                        li.description=pd.GE_LGT_EM_MaterialDescription__c;
                        li.Quantity =0;
                        li.UnitPrice =0; 
                        li.Unit_of_measure__c='piece(s)';
                        li.SKU_Number__c=pd.id; 
                        
                        li.SKUNumber__c =pd.GE_LGT_EM_SAP_MaterialNumber__c;                            
                        oppLines.add(li);
                        prdListSet1.get(pd.Product_Hierarchy_Code_2__r.id).isActive=pd.Product_Hierarchy_Code_2__r.isActive;
                        dupProducts1.add(prdListSet1.get(pd.Product_Hierarchy_Code_2__r.id));
                    }
                }
            }
            opptyline.addall(oppLines);
            oppLines.clear();
            
        }
        matMasListSearchresultNext.clear();
        blockSize=10;
        index=0;
    }
    public void addLines1() {
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
        addb =True;
        check1=false;
        List<OpportunityLineItem> Opptyline2=new List<OpportunityLineItem>();
        Set<String> setProdID1 = new Set<String>();
        List<Product2> prdList=new List<Product2>();
        Map<string,string> mapPrdeEnt = new Map<string,string>();
        for(OPPORTUNITYLINEITEM oltm :Opptyline1) {
            setProdID1.add(oltm.Product2id);
        }
        lstEntryID =[SELECT ID,Name,Product2Id FROM PRICEBOOKENTRY WHERE PRICEBOOK2ID=:opp.PRICEBOOK2ID AND CurrencyIsoCode=:opp.CurrencyIsoCode AND PRODUCT2ID IN :setProdID1];
        OpportunityLineItem li = new OpportunityLineItem();
        for(PriceBookEntry pe1:lstEntryID) {
            mapPrdeEnt.put(pe1.PRODUCT2ID,pe1.id);
        }
        for(OPPORTUNITYLINEITEM oltm :Opptyline1) {
            if(oltm.Product2.IsActive || test.isrunningtest()) {
                li = new OpportunityLineItem();
                if(li.OPPORTUNITY.CurrencyIsoCode ==li.PRICEBOOKENTRY.CurrencyIsoCode) 
                {
                    li.OpportunityID = opp.ID;
                    li.PricebookEntryID = mapPrdeEnt.get(oltm.PRODUCT2ID); 
                    li.GE_LGT_Product_Name__c=oltm.Product2.Hierarchy_Level_4_Description__c;
                    li.GE_LGT_Level1__c=oltm.Product2.Hierarchy_Level_1_Description__c;
                    li.GE_LGT_Level2__c=oltm.Product2.Hierarchy_Level_2_Description__c;
                    li.GE_LGT_Level3__c=oltm.Product2.Hierarchy_Level_3_Description__c;
                    li.Quantity =0;
                    li.UnitPrice =0;  
                    li.Unit_of_measure__c='piece(s)';      
                    Opptyline2.add(li);
                    prdList.add(oltm.Product2);
                }
            }
        }
        lstwrapper = new list<oliwrapper>();
        opptyline.addall(Opptyline2);
        for(opportunitylineitem oli : Opptyline){
            lstwrapper.add(new oliwrapper(false,oli));
        }
        if(prdList.size()>0)
        {
            prdlistSet.addAll(prdList);
        }
    }
    
    //  Upload Opportunity Products File
    public Pagereference ReadFile(){  
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
        Set<String> skuDetails=new Set<String>();       
        Map<String,String> mapPE = new map <String,String>(); 
        
        
        if(contentFile != null){        
            if (csvfile.endsWith('.csv')){                                    
                
                csvfile=contentFile.toString();     
                
                filelines = csvfile.split('\n');
                Set<String> bs = new Set<String>(); 
                oltoupload = new List<OpportunityLineItem>();
                String[] str = new String[]{};  
                    
                    if (filelines[1].contains(';'))
                {
                    str = filelines[1].split(';');
                }
                else
                {
                    str = filelines[1].split(',');
                }
                if(str.size()<4){
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'File format is not correct, please use template, download and after you filled it with data, try to upload again.');
                    ApexPages.addMessage(errormsg);
                    return null;
                }
                rowNum_ColumnNums_Map = new Map<Integer, Set<String>>();
                set < Integer > InvalidDataRows;
                String errorRows = '';
                String errorMsgToBeShown = '';
                InvalidDataRows = HeadCheck();
                if (InvalidDataRows.size() > 0)
                {
                    for (Integer rowNum: rowNum_ColumnNums_Map.keySet()) {
                        
                        String errorRowsData = 'Row No:' + rowNum  ;
                        
                        for (String colNum: rowNum_ColumnNums_Map.get(rowNum)) {
                            errorRowsData = errorRowsData + ' ' + colNum;
                        }
                        errorMsgToBeShown = errorMsgToBeShown + '<br/>' + errorRowsData + '<br/>' ;
                        errorRowsData = '';
                    }
                    
                    String errorMsg = errorMsgToBeShown + '<br/>' +'  Please correct the data and upload again';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
                    
                    check1=true; 
                    checksave1=false;
                    checkResults=false;
                }  
                else {
                    if (filelines.size() > 1)
                    {
                        system.debug(' filelines.size()@@'+ filelines.size());
                        List<String> matNumList=new List<String>();
                        List<String> matNumList1=new List<String>();
                        String givenFileType=''; //possible types are :::  CATLOGICFILE/PRODUCTCODEFILE/BOTHFILE
                        integer bothFileCount=0;
                        for (Integer i=2; i<filelines.size(); i++)
                        {
                            if (filelines[i].contains('"')) {
                                filelines[i] = filelines[i].replace('""','!!');
                                string[] tempArr = new string[]{};
                                    tempArr = filelines[i].split('"');
                                for(integer j=0; j<tempArr.size(); j++) {
                                    if(math.mod(j,2) == 1) {
                                        tempArr[j] = tempArr[j].replace(',',';;');
                                    }
                                }
                                filelines[i] = '';
                                for(integer j=0; j<tempArr.size(); j++) {
                                    filelines[i] = filelines[i] + tempArr[j];
                                }
                                filelines[i] = filelines[i].replace('!!','"');
                            }
                            String[] inputvalues = new String[]{};                  
                                system.debug(' filelines[i]@@'+ filelines[i]);
                            if(filelines[i].contains(',')){
                                
                                inputvalues = filelines[i].split(',');
                                system.debug(' inputvalues@@'+i+'@@'+ inputvalues);
                            }
                            else if(filelines[i].contains(';')){
                                inputvalues = filelines[i].split(';');
                            }
                            inputvalues[0] = inputvalues[0].replace(';;',',');
                            OpportunityLineItem il = new OpportunityLineItem();
                            il.OpportunityID = OppId; 
                            
                            if ((inputvalues[0] != null) && (inputvalues[0] != ''))
                            {
                                system.debug(' inputvalues[0] first if'+ inputvalues[0]);
                                il.Description = inputvalues[0];
                                skuDetails.add(inputvalues[0]);
                                if((inputvalues[1] == null) || (inputvalues[1] == ''))
                                {
                                    system.debug(' inputvalues[0] first if if'+ inputvalues[0]);
                                    matNumList1.add(inputvalues[0]);
                                    givenFileType='CATLOGICFILE';
                                }
                            } 
                            
                            if ((inputvalues[1] != null) && (inputvalues[1] != ''))
                            {
                                system.debug(' inputvalues[1] second if'+ inputvalues[1]);
                                il.SKUNumber__c= inputvalues[1];
                                il.SAPDescription__c= inputvalues[1];
                                system.debug(' inputvalues[1]@@'+ inputvalues[1]);
                                matNumList.add(inputvalues[1]);
                                skuDetails.add(inputvalues[1]);
                                if((inputvalues[0] == null) || (inputvalues[0] == ''))
                                {
                                    
                                    givenFileType='PRODUCTCODEFILE';
                                    bothFileCount=bothFileCount+1;
                                }
                            }
                            if (((inputvalues[0] != null) && (inputvalues[0] != '')) &&((inputvalues[1] != null) && (inputvalues[1] != '')))
                            {
                                givenFileType='BOTHFILE';
                            }
                            
                            if ((inputvalues[2] != null) && (inputvalues[2] != ''))
                            {
                                system.debug(' inputvalues[2] third if'+ inputvalues[2]);
                                il.QUANTITY = Decimal.Valueof(inputvalues[2]);
                            }
                            else
                            {
                                system.debug(' inputvalues[2] third else '+ inputvalues[2]);
                                il.QUANTITY=NULL;
                            }
                            if ((inputvalues[3] != null) && (inputvalues[3] != ''))
                            {
                                system.debug(' inputvalues[3] fourth if'+ inputvalues[3]);
                                il.UNITPRICE= Decimal.valueof(inputvalues[3].trim());
                            }
                            else
                            {
                                system.debug(' inputvalues[0] fourth else'+ inputvalues[3]);
                                il.UNITPRICE=NULL;
                            }
                            
                            il.ServiceDate=NULL;
                            
                            il.Unit_of_measure__c='piece(s)';
                            oltoupload.add(il); 
                            system.debug(' il'+ il);
                            system.debug(' skuDetails'+ skuDetails);
                        }
                        Map<String,String> CatlogicwithProductCodeMap = new Map<String,String>();
                        Map<String,String> ProductCodewithCatlogicMap = new Map<String,String>();
                        List<GE_LGT_EM_MaterialMaster__c> matMasListReadFile=new List<GE_LGT_EM_MaterialMaster__c>();
                        List<GE_LGT_EM_MaterialMaster__c> matMasListReadFile1=[SELECT ID,Material_Type__c,GE_LGT_EM_ProductHierarchy__c,GE_LGT_EM_SAP_MaterialNumber__c,GE_LGT_EM_MaterialDescription__c,Product_Hierarchy_Code_2__r.Name,Level_1__c,Level_2__c,Level_3__c,Level_4__c,Level_5__c FROM GE_LGT_EM_MaterialMaster__c
                                                                WHERE (GE_LGT_EM_SAP_MaterialNumber__c IN:matNumList or GE_LGT_EM_MaterialDescription__c IN:matNumList1) 
                                                                AND (Level_4__c!=NULL AND Level_4__c!='0') AND (Product_Hierarchy_Code_2__C!=NULL) 
                                                                AND  (NOT Level_1__c LIKE :filters) AND (NOT GE_LGT_EM_ProductHierarchy__c LIKE :filters) ];
                        System.debug('matNumList'+matNumList); 
                        
                        
                        //added for RQT-0001146
                        System.debug('level4list'+level4Set);
                        List<Id> productIdset= new List<ID>();
                        for(GE_LGT_EM_MaterialMaster__c mm:matMasListReadFile1)
                        {
                            productIdset.add(mm.Product_Hierarchy_Code_2__c);
                            // GE_LGT_EM_MaterialDescription__c: catlogic
                            //GE_LGT_EM_SAP_MaterialNumber__c: product code
                            CatlogicwithProductCodeMap.put(mm.GE_LGT_EM_MaterialDescription__c,mm.GE_LGT_EM_SAP_MaterialNumber__c);
                            ProductCodewithCatlogicMap.put(mm.GE_LGT_EM_SAP_MaterialNumber__c,mm.GE_LGT_EM_MaterialDescription__c);
                            
                            System.debug('mm and GE_LGT_EM_SAP_MaterialNumber__c::'+mm.GE_LGT_EM_SAP_MaterialNumber__c+mm.Product_Hierarchy_Code_2__r.name);
                        }
                        
                        System.debug('productIdset ::'+productIdset.size());
                        //System.debug('matMasListReadFile1 ::'+matMasListReadFile1.size());
                        Map<Id,Product2> Productlist = new Map<ID,Product2>([Select Id , name from Product2 where ID IN:productIdset AND  IsActive=True ]);
                        /*for(Product2 pp:Productlist.values())
{
System.debug('Product id ::'+pp.id);
}*/
                        
                        System.debug('productslist' + Productlist.keyset() +'count of productslist::'+Productlist.size());
                        List<PRICEBOOKENTRY> listPE= [SELECT ID,Name,CurrencyIsoCode,Product2Id,Product2.Name,IsActive FROM PRICEBOOKENTRY WHERE PRICEBOOK2ID=:opp.PRICEBOOK2ID ANd Product2Id IN:Productlist.keyset() AND CurrencyIsoCode=:opp.CurrencyIsoCode AND  IsActive=True];
                        System.debug('size of excel products::'+listPE.size()+'count of prod::'+matNumList.size());
                        System.debug('list of excel products'+listPE);
                        for(PRICEBOOKENTRY p : listPE){
                            mapPE.put(p.Product2Id,p.id);
                            System.debug('PE product name:: '+p.Product2Id);
                        }
                        system.debug('maps of PE ::@@'+mapPE.size());
                        system.debug('maps of keys ::@@'+mapPE.keyset());
                        system.debug('maps of valus ::@@'+mapPE.values());
                        for(String str1:mapPE.keyset())
                        {
                            System.debug(str1+'@@'+mapPE.get(str1));
                            
                        }
                        system.debug('matNumList1@@'+matNumList1);
                        List<GE_LGT_EM_MaterialMaster__c> matMasListReadFile2=[SELECT ID,Material_Type__c,GE_LGT_EM_ProductHierarchy__c,GE_LGT_EM_SAP_MaterialNumber__c,GE_LGT_EM_MaterialDescription__c,Product_Hierarchy_Code_2__r.Name,Level_1__c,Level_2__c,Level_3__c,Level_4__c,Level_5__c FROM GE_LGT_EM_MaterialMaster__c
                                                                 WHERE GE_LGT_EM_MaterialDescription__c IN:matNumList1 
                                                                 AND (Level_4__c!=NULL AND Level_4__c!='0') AND (Product_Hierarchy_Code_2__C!=NULL) 
                                                                AND  (NOT Level_1__c LIKE :filters) AND (NOT GE_LGT_EM_ProductHierarchy__c LIKE :filters) ];
                        system.debug('matMasListReadFile2@@'+matMasListReadFile2);
                        Set<String> level4Set=new Set<String>();
                        if(matMasListReadFile1!=NULL && matMasListReadFile1.size()>0)
                        {
                            matMasListReadFile.addAll(matMasListReadFile1);
                        }
                        if(matMasListReadFile2!=NULL && matMasListReadFile2.size()>0)
                        {
                            for(GE_LGT_EM_MaterialMaster__c m:matMasListReadFile2)
                            {
                                if(!level4Set.contains(m.GE_LGT_EM_SAP_MaterialNumber__c))
                                {
                                    matMasListReadFile.add(m);
                                    level4Set.add(m.GE_LGT_EM_SAP_MaterialNumber__c);
                                }
                            }                               
                        }
                        
                        system.debug('matMasListReadFile@@'+matMasListReadFile);
                        Set<String> resultantSKUs=new Set<String>();
                        for(GE_LGT_EM_MaterialMaster__c m:matMasListReadFile)
                        {
                            system.debug('GE_LGT_EM_MaterialDescription__c,GE_LGT_EM_SAP_MaterialNumber__c@@'+m.GE_LGT_EM_MaterialDescription__c+'@@'+m.GE_LGT_EM_SAP_MaterialNumber__c);
                            if(m.GE_LGT_EM_MaterialDescription__c!=NULL)
                            {
                                resultantSKUs.add(m.GE_LGT_EM_MaterialDescription__c);
                            }
                            if(m.GE_LGT_EM_SAP_MaterialNumber__c!=NULL)
                            {
                                resultantSKUs.add(m.GE_LGT_EM_SAP_MaterialNumber__c);
                            }
                        }
                        system.debug('resultantSKUs@@'+resultantSKUs);
                        Boolean countFlag=false;
                        for(String s:skuDetails)
                        {
                            system.debug('s@@'+s);
                            if(!resultantSKUs.contains(s))
                            {
                                system.debug('entered@@ in to if');
                                countFlag=true;
                            }
                        }
                        Map<String,OpportunityLineItem> oliMap=new Map<String,OpportunityLineItem>();
                        Map<String,OpportunityLineItem> oliDescMap=new Map<String,OpportunityLineItem>();
                        set<OpportunityLineItem> toInsert=new set<OpportunityLineItem>();
                        set<OpportunityLineItem> toUpdate=new set<OpportunityLineItem>();
                        for(OpportunityLineItem o:Opptyline)
                        {
                            oliMap.put(o.SKU_Number__r.GE_LGT_EM_SAP_MaterialNumber__c,o);
                            oliDescMap.put(o.Description,o);
                        }
                        
                        if(countFlag)
                        {
                            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.WARNING,'SKU Number does not exist');
                            ApexPages.addMessage(errormsg);
                            check1=true; 
                            checksave1=false;
                            flagrecordupsert=false;
                            checkResults=false;
                        }
                        system.debug('oltoupload@@'+oltoupload);
                        system.debug('matMasListReadFile@@'+matMasListReadFile);
                        system.debug('CatlogicwithProductCodeMap@@'+CatlogicwithProductCodeMap);
                        //system.debug('ProductCodewithCatlogicMap@@'+ProductCodewithCatlogicMap);
                        
                        if(matMasListReadFile!=NULL && matMasListReadFile.size()>0)
                        {
                            for(OpportunityLineItem o:oltoupload)
                            {
                                for(GE_LGT_EM_MaterialMaster__c m:matMasListReadFile)
                                {
                                    if((o.SKUNumber__c==m.GE_LGT_EM_SAP_MaterialNumber__c && m.Product_Hierarchy_Code_2__r.Name!=null && oliMap.containsKey(o.SKUNumber__c) && oliMap.get(o.SKUNumber__c).OpportunityLineItemSchedules.size()==0) || (o.Description==m.GE_LGT_EM_MaterialDescription__c && m.Product_Hierarchy_Code_2__r.Name!=null && oliDescMap.containsKey(o.Description) && oliDescMap.get(o.Description).OpportunityLineItemSchedules.size()==0))
                                    {
                                        System.debug('if!! first');
                                        o.SKU_Number__c=m.id;
                                        System.debug('mapPE.get(m.Product_Hierarchy_Code_2__c)@@'+mapPE.get(m.Product_Hierarchy_Code_2__c));
                                        //o.PricebookEntryID  = mapPE.get(m.Product_Hierarchy_Code_2__c);
                                        system.debug('o.SKUNumber__c@'+o.SKUNumber__c);
                                        system.debug('o.Description@'+o.Description);
                                        system.debug('oliMap@'+oliMap);
                                        system.debug('oliDescMap.get(o.Description)@'+oliDescMap.get(o.Description));
                                        //system.debug('oliDescMap.get(o.Description).SKUNumber__c@'+oliDescMap.get(o.Description).SKUNumber__c);
                                        
                                        //system.debug('CatlogicwithProductCodeMap@@'+CatlogicwithProductCodeMap);
                                        //system.debug('ProductCodewithCatlogicMap@@'+ProductCodewithCatlogicMap);
                                        
                                        //system.debug('CatlogicwithProductCodeMap@@'+CatlogicwithProductCodeMap.get(o.Description));
                                        if(o.SKUNumber__c!=NULL && oliMap.containsKey(o.SKUNumber__c))
                                        {
                                            o.id=oliMap.get(o.SKUNumber__c).ID;
                                            if(ProductCodewithCatlogicMap.get(o.SKUNumber__c)!=null && ProductCodewithCatlogicMap.get(o.SKUNumber__c)!='')
                                            {
                                                o.Description=ProductCodewithCatlogicMap.get(o.SKUNumber__c);
                                            }
                                            
                                        }
                                        else if(o.Description!=NULL && oliDescMap.containsKey(o.Description))
                                        {
                                            o.id=oliDescMap.get(o.Description).ID; 
                                            if(CatlogicwithProductCodeMap.get(o.Description)!=null && CatlogicwithProductCodeMap.get(o.Description)!='')
                                            {
                                                o.SKUNumber__c=CatlogicwithProductCodeMap.get(o.Description);
                                            }
                                            
                                        }
                                        system.debug('o##'+o);
                                        toUpdate.add(o);
                                        System.debug('if@@');
                                    }
                                    else if((o.SKUNumber__c==m.GE_LGT_EM_SAP_MaterialNumber__c && m.Product_Hierarchy_Code_2__r.Name!=null && oliMap.containsKey(o.SKUNumber__c) && oliMap.get(o.SKUNumber__c).OpportunityLineItemSchedules.size()>0)||(o.Description==m.GE_LGT_EM_MaterialDescription__c && m.Product_Hierarchy_Code_2__r.Name!=null && oliDescMap.containsKey(o.Description) && oliDescMap.get(o.Description).OpportunityLineItemSchedules.size()>0))
                                    {
                                        
                                        System.debug('else if!! second');
                                        if(!(o.SKUNumber__c==NULL ||o.SKUNumber__c==''))
                                        {
                                            o.SKU_Number__c=m.id;
                                            o.SKUNumber__c=m.GE_LGT_EM_SAP_MaterialNumber__c;
                                        }
                                        System.debug('first toInsert map::@@'+ mapPE.get(m.Product_Hierarchy_Code_2__c ));
                                        o.PricebookEntryID  = mapPE.get(m.Product_Hierarchy_Code_2__c);
                                        o.GE_LGT_Level1__c=m.Level_1__c;
                                        o.GE_LGT_Level2__c=m.Level_2__c;
                                        o.GE_LGT_Level3__c=m.Level_3__c;
                                        o.GE_LGT_Product_Name__c=m.Level_4__c;
                                        toInsert.add(o);
                                        System.debug('first toInsert PricebookEntryID::@@' + o.PricebookEntryID);
                                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.WARNING,'some of the items in your upload matches with Opp.Products which has schedules - pls correct your schedule');
                                        ApexPages.addMessage(errormsg);
                                        
                                    }
                                    else if(o.SKUNumber__c==m.GE_LGT_EM_SAP_MaterialNumber__c && m.Product_Hierarchy_Code_2__r.Name!=null && !oliMap.containsKey(o.SKUNumber__c))
                                    {
                                        System.debug('else if!! third');
                                        o.SKU_Number__c=m.id;
                                        System.debug('second toInsert map::@@'+ mapPE.get(m.Product_Hierarchy_Code_2__c ));
                                        o.PricebookEntryID  = mapPE.get(m.Product_Hierarchy_Code_2__c);
                                        o.GE_LGT_Level1__c=m.Level_1__c;
                                        o.GE_LGT_Level2__c=m.Level_2__c;
                                        o.GE_LGT_Level3__c=m.Level_3__c;
                                        o.SKUNumber__c=m.GE_LGT_EM_SAP_MaterialNumber__c;
                                        o.GE_LGT_Product_Name__c=m.Level_4__c;
                                        toInsert.add(o);
                                        System.debug('second toInsert pricebookid::'+ o.PricebookEntryID +':: o.GE_LGT_Product_Name__c::'  + m.Product_Hierarchy_Code_2__c);
                                    }
                                    else if(o.Description==m.GE_LGT_EM_MaterialDescription__c && m.Product_Hierarchy_Code_2__r.Name!=null)
                                    {
                                        System.debug('else if!! fourth');
                                        System.debug('third toInsert map::@@'+ mapPE.get(m.Product_Hierarchy_Code_2__c ));
                                        o.PricebookEntryID  = mapPE.get(m.Product_Hierarchy_Code_2__c);//'01u0Z00001Ai5Y3';
                                        o.SKU_Number__c=m.id;
                                        o.GE_LGT_Level1__c=m.Level_1__c;
                                        o.GE_LGT_Level2__c=m.Level_2__c;
                                        o.GE_LGT_Level3__c=m.Level_3__c;
                                        o.GE_LGT_Product_Name__c=m.Level_4__c;
                                        //o.SKUNumber__c=CatlogicwithProductCodeMap.get(o.Description);
                                        toInsert.add(o);
                                        System.debug('third toInsert pricebookid::@@'+ o.PricebookEntryID );
                                        System.debug('third toInsert pricebookid::@@'+ o);
                                        
                                    }else{
                                        System.debug('else if!! fifth');
                                    }
                                    
                                }
                                
                            }
                        }
                        check1=true;
                        checksave1=false;
                        checkResults=false;
                        d=false;
                        System.debug('toInsert@@$'+toInsert.size());
                        System.debug('toInsert@@$ before '+toInsert);
                        System.debug('givenFileType@@$ before '+givenFileType);
                        System.debug('bothFileCount@@$ before '+bothFileCount);
                        
                        if(toInsert.size()>0)
                        {
                            for(OpportunityLineItem opptylineitem:toInsert)
                            {
                                bothFileCount=bothFileCount+1;
                                if(givenFileType=='CATLOGICFILE' || bothFileCount>0)
                                {
                                    if(CatlogicwithProductCodeMap.get(opptylineitem.Description)!=null && CatlogicwithProductCodeMap.get(opptylineitem.Description)!='')
                                    {
                                        opptylineitem.SKUNumber__c = CatlogicwithProductCodeMap.get(opptylineitem.Description);
                                    }
                                }
                                if(givenFileType=='PRODUCTCODEFILE' || bothFileCount>0)
                                {
                                    if(ProductCodewithCatlogicMap.get(opptylineitem.SKUNumber__c)!=null && ProductCodewithCatlogicMap.get(opptylineitem.SKUNumber__c)!='')
                                    {
                                        opptylineitem.Description = ProductCodewithCatlogicMap.get(opptylineitem.SKUNumber__c);
                                    }
                                }
                            }
                        }
                        if(bothFileCount>0)
                        {
                            if(toInsert.size()>0)
                            {                            
                            map<String,OpportunityLineItem> toinsertmap=new map<String,OpportunityLineItem>();                              
                            for(OpportunityLineItem opptylineitem:toInsert)
                            {
                                if(!toinsertmap.containsKey(opptylineitem.Description+opptylineitem.SKUNumber__c))
                                {
                                    toinsertmap.put(opptylineitem.Description+opptylineitem.SKUNumber__c,opptylineitem);
                                }
                                
                            }
                            system.debug('toinsertmap'+toinsertmap.size());
                            system.debug('toinsertmap'+toinsertmap);
                            toInsert.clear();
                            toInsert.addAll(toinsertmap.values());
                            
                            }
                            if(toUpdate.size()>0)
                            {
                            map<String,OpportunityLineItem> toUpdateMap=new map<String,OpportunityLineItem>();                              
                            for(OpportunityLineItem opptylineitem:toUpdate)
                            {
                                if(!toUpdateMap.containsKey(opptylineitem.Description+opptylineitem.SKUNumber__c))
                                {
                                    toUpdateMap.put(opptylineitem.Description+opptylineitem.SKUNumber__c,opptylineitem);
                                }
                                
                            }
                            system.debug('toUpdateMap'+toUpdateMap.size());
                            system.debug('toUpdateMap'+toUpdateMap);
                            toUpdate.clear();
                            toUpdate.addAll(toUpdateMap.values());
                            }
                        }
                        
                        
                        
                        
                        System.debug('toInsert@@$ after'+toInsert);
                        list<OpportunityLineItem> toinsertlist = new list<OpportunityLineItem>();                           
                        toinsertlist.addAll(toInsert);                          
                        insert toinsertlist;                            
                        check1=true;
                        checksave1=false;
                        checkResults=false;
                        check1scdule=false;
                        list<OpportunityLineItem> toUpdatelist = new list<OpportunityLineItem>();
                        System.debug('toUpdate@@$'+toUpdate);
                        toUpdatelist.addAll(toUpdate);
                        
                        try {
                            update toUpdatelist;
                        } catch(DmlException e) {
                            System.debug('The following exception has occurred: ' + e.getMessage());
                            String msg=e.getMessage();
                            if(msg.contains('Duplicate id in list'))
                            {
                                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'dupli recs');
                                ApexPages.addMessage(errormsg); 
                            }
                        }
                        system.debug('toUpdatelist[0].id'+toUpdatelist);
                        
                        
                        Opptyline =[SELECT ID,product2.name,product2ID,SKUNumber__c,product2.Levels_1__c,product2.Levels_2__c,product2.Hierarchy_Level_4_Description__c,product2.Hierarchy_Level_3_Description__c,product2.Hierarchy_Level_1_Description__c,product2.Hierarchy_Level_2_Description__c,TotalPrice,Unit_of_measure__c,SKU_Number__r.GE_LGT_EM_SAP_MaterialNumber__c,SKU_Number__r.GE_LGT_EM_MaterialDescription__c, Product_Hierarchy_Code__c,OPPORTUNITYID,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,GE_LGT_Level1__c,GE_LGT_Level2__c,GE_LGT_Level3__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,Confirmed__c,Cut_off_date__c,Product2.Material_No__c,(SELECT Id,Description,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type FROM OpportunityLineItemSchedules ORDER BY ScheduleDate ASC) FROM OPPORTUNITYLINEITEM where OPPORTUNITYID =:OppId ];
                        lstwrapper.clear();
                        for(opportunitylineitem oli : Opptyline){
                            lstwrapper.add(new oliwrapper(false,oli));
                        }
                        
                        if(ApexPages.hasMessages()==false)
                        {
                            if ((filelines.size() - 2) == oltoupload.size())
                            {
                                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.INFO,  +' Records Inserted successfully');
                                ApexPages.addMessage(errormsg);  
                                check1=true; 
                                checksave1=false;
                                flagrecordupsert=false;
                                checkResults=false;
                            }
                        }                   
                    }  
                    else
                    {
                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.WARNING,'Your products are unable to be uploaded. Please ensure all red (mandatory) fields are populated, and the product is spelled correctly');
                        ApexPages.addMessage(errormsg);
                        check1=true;
                        checksave1=false;
                        flagrecordupsert=false;
                        checkResults=false;
                    }
                } 
                return null; 
            }
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'The file format (extension) you try to upload is not matching. Please upload csv format and try again.');
                ApexPages.addMessage(errormsg); 
                check1=true; 
                checksave1=false;
                checkResults=false;
            }
        }
        else
        {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Please Select a File');
            ApexPages.addMessage(errormsg);
            check1=true;
            checksave1=false; 
            checkResults=false;
        } 
        return null;   
    }
    //oliwrapper method
    public class oliwrapper{
        public boolean b{get; set;}
        public opportunitylineitem oli{get; set;}
        public decimal totalPrice {get; set;}
        public String sku{get; set;}
        public oliwrapper(boolean b, opportunitylineitem oli){
            this.b = b;
            this.oli = oli;
            totalPrice=oli.TotalPrice;
            Decimal quanwithoutdecimal=oli.quantity;
            oli.quantity=quanwithoutdecimal.intValue();
            if(oli.Product2.Material_No__c!=NULL && oli.Product2.Material_No__c.isNumeric())
            {
                Integer skuInt= Integer.valueOf(oli.Product2.Material_No__c);
                oli.SKUNumber__c = String.valueOf(skuInt);
            }
            else if(oli.Product2.Material_No__c!=NULL)
                oli.SKUNumber__c = oli.Product2.Material_No__c;
            else if(oli.SKUNumber__c!=NULL)
                oli.SKUNumber__c = oli.SKUNumber__c;
        }
    }
    
    public String keyword{get;set;}
    private integer totalRecs = 2000;     
    private integer index = 0;
    private integer blockSize = 10;    
    
    
    // Previous method on Product Results Selection  for Search by SKU/CAT Logic/Description    
    public void previous()
    {
        for(GE_LGT_EM_MaterialMaster__c mm:matMasListSearchresult){
            if(mm.Product_Hierarchy_Code_2__r != null && mm.Is_Active_Internal__c){
                matMasListSearchresultNext.put(mm.ID, mm);
                
            }
        }
        index = index - blockSize;
        
        if(keyword!=null)
            searchProductBySAPMatNumber();
    }
    // Next method on Product Results Selection  for Search by SKU/CAT Logic/Description
    public void next()
    {  
        for(GE_LGT_EM_MaterialMaster__c mm:matMasListSearchresult){
            if(mm.Product_Hierarchy_Code_2__r != null && mm.Is_Active_Internal__c){
                matMasListSearchresultNext.put(mm.ID, mm);  
            }   
        }
        index = index + blockSize;
        if(keyword != null)
            searchProductBySAPMatNumber();
    } 
    
    public boolean getprev()
    {
        if(index == 0)
            return true;
        else
            return false;
    }  
    
    public boolean getnxt()
    {
        if((index + blockSize) > totalRecs)
            return true;
        else
            return false;
    }  
    
    //system.debug('filters'+filters);
    //String[] filters = new String[]{'AUT%','CFL%','COM%','HAL%','HID%','INC%','MKT%','NPL%','OTL%','OTN%'};
        //Below method is for Search by SKU/CAT Logic/Description   
        public void searchProductBySAPMatNumber()
    {
        Map<string,UnwantedLevels__c> levelsinfo = UnwantedLevels__c.getAll(); 
        falgtoshowproductsearchlist=False;
        falgtoshowMMobjectsearchlist=true;
        flagrecordupsert = False;
        flagrecordupsert1=false;
        check1scdule=false;
        d = False;
        addb=False;
        
        if(keyword!=null )
        {
            check =true;
            List<String> prdid=new List<String>();
            matMasListSearchresult.clear();
            
            if(keyword != null || keyword!='' || keyword!=' ')
            {
                String keyword1=keyword.substringBefore('::');
                system.debug('filters'+filters);
               // system.debug('filters1'+filters1);
                matMasList=[SELECT ID,GE_LGT_EM_ProductHierarchy__c,Is_Active_Internal__c,Level_1__c,Level_2__c,Level_3__c,Level_4__c,GE_LGT_EM_SAP_MaterialNumber__c,GE_LGT_EM_MaterialDescription__c,Product_Hierarchy_Code_2__r.id,Material_Type__c,Product_Hierarchy_Code_2__r.isActive,Product_Hierarchy_Code_2__r.name FROM GE_LGT_EM_MaterialMaster__c WHERE 
                            (GE_LGT_EM_SAP_MaterialNumber__c=:keyword1 OR GE_LGT_EM_SAP_MaterialNumber__c=:keyword OR GE_LGT_EM_MaterialDescription__c Like : '%'+ keyword +'%' OR GE_LGT_EM_SAP_MaterialNumber__c Like : '%'+ keyword +'%') AND (Level_4__c!=NULL AND Level_4__c!='0') AND (Product_Hierarchy_Code_2__C!=NULL) AND  (NOT Level_1__c LIKE :filters) AND (NOT GE_LGT_EM_ProductHierarchy__c LIKE :filters) limit:blockSize OFFSET:index];
            } 
            if(matMasList!=NULL && matMasList.size()>0)
            {
                for(GE_LGT_EM_MaterialMaster__c m:matMasList)
                {
                    if(matMasListSearchresultNext.containsKey(m.id))
                    {
                        m.Is_Active_Internal__c=true;
                    }
                    if(m.Level_4__c!=NULL && m.Level_4__c!='0'){
                        matMasListSearchresult.add(m);
                    }
                }
                
            }
            else
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.WARNING,'SKU/CAT Logic/Description/Product is not found');
                ApexPages.addMessage(errormsg);
                checkResults=true;
                check1=false;
            }
            
        }
        
    }
    //Below method is for Search by filtering 
    public void searchMMByLevel4()
    {
        
        falgtoshowproductsearchlist=true;
        falgtoshowMMobjectsearchlist=false;
        flagrecordupsert=false;
        flagrecordupsert1=false;
        check1scdule=false;
        addb=False;
        if(selectedValueAtL4!=Null)
        {
            check =true;
            system.debug('opp.PRICEBOOK2ID :::'+opp.PRICEBOOK2ID);
            system.debug('opp.CurrencyIsoCode :::'+opp.CurrencyIsoCode);
            system.debug('selectedValueAtL4 :::'+selectedValueAtL4);
            
            prdList =[select Name,Hierarchy_Level_4_Description__c,Hierarchy_Level_3_Description__c,Hierarchy_Level_2_Description__c,Hierarchy_Level_1_Description__c, (SELECT ID,Name,CurrencyIsoCode,Product2Id FROM pricebookentries  WHERE PRICEBOOK2ID=:opp.PRICEBOOK2ID AND CurrencyIsoCode=:opp.CurrencyIsoCode),Description,Level_1__c,Level_2__c,Level_3__c,Levels_1__c,Levels_2__c,Levels_3__c,GE_LGT_Product_Group__c,GE_LGT_Product_Line__c,GE_LGT_Product_Family__c,IsActive from Product2 where (Name Like : '%'+ selectedValueAtL4 +'%') and isactive=true limit 100];
            System.debug('count of products' +prdList.size());
            system.debug('prdList :::'+prdList );
            for(Product2 prd :prdList) {    
                prd.isActive = false;
            }
        }
        productSearchList = new list<product2>();
        inte = 0;
        if(prdlist.size() > 25){
            prdlistSet.addAll(prdlist);
            for(integer i = inte;  i < inte + 25; i++){
                productSearchList.add(prdlist[i]);
            }
            integ = prdlist.size()- 25; 
        }
        else{
            productSearchList = prdlist;
            prdlistSet.addAll(prdlist);
            System.debug('prdlistSet' +prdlistSet);
            integ = -1;
        }
        flag=false;
    }
    
    
    public Transient List<MMobjectLevels__c> phLevels;    
    public List<SelectOption> level1{get;set;}
    public List<SelectOption> level2{get;set;}
    public List<SelectOption> level3{get;set;}
    public List<SelectOption> level4{get;set;}
    public String selectedValueAtL1{get;set;}
    public String selectedValueAtL2{get;set;}
    public String selectedValueAtL3{get;set;}
    public String selectedValueAtL4{get;set;}
    Set<String> level1Set=new Set<String>();
    Set<String> level2Set=new Set<String>();
    Set<String> level3Set=new Set<String>();
    Set<String> level4Set=new Set<String>();
    //Below method is for setPHLevels on Search by filtering 
    public void setPHLevels()
    {
        phLevels=[SELECT id,Level_1__c, Level_2__c, Level_3__c, Level_4__c, Product_Hierarchy__c FROM MMobjectLevels__c where Level_1__c not in('SOL-SOLAR-1','IBE-INTELLIGENT BUILDINGS ENERGY MANAGEMENT-1')]; //Andras filtered 
        level1=new List<SelectOption>();
        level2=new List<SelectOption>();
        level3=new List<SelectOption>();
        level4=new List<SelectOption>();
        level1.add(new SelectOption('Product Line','Product Line'));
        level2.add(new SelectOption('Product Group','Product Group'));
        level3.add(new SelectOption('Product Family','Product Family'));
        level4.add(new SelectOption('Product Name','Product Name'));
        for(MMobjectLevels__c l:phLevels)
        {
            if(l.Product_Hierarchy__c.length()>=13){
                
                if(l.Level_1__c!=NULL)
                    level1Set.add(l.Level_1__c.removeEndIgnoreCase('-1'));   
            }
            
        }
        for(String l:level1Set)
        {
            if(l.contains('-')){
                level1.add(new SelectOption(l,l.substringafter('-')));
            }
            else
            {
                level1.add(new SelectOption(l,l));
            }
        }
    }
    //Below method is for setPHLevels on Search by filtering  for Level 2
    public void setLevel2Value()
    {
        phLevels=[SELECT id,Level_1__c, Level_2__c, Level_3__c, Level_4__c, Product_Hierarchy__c FROM MMobjectLevels__c where Level_1__c not in('SOL-SOLAR-1','IBE-INTELLIGENT BUILDINGS ENERGY MANAGEMENT-1')];
        level2=new List<SelectOption>();
        level3=new List<SelectOption>();
        level4=new List<SelectOption>();
        level2Set=new Set<String>();
        level2.add(new SelectOption('Product Group','Product Group'));
        level3.add(new SelectOption('Product Family','Product Family'));
        level4.add(new SelectOption('Product Name','Product Name'));
        
        for(MMobjectLevels__c l:phLevels)
        {
            if(l.Level_1__c != null){
                if(l.Level_1__c.removeEndIgnoreCase('-1')==selectedValueAtL1){
                    if(l.Level_2__c.contains('-') && !level2Set.contains(l.Level_2__c.removeEndIgnoreCase('-2'))){
                        level2.add(new SelectOption(l.Level_2__c.removeEndIgnoreCase('-2'),l.Level_2__c.removeEndIgnoreCase('-2').substringafter('-')));
                        level2Set.add(l.Level_2__c.removeEndIgnoreCase('-2'));
                    }
                    else if(!level2Set.contains(l.Level_2__c.removeEndIgnoreCase('-2'))){
                        level2.add(new SelectOption(l.Level_2__c.removeEndIgnoreCase('-2'),l.Level_2__c.removeEndIgnoreCase('-2')));   
                        level2Set.add(l.Level_2__c.removeEndIgnoreCase('-2'));
                    }
                }
            }
            
            
        }
    }
    //Below method is for setPHLevels on Search by filtering  for Level 3
    public void setLevel3Value()
    {
        phLevels=[SELECT id,Level_1__c, Level_2__c, Level_3__c, Level_4__c, Product_Hierarchy__c FROM MMobjectLevels__c where Level_1__c not in('SOL-SOLAR-1','IBE-INTELLIGENT BUILDINGS ENERGY MANAGEMENT-1')];
        level3=new List<SelectOption>();
        level4=new List<SelectOption>();
        level3Set=new Set<String>();
        level3.add(new SelectOption('Product Family','Product Family'));
        level4.add(new SelectOption('Product Name','Product Name'));
        
        for(MMobjectLevels__c l:phLevels)
        {
            if(l.Level_2__c != null){
                if(l.Level_2__c.removeEndIgnoreCase('-2')==selectedValueAtL2){
                    if(l.Level_3__c.contains('-') && !level3Set.contains(l.Level_3__c.removeEndIgnoreCase('-3'))){
                        level3.add(new SelectOption(l.Level_3__c.removeEndIgnoreCase('-3'),l.Level_3__c.removeEndIgnoreCase('-3').substringafter('-')));
                        level3Set.add(l.Level_3__c.removeEndIgnoreCase('-3'));
                    }
                    else if(!level3Set.contains(l.Level_3__c.removeEndIgnoreCase('-3'))){
                        level3.add(new SelectOption(l.Level_3__c.removeEndIgnoreCase('-3'),l.Level_3__c.removeEndIgnoreCase('-3'))); 
                        level3Set.add(l.Level_3__c.removeEndIgnoreCase('-3'));                 
                    }                
                    
                }
            }
            
            
        }
        
    }
    //Below method is for setPHLevels on Search by filtering  for Level 4
    public void setLevel4Value()
    {
        phLevels=[SELECT id,Level_1__c, Level_2__c, Level_3__c, Level_4__c, Product_Hierarchy__c FROM MMobjectLevels__c where Level_1__c not in('SOL-SOLAR-1','IBE-INTELLIGENT BUILDINGS ENERGY MANAGEMENT-1')];
        level4=new List<SelectOption>();
        level4Set=new Set<String>();
        level4.add(new SelectOption('Product Name','Product Name'));
        
        for(MMobjectLevels__c l:phLevels)
        {
            if(l.Level_2__c != null){
                if(l.Level_3__c.removeEndIgnoreCase('-3')==selectedValueAtL3){
                    if(l.Level_4__c.contains('-') && !level4Set.contains(l.Level_4__c.removeEndIgnoreCase('-4'))){
                        level4.add(new SelectOption(l.Level_4__c.removeEndIgnoreCase('-4'),l.Level_4__c.removeEndIgnoreCase('-4').substringafter('-')));
                        level4Set.add(l.Level_4__c.removeEndIgnoreCase('-4'));
                    }
                    else if(!level4Set.contains(l.Level_4__c.removeEndIgnoreCase('-4'))){
                        level4.add(new SelectOption(l.Level_3__c.removeEndIgnoreCase('-4'),l.Level_4__c.removeEndIgnoreCase('-4'))); 
                        level4Set.add(l.Level_4__c.removeEndIgnoreCase('-4'));
                    }                
                    
                }
            }
            
            
        }
    }
    public Set < Integer >  HeadCheck() {
        InvalidRows = new Set < Integer > ();
        String[] headervalues = new String[] {};
            if(filelines[1].contains(',')){
                headervalues = filelines[1].split(',');
            }
        else if(filelines[1].contains(';')){
            headervalues = filelines[1].split(';');
        }
        
        if(headervalues.size()==4){
            
            if (headervalues[0] != 'CAT Logic/Description'){
                InvalidRows.add(2);
                if (!rowNum_ColumnNums_Map.containsKey(2)) {
                    rowNum_ColumnNums_Map.put(2, new Set < String > ());
                    rowNum_ColumnNums_Map.get(2).add('<BR/> Column A is not a valid column heading. Column A should be "CAT Logic/Description"');
                } else {
                    rowNum_ColumnNums_Map.get(2).add('<BR/> Column A is not a valid column heading. Column A should be "CAT Logic/Description"');
                }
            }
            
            
            if (headervalues[1] != 'Product Code/SKU/Material #'){
                InvalidRows.add(2);
                if (!rowNum_ColumnNums_Map.containsKey(2)) {
                    rowNum_ColumnNums_Map.put(2, new Set < String > ());
                    rowNum_ColumnNums_Map.get(2).add('<BR/> Column B is not a valid column heading. Column B should be "Product Code/SKU/Material #"');
                } else {
                    rowNum_ColumnNums_Map.get(2).add('<BR/> Column B is not a valid column heading. Column B should be "Product Code/SKU/Material #"');
                }
            }
            
            if (headervalues[2] != 'Quantity'){
                InvalidRows.add(2);
                if (!rowNum_ColumnNums_Map.containsKey(2)) {
                    rowNum_ColumnNums_Map.put(2, new Set < String > ());
                    rowNum_ColumnNums_Map.get(2).add('<BR/> Column C is not a valid column heading. Column C should be "Quantity"');
                } else {
                    rowNum_ColumnNums_Map.get(2).add('<BR/> Column C is not a valid column heading. Column C should be "Quantity"');
                }
            }
            if (headervalues[3].trim() != 'Sales Price per Unit'){
                InvalidRows.add(2);
                if (!rowNum_ColumnNums_Map.containsKey(1)) {
                    rowNum_ColumnNums_Map.put(2, new Set < String > ());
                    rowNum_ColumnNums_Map.get(2).add('<BR/> Column D is not a valid column heading. Column D should be "Sales Price per Unit"');
                } else {
                    rowNum_ColumnNums_Map.get(2).add('<BR/> Column D is not a valid column heading. Column D should be "Sales Price per Unit"');
                }
            }
            string s='Expected Ship Date';
            
            validateCSV() ;
        }
        else{
            InvalidRows.add(1);
            rowNum_ColumnNums_Map.put(1, new Set < String > ());
            rowNum_ColumnNums_Map.get(1).add('<BR/> Number of headers given are '+ headervalues.size() +',Expecting 4 headers');
        }
        return InvalidRows;
    }
    public void validateCSV(){
        List<String> matNumList=new List<String>();
        List<String> matNumList1=new List<String>();
        Map<String,NA_Profiles__c> profiles1 = NA_Profiles__c.getAll(); 
        for (Integer i = 2; i <filelines.size(); i++) {
            String[] inputvalues = new String[] {};
                if(filelines[i].contains(',')){
                    inputvalues = filelines[i].split(',');
                }
            else if(filelines[i].contains(';')){
                inputvalues = filelines[i].split(';');
            }
            matNumList.add(inputvalues[0].trim());
            matNumList1.add(inputvalues[1].trim());
            
        }
        map<string,list<GE_LGT_EM_MaterialMaster__c>> sku_mmlist=new map<string,list<GE_LGT_EM_MaterialMaster__c>>();
        map<string,list<GE_LGT_EM_MaterialMaster__c>> sku_desc=new map<string,list<GE_LGT_EM_MaterialMaster__c>>();
        matMasListReadFile1=[SELECT ID,GE_LGT_EM_ProductHierarchy__c,GE_LGT_EM_SAP_MaterialNumber__c,Material_Type__c,GE_LGT_EM_MaterialDescription__c,Product_Hierarchy_Code_2__r.Name,Level_1__c,Level_2__c,Level_3__c,Level_4__c,Level_5__c FROM GE_LGT_EM_MaterialMaster__c
                             WHERE GE_LGT_EM_SAP_MaterialNumber__c IN:matNumList1 
                             AND (Level_4__c!=NULL AND Level_4__c!='0') AND (Product_Hierarchy_Code_2__C!=NULL) 
                            AND  (NOT Level_1__c LIKE :filters) AND (NOT GE_LGT_EM_ProductHierarchy__c LIKE :filters) ];
        matMasListReadFile2=[SELECT ID,GE_LGT_EM_ProductHierarchy__c,GE_LGT_EM_SAP_MaterialNumber__c,Material_Type__c,GE_LGT_EM_MaterialDescription__c,Product_Hierarchy_Code_2__r.Name,Level_1__c,Level_2__c,Level_3__c,Level_4__c,Level_5__c FROM GE_LGT_EM_MaterialMaster__c
                             WHERE GE_LGT_EM_MaterialDescription__c IN:matNumList 
                             AND (Level_4__c!=NULL AND Level_4__c!='0') AND (Product_Hierarchy_Code_2__C!=NULL) 
                             AND  (NOT Level_1__c LIKE :filters) AND (NOT GE_LGT_EM_ProductHierarchy__c LIKE :filters) ];
                             
        
        for(GE_LGT_EM_MaterialMaster__c m:matMasListReadFile1){
            if (!sku_mmlist.containsKey(m.GE_LGT_EM_SAP_MaterialNumber__c)) {
                sku_mmlist.put(m.GE_LGT_EM_SAP_MaterialNumber__c, new list < GE_LGT_EM_MaterialMaster__c > ());
                sku_mmlist.get(m.GE_LGT_EM_SAP_MaterialNumber__c).add(m);
            } else {
                sku_mmlist.get(m.GE_LGT_EM_SAP_MaterialNumber__c).add(m);
            }   
        }
        set<string> uniquedesc=new set<string>();
        set<string> uniqueMn=new set<string>();
        set<string> dupelicatedesc=new set<string>(); 
        set<string> dupelicateMn=new set<string>(); 
        for(GE_LGT_EM_MaterialMaster__c m:matMasListReadFile2){
            if(!uniquedesc.contains(m.GE_LGT_EM_MaterialDescription__c)){
                uniquedesc.add(m.GE_LGT_EM_MaterialDescription__c);
            }
            else{
                dupelicatedesc.add(m.GE_LGT_EM_MaterialDescription__c);
            }
            
            
        }
        
        for(string m:matNumList1){
            if(!uniqueMn.contains(m)){
                uniqueMn.add(m);
            }
            else{
                dupelicateMn.add(m);
            }
            
        }
        for(GE_LGT_EM_MaterialMaster__c m:matMasListReadFile2){
            if (!sku_desc.containsKey(m.GE_LGT_EM_MaterialDescription__c)) {
                sku_desc.put(m.GE_LGT_EM_MaterialDescription__c, new list < GE_LGT_EM_MaterialMaster__c > ());
                sku_desc.get(m.GE_LGT_EM_MaterialDescription__c).add(m);
            } else {
                sku_desc.get(m.GE_LGT_EM_MaterialDescription__c).add(m);
            }   
        }
        for (Integer i = 2; i <filelines.size(); i++) {
            String[] inputvalues = new String[] {};
                if(filelines[i].contains(',')){
                    inputvalues = filelines[i].split(',');
                }
            else if(filelines[i].contains(';')){
                inputvalues = filelines[i].split(';');
            }
            if ((inputvalues[0] == '' || inputValues[0] == null) && (inputvalues[1] == '' || inputvalues[1] == null)) {
                InvalidRows.add(i + 1);
                if (!rowNum_ColumnNums_Map.containsKey(i + 1)) {
                    rowNum_ColumnNums_Map.put(i + 1, new Set < String > ());
                    rowNum_ColumnNums_Map.get(i + 1).add('<BR/> CAT Logic/Description (or) Product Code/SKU/Material # mandatory . Please include and resubmit');
                } else {
                    rowNum_ColumnNums_Map.get(i + 1).add('<BR/> CAT Logic/Description (or) Product Code/SKU/Material # mandatory . Please include and resubmit');
                }
            }
            if (inputValues[0] != '' || String.isNotBlank(inputValues[0])){
                if (!sku_desc.containsKey(inputValues[0])) {
                    InvalidRows.add(i + 1);
                    if (!rowNum_ColumnNums_Map.containsKey(i + 1)) {
                        rowNum_ColumnNums_Map.put(i + 1, new Set < String > ());
                        rowNum_ColumnNums_Map.get(i + 1).add('<BR/> CAT Logic/Description contains invalid data. Please update and resubmit');
                    } else {
                        rowNum_ColumnNums_Map.get(i + 1).add('<BR/> CAT Logic/Description contains invalid data. Please update and resubmit');
                    }
                }
                if(dupelicatedesc.contains(inputValues[0]) && (!sku_mmlist.containsKey(inputValues[1]))){
                    InvalidRows.add(i + 1);
                    if (!rowNum_ColumnNums_Map.containsKey(i + 1)) {
                        rowNum_ColumnNums_Map.put(i + 1, new Set < String > ());
                        rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Cat Logic/Description contains duplicates. Please add product Code/SKU/Material # to upload template or manually add product.');
                    } else {
                        rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Cat Logic/Description contains duplicates. Please add product Code/SKU/Material # to upload template or manually add product.');
                    }
                    
                }
            }
            if (inputValues[1].trim() != '' ||  String.isNotBlank(inputValues[1]))  {
                if (!sku_mmlist.containsKey(inputValues[1])) { 
                    InvalidRows.add(i + 1);
                    if (!rowNum_ColumnNums_Map.containsKey(i + 1)) {
                        rowNum_ColumnNums_Map.put(i + 1, new Set < String > ());
                        rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Product Code/SKU/Material contains invalid data. Please update and resubmit');
                    } else {
                        rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Product Code/SKU/Material contains invalid data. Please update and resubmit');
                    }
                    
                }
                if(dupelicateMn.contains(inputValues[1])  ){
                    InvalidRows.add(i + 1);
                    if (!rowNum_ColumnNums_Map.containsKey(i + 1)) {
                        rowNum_ColumnNums_Map.put(i + 1, new Set < String > ());
                        rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Product Code/SKU/Material contains duplicates. Please keep one row');
                    } else {
                        rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Product Code/SKU/Material contains  duplicates. Please keep one row');
                    }
                }   
            }
            if (inputValues[2] == '' || String.isBlank(inputValues[2])) {
                InvalidRows.add(i + 1);
                if (!rowNum_ColumnNums_Map.containsKey(i + 1)) {
                    rowNum_ColumnNums_Map.put(i + 1, new Set < String > ());
                    rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Quantity mandatory. Please include and resubmit');
                } else {
                    rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Quantity mandatory. Please include and resubmit');
                }
                
            }
            else if(inputValues[2] != ''){
                try {
                    integer dt = integer.valueof(inputvalues[2].trim());
                } catch (Exception e) {
                    if (!rowNum_ColumnNums_Map.containsKey(i + 1)) {
                        rowNum_ColumnNums_Map.put(i + 1, new Set < String > ());
                        rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Quantity contains invalid data. Please update and resubmit');
                    } else {
                        rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Quantity contains invalid data. Please update and resubmit');
                    }   
                }
            }
            if (inputValues[3] == '' || String.isBlank(inputValues[3]) ){
                InvalidRows.add(i + 1);
                if (!rowNum_ColumnNums_Map.containsKey(i + 1)) {
                    rowNum_ColumnNums_Map.put(i + 1, new Set < String > ());
                    rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Sales Price per Unit mandatory. Please include and resubmit');
                } else {
                    rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Sales Price per Unit mandatory. Please include and resubmit');
                }
                
            }
            else if(inputValues[3] != ''){
                try {
                    Decimal dec = Decimal.valueOf(inputvalues[3].trim());
                } catch (Exception e) {
                    if (!rowNum_ColumnNums_Map.containsKey(i + 1)) {
                        rowNum_ColumnNums_Map.put(i + 1, new Set < String > ());
                        rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Sales Price per Unit contains invalid data. Please update and resubmit');
                    } else {
                        rowNum_ColumnNums_Map.get(i + 1).add('<BR/> Sales Price per Unit contains invalid data. Please update and resubmit');
                    }   
                }
            }
            
            
        }
        
        
    }
    
}