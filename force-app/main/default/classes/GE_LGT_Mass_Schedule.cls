public  class GE_LGT_Mass_Schedule {
    Public list<OPPORTUNITYLINEITEM> ollist {get;set;}
    Public List<OpportunityLineItemSchedule> ItemsAlreadyPresent {get;set;}
    public list<wrapperc> lstwrapper{get; set;}
    public Boolean d {get; set;}
    public Boolean b {get; set;}
    public boolean allBool{get; set;}    
    Public integer  productCount {get; set;} 
    public List<OpportunityLineItem> listoppsd{get;set;}
    public Boolean disableInput {get; set;} 
    public boolean editpbrender{get; set;}
     //public string bvar{get; set;}    
        Public GE_LGT_Mass_Schedule() {
        //bvar =  ApexPages.currentPage().getParameters().get('bvar');
        editpbrender = false;
        b=False;
        
        //if(bvar == 'true'){
        //bvar = 'ttrue';
        //b = true;
        //}
        
        
        disableInput=True;
        ollist = new List<OPPORTUNITYLINEITEM>();            
        //ItemsAlreadyPresent2 = new List<OpportunityLineItemSchedule>();
                if(ApexPages.currentPage().getParameters().get('id') != null) {  
                    ollist = [SELECT ID,Product2.Name,TotalPrice,OPPORTUNITYID,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,Confirmed__c,Cut_off_date__c  FROM OPPORTUNITYLINEITEM where OPPORTUNITYID=:ApexPages.currentPage().getParameters().get('id')];
                        /*Set<Id> lineItemIds =  new set<Id>();
                        for(Opportunitylineitem o:ollist ) {
                        lineItemIds.add(o.id);
                        }
                        ItemsAlreadyPresent2 =[SELECT Id,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type FROM OpportunityLineItemSchedule where OpportunityLineItemId in: lineItemIds];
                         */
                    listoppsd =[SELECT ID,Product2.Name,TotalPrice,OPPORTUNITYID,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,Confirmed__c,Cut_off_date__c, (SELECT Id,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type FROM OpportunityLineItemSchedules ORDER BY ScheduleDate ASC) FROM OPPORTUNITYLINEITEM where OPPORTUNITYID=:ApexPages.currentPage().getParameters().get('id')];
                    productCount = ollist.size();
                    lstwrapper = new list<wrapperc>();
                    //n=1;// remove comment to populate default 'Number of Installment' on VF
                    for(opportunitylineitem oli : ollist){
                        for(opportunitylineitem l :listoppsd ){
                            if(oli.id==l.id){
                                lstwrapper.add(new wrapperc(oli, new opportunitylineitemschedule(),l.OpportunityLineItemSchedules.size()));
                            }                 
                        }
                    
                    }
                }
        }
        
    Public class wrapperc{
        public opportunitylineitem oli{get; set;}
        public opportunitylineitemschedule olisch{get; set;}
        public integer  n {get; set;}
        Public string s2 {get;set;}  
        public Boolean c {get; set;} 
        public wrapperc(opportunitylineitem oli, opportunitylineitemschedule olisch, integer n){
            this.oli = oli;
            this.olisch = olisch;
            //if(n==0){
            
            //this.n = 1;
            //}
            //else {
            this.n = n;
            //}
            
            
            //this.s2 = s2;            
        }
    }
    public PageReference saveall() {
        editpbrender = false;
        list<OpportunityLineItemSchedule> lstolischedule = new list<OpportunityLineItemSchedule>();
        list<OpportunityLineItem> lstoli = new list<OpportunityLineItem>();
        for(OpportunityLineItem oli: listoppsd){
        //update oli.OpportunityLineItemSchedules;
        lstolischedule.addall(oli.OpportunityLineItemSchedules);
        }
         update lstolischedule;
         
         
         list<OPPORTUNITYLINEITEM> lstlineit =[SELECT ID,Product2.Name,TotalPrice,OPPORTUNITYID,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,Confirmed__c,Cut_off_date__c, (SELECT Id,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type FROM OpportunityLineItemSchedules ORDER BY ScheduleDate ASC) FROM OPPORTUNITYLINEITEM where OPPORTUNITYID=:ApexPages.currentPage().getParameters().get('id')];
        list<OPPORTUNITYLINEITEM> lstlineit1 = new list<OPPORTUNITYLINEITEM>();
        for(OpportunityLineItem olii: lstlineit){
        date dt;
        for(OpportunityLineItemSchedule oliisch: olii.OpportunityLineItemSchedules){
        
        if(dt == null){
        dt = oliisch.Scheduledate;
        }
        else{
        if(oliisch.Scheduledate < dt){
        dt = oliisch.Scheduledate;
        }
        }        
        }
        olii.ServiceDate = dt;
        lstlineit1.add(olii);
        }           
        update lstlineit1; 

        PageReference pf = new PageReference('/apex/GE_LGT_Mass_Schedule?id=' + ApexPages.currentPage().getParameters().get('id'));
         pf.setRedirect(true);
         return pf;
        //return null;
    }


    public PageReference Editall() {
        editpbrender = true;
        return null;
    }
    Public PageReference scheduleall(){
        integer dt= 30;                                
        List<OpportunityLineItemSchedule> opptylishd = new list<OpportunityLineItemSchedule>();
        set<id> wcoliid = new set<id>();
        for(wrapperc wc: lstwrapper) {
        wcoliid.add(wc.oli.id);
        }
         List<OpportunityLineItemSchedule> lstItemsAlreadyPresent = new List<OpportunityLineItemSchedule>();
         List<OpportunityLineItemSchedule> lstdeletingItemsAlreadyPresent = new List<OpportunityLineItemSchedule>();
         List<OpportunityLineItem> lstOLI_SchDate = new List<OpportunityLineItem>();
         List<OpportunityLineItem> lstupdatingOLI_SchDate = new List<OpportunityLineItem>();
         lstItemsAlreadyPresent =[SELECT Id,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type FROM OpportunityLineItemSchedule where OpportunityLineItemId IN :wcoliid];
          lstOLI_SchDate = [Select ServiceDate from OpportunityLineItem where id IN :wcoliid];
                  
        for(wrapperc wc: lstwrapper) {
            system.debug('Wrapper class Oppty line items :: '+wc);
            system.debug('First Oppty Line Item '+wc.oli.id);
            if(wc.oli.id!=null && wc.oli.Quantity!=null){
               // ItemsAlreadyPresent =[SELECT Id,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type FROM OpportunityLineItemSchedule where OpportunityLineItemId=:wc.oli.id];
                ItemsAlreadyPresent = new List<OpportunityLineItemSchedule>();
                for(OpportunityLineItemSchedule olische: lstItemsAlreadyPresent){
                if(olische.OpportunityLineItemId == wc.oli.id){
                ItemsAlreadyPresent.add(olische);
                }
                }
                
                if(ItemsAlreadyPresent.size()>0 ){       
                    //delete ItemsAlreadyPresent;
                    lstdeletingItemsAlreadyPresent.addall(ItemsAlreadyPresent);
                    system.debug('Schedule items deleted for '+ wc.oli.id);
                }  
                
                     
                //List<OpportunityLineItem> OLI_SchDate = [Select ServiceDate from OpportunityLineItem where id = :wc.oli.id];
               List<OpportunityLineItem> OLI_SchDate = new List<OpportunityLineItem>();
                for(OpportunityLineItem olin: lstOLI_SchDate){
                if(olin.id== wc.oli.id){
                OLI_SchDate.add(olin);
                }
                }
                
                
                
               
                if(wc.oli.quantity!=null && wc.s2=='quarterly' && wc.n!=0 ){
                String qtystr = calculateQty(wc.oli.quantity,wc.n);
                String revstr = calculaterev(wc.oli.TotalPrice,wc.n);
                List<String> parts = qtystr.split('&'); 
                List<String> parts1 = revstr.split('&'); 
                //Decimal revfinal = wc.olisch.Revenue / wc.n; 
                
                for(Integer i=1; i<=wc.n; i++){
                    system.debug('Tandra Testing');
                    system.debug(wc.n);         
                    OpportunityLineItemSchedule opptylishditem = new OpportunityLineItemSchedule();
                    opptylishditem.OpportunityLineItemId = wc.oli.id;
                    opptylishditem.Type = 'Both';
                    //opptylishditem.Quantity = wc.oli.Quantity;
                    opptylishditem.Quantity = decimal.valueof(parts[i]);
                    opptylishditem.Revenue= decimal.valueof(parts1[i]);
                    opptylishditem.ScheduleDate= wc.oli.Servicedate.addMonths(3*(i-1));
                    //wc.olisch.CurrencyIsoCode='USD';
                    b=true;             
                    opptylishd.add(opptylishditem);
                    //added by Neel:Update OLI.ServiceDate(Expected Ship Date)
                    if(i==1){
                    system.debug('Neel Inside i==1');
                    
                    OLI_SchDate[0].ServiceDate =wc.oli.Servicedate.addMonths(3*(i-1));
                 //   update OLI_SchDate ;
                   
                    }
                   
                   
                }               
                system.debug('Schedule items inserted for '+ wc.oli.id);
                }
                else if(wc.oli.quantity!=null && wc.s2=='monthly' && wc.n!=0 ){
                
                String qtystr = calculateQty(wc.oli.quantity,wc.n);
                String revstr = calculaterev(wc.oli.TotalPrice,wc.n);
                List<String> parts = qtystr.split('&'); 
                List<String> parts1 = revstr.split('&'); 
                
                for(Integer i=1; i<=wc.n; i++){
                    system.debug('Tandra Testing');
                    system.debug(wc.n);         
                    OpportunityLineItemSchedule opptylishditem = new OpportunityLineItemSchedule();
                    opptylishditem.OpportunityLineItemId = wc.oli.id;
                    opptylishditem.Type = 'Both';
                    //opptylishditem.Quantity = wc.oli.Quantity;
                    opptylishditem.Quantity = decimal.valueof(parts[i]);
                    opptylishditem.Revenue= decimal.valueof(parts1[i]);
                    opptylishditem.ScheduleDate= wc.oli.Servicedate.addMonths(1*(i-1));
                    //wc.olisch.CurrencyIsoCode='USD';
                    b=true;             
                    opptylishd.add(opptylishditem);
                    
                    if(i==1){
                    OLI_SchDate[0].ServiceDate =wc.oli.Servicedate.addMonths(1*(i-1));
                 //   List<OpportunityLineItem> OLI_SchDate = [Select ServiceDate from OpportunityLineItem where id = :wc.oli.id];
                 //   OLI_SchDate[0].ServiceDate =wc.oli.Servicedate.addMonths(1*(i-1));
                 //   update OLI_SchDate ;
                    }
                    
                }   
                         
                system.debug('Schedule items inserted for '+ wc.oli.id);
                }
                /*else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Installment in  '));
                }*/
                //update OLI_SchDate; 
                lstupdatingOLI_SchDate.addall(OLI_SchDate);
               
            }
         
        }
        if(lstupdatingOLI_SchDate.size()>0)
        update lstupdatingOLI_SchDate;
        if(lstdeletingItemsAlreadyPresent.size()>0)
        delete lstdeletingItemsAlreadyPresent;
        try{
        insert opptylishd;
        
      //  if(lstdeletingItemsAlreadyPresent.size()==0){
      //  updateMaxMinDatesonOpptyFromLineItem();
      //  }else{
        updateMaxMinDatesonOppty();
     //   }
        
        
        }
        catch (exception e)
        {
        }
        if(ApexPages.currentPage().getParameters().get('id') != null)
        listoppsd =[SELECT ID,Product2.Name,OPPORTUNITYID,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,Confirmed__c,Cut_off_date__c, (SELECT Id,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type FROM OpportunityLineItemSchedules ORDER BY ScheduleDate ASC ) FROM OPPORTUNITYLINEITEM where OPPORTUNITYID=:ApexPages.currentPage().getParameters().get('id') ORDER BY ID DESC];
        
          PageReference pf = new PageReference('/apex/GE_LGT_Mass_Schedule?&id=' + ApexPages.currentPage().getParameters().get('id'));
          pf.setRedirect(true);
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.INFO,'Records inserted successfully');
          ApexPages.addMessage(myMsg);
          return pf;

        return null;
    }
    
    public string calculateQty(Decimal qty, Integer Inst){    
        Integer Installment=Inst;
        Integer Quantity=Integer.valueof(qty);
        String Finalstr;
        //system.debug(math.mod(Quantity, Installment));
        Integer mod_var = math.mod(Quantity, Installment);
        //System.debug('mod_var' +mod_var);
        Integer fixed_int = Quantity-mod_var;
        //System.debug('fixed_int '+fixed_int);
        Integer Initial_Instlmnt = fixed_int/Installment;
        //System.debug('Initial_Instlmnt' +Initial_Instlmnt);
        for (integer i=1 ;i<=Installment;i++){
            //System.debug('Installment Number : ' +i);
            if(i==Installment){
                //system.debug('Last Installment Quantity ');
                //System.debug(Quantity-((i-1)*Initial_Instlmnt));
               // Finalstr = Finalstr + '&' +string.valueof(Initial_Instlmnt);
               Finalstr = Finalstr + '&' +string.valueof(Quantity-((i-1)*Initial_Instlmnt));
                
            }else{
            Finalstr = Finalstr + '&' +string.valueof(Initial_Instlmnt);
            //System.debug('Quantity for this Installment '+Initial_Instlmnt);
            }    
        }
        return Finalstr;
    }
    public string calculaterev(Decimal rev, Integer Inst){    
        Integer Installment=Inst;
        Integer Revenue=Integer.valueof(rev);
        String Finalstre;
        //system.debug(math.mod(Revenue, Installment));
        Integer mod_var = math.mod(Revenue, Installment);
        //System.debug('mod_var' +mod_var);
        Integer fixed_int = Revenue-mod_var;
        //System.debug('fixed_int '+fixed_int);
        Integer Initial_Instlmnt = fixed_int/Installment;
        //System.debug('Initial_Instlmnt' +Initial_Instlmnt);
        for (integer i=1 ;i<=Installment;i++){
            //System.debug('Installment Number : ' +i);
            if(i==Installment){
                //system.debug('Last Installment Revenue ');
                //System.debug(Revenue-((i-1)*Initial_Instlmnt));
               // Finalstre = Finalstre + '&' +string.valueof(Initial_Instlmnt);
               Finalstre = Finalstre + '&' +string.valueof(Revenue-((i-1)*Initial_Instlmnt));
                
            }else{
            Finalstre = Finalstre + '&' +string.valueof(Initial_Instlmnt);
            //System.debug('Revenue for this Installment '+Initial_Instlmnt);
            }    
        }
        return Finalstre;
    }
    
   Public PageReference  deloli() {
   List<opportunitylineitemSchedule> lsdeletinglistForDel = new List<opportunitylineitemSchedule>();
    List<opportunitylineitemSchedule> lslistForDel = new List<opportunitylineitemSchedule>(); 
    List<wrapperc> listTempWrapper = new List<wrapperc>();
    List<OpportunityLineItemSchedule> opptylishd1 = new list<OpportunityLineItemSchedule>();
    List<OpportunityLineItem> lstupdatingOLI_SchDate = new List<OpportunityLineItem>();
    set<id> setwcoliid = new set<id>();
    for(wrapperc wc: lstwrapper) {
        setwcoliid.add(wc.oli.id);
        }
    List<OpportunityLineItem> lstOLI_SchDate = [Select ServiceDate from OpportunityLineItem where id IN  :setwcoliid];
    lslistForDel =[SELECT Id,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type FROM OpportunityLineItemSchedule where OpportunityLineItemId IN :setwcoliid]; 
    for(wrapperc w : lstWrapper){   
    // List<OpportunityLineItem> OLI_SchDate = [Select ServiceDate from OpportunityLineItem where id = :w.oli.id];  

        List<OpportunityLineItem> OLI_SchDate = new List<OpportunityLineItem>();
                for(OpportunityLineItem olin: lstOLI_SchDate){
                if(olin.id== w.oli.id){
                OLI_SchDate.add(olin);
                }
                }

       if(w.c){                                            
           // listForDel =[SELECT Id,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type FROM OpportunityLineItemSchedule where OpportunityLineItemId=:w.oli.id];               
            
             List<opportunitylineitemSchedule> listForDel = new List<opportunitylineitemSchedule>();

            for(OpportunityLineItemSchedule olische: lslistForDel){
                if(olische.OpportunityLineItemId == w.oli.id){
                listForDel.add(olische);
                }
                }

            if(listForDel.size()>0 ){       
                //delete listForDel;
                lsdeletinglistForDel.addall(listForDel);          
            }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select atleast one Product '));
            //return null;    
            }
            OpportunityLineItemSchedule opptylishditem = new OpportunityLineItemSchedule();
            opptylishditem.OpportunityLineItemId = w.oli.id;
            opptylishditem.Type = 'Both';   
            opptylishditem.Quantity = w.oli.Quantity;
            opptylishditem.Revenue= w.oli.TotalPrice;
            opptylishditem.ScheduleDate= w.oli.Servicedate;     
            //b=true;             
            opptylishd1.add(opptylishditem);
        }
        OLI_SchDate[0].Servicedate=w.oli.Servicedate;
        //update  OLI_SchDate;
        lstupdatingOLI_SchDate.addall(OLI_SchDate);
    }
    
    if(lstupdatingOLI_SchDate.size()>0)
    update lstupdatingOLI_SchDate;
    insert opptylishd1;
    updateMaxMinDatesonOppty();
    if(lsdeletinglistForDel.size()>0)
   delete lsdeletinglistForDel;
    d = True;
    //updateMaxMinDatesonOpptyFromLineItem();
    
    //listoppsd =[SELECT ID,Product2.Name,OPPORTUNITYID,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,Confirmed__c,Cut_off_date__c, (SELECT Id,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type FROM OpportunityLineItemSchedules ORDER BY ScheduleDate ASC ) FROM OPPORTUNITYLINEITEM where OPPORTUNITYID=:ApexPages.currentPage().getParameters().get('id') ORDER BY ID DESC];
    PageReference pf = new PageReference('/apex/GE_LGT_Mass_Schedule?id=' + ApexPages.currentPage().getParameters().get('id'));
    pf.setRedirect(true);
    return pf;
    //return null;    
}   
    Public pageReference returntooppty()
    {  
        b = False;
        //Opptyline.clear();
        PageReference pf = new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
        pf.setRedirect(true);
        return pf;
    }
    public void selectAll() {
        if(allBool) {
            for(wrapperc w : lstWrapper) {
                w.c= true;
            }
        } else {
            for(wrapperc w : lstWrapper) {
                w.c= false;
            }
        }
    }
     public pagereference delolisch() {
        List<opportunitylineitemSchedule> listForDel1 = new List<opportunitylineitemSchedule>();
        List<opportunitylineitem> listoliii = new List<opportunitylineitem>();
        List<wrapperc> listTempWrapper1 = new List<wrapperc>();
        //addb=False;
        for(wrapperc w : lstWrapper) {
        
            if(w.c) {
               for(Opportunitylineitem olltsch:listoppsd){
                 listoliii.add(olltsch); 
                 if(olltsch.id == w.oli.id){
                 listForDel1.addall(olltsch.Opportunitylineitemschedules);
                 }
               }
                
                
            } //else {
              // listTempWrapper1.add(w);
            //}
            
        }
        
        if(listForDel1.size() > 0) {
            try{
            delete listForDel1;
            set<id> ollid = new set<id>();
            for(opportunitylineitem olll: listoliii){
            ollid.add(olll.id);
            }
            List<opportunitylineitem> listoliiii = [select quantity, totalprice from opportunitylineitem where id IN : ollid];
            for(opportunitylineitem olll: listoliiii){
            for(opportunitylineitem ollll:listoliii){
            if(olll.id == ollll.id){
            olll.quantity = ollll.quantity;
            olll.totalprice = ollll.totalprice;
            
            }
            }
            }
            update listoliiii;
            updateMaxMinDatesonOppty();
            PageReference pf = new PageReference('/apex/GE_LGT_Mass_Schedule?id=' + ApexPages.currentPage().getParameters().get('id'));
            pf.setRedirect(true);
            return pf;
            //b=false;
            //d=true;
            }
            catch(exception e){
                    }
                    
            //lstWrapper = listTempWrapper1;
            
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select atleast one Product to delete Schedules'));
        }
        return null;
          

    }
    Public void updateMaxMinDatesonOppty(){
    //Opportunity ChildOppty = [select Parent_Opportunity__c from Opportunity where id =:  ApexPages.currentPage().getParameters().get('id') limit 1];
    Opportunity Oppty = [select First_Ship_Date__c, Last_Ship_Date__c from Opportunity where id =: ApexPages.currentPage().getParameters().get('id') limit 1];
   // Opportunity ParentOppty = [select First_Ship_Date__c, Last_Ship_Date__c   from Opportunity where id =: ChildOppty.Parent_Opportunity__c  limit 1];
    
    
    list<aggregateresult> lstOpptySchedule = [select Max(ScheduleDate)ma, Min(ScheduleDate)mi, COUNT(ID) count_sch from OpportunityLineItemSchedule where opportunitylineitem.Opportunityid =: Oppty.id]; 
    
    system.debug('Neel Schedule Count ::: '+lstOpptySchedule[0].get('count_sch'));
    
    Oppty.First_Ship_Date__c =  Date.ValueOf(lstOpptySchedule[0].get('mi'));
    Oppty.Last_Ship_Date__c =  Date.ValueOf(lstOpptySchedule[0].get('ma')); 
    if(lstOpptySchedule[0].get('count_sch')==0){
    Oppty.hasSchedule__c = false;
    }else{
    Oppty.hasSchedule__c = true;
    }
    Update Oppty;
    //ChildOppty.phaseHasSchedule__c = true;
   // Update ChildOppty;
    }
   Public void updateMaxMinDatesonOpptyFromLineItem(){
    Opportunity Oppty = [select First_Ship_Date__c, Last_Ship_Date__c from Opportunity where id =: ApexPages.currentPage().getParameters().get('id') limit 1];
    list<aggregateresult> lstOpptyServiceDate = [select Max(ServiceDate)ma, Min(ServiceDate)mi from OpportunityLineItem where Opportunityid =: ApexPages.currentPage().getParameters().get('id')]; 
    Oppty.First_Ship_Date__c =  Date.ValueOf(lstOpptyServiceDate[0].get('mi'));
    Oppty.Last_Ship_Date__c =  Date.ValueOf(lstOpptyServiceDate[0].get('ma')); 
    Update Oppty;
    
    }
   
}