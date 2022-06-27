public class SalsifyProductCalloutBatch implements Database.Batchable<sObject>,Database.Stateful  {
    // instance member to retain state across transactions
    public Integer batchesFailed = 0;
    public String jsonInput; 
    public String tempCat;
     public string gtmfam;
    public List<Object> aSKU = new List<Object>();
    public List<Object> aFamily = new List<Object>();
    //public Map<String, Object> prod1;
    
    //public List<ccrz__E_ProductCategory__c> toUpdatecatex= new  List<ccrz__E_ProductCategory__c>();
    
    //public Set<String> notexistprod =  new Set<String>();
    
    //public List<ccrz__E_Product__c> existprod = [Select ccrz__SKU__c From ccrz__E_Product__c];
    public Map<String,id> allspec = new Map<String,id>();    
    
    public Map<String,id> allcat = new Map<String,id>(); 
    public List<ccrz__E_Spec__c> semispecs= new  List<ccrz__E_Spec__c>();
    public List<ccrz__E_Category__c> semicats= new  List<ccrz__E_Category__c>();
    public List<ccrz__E_Category__c> childCats= new  List<ccrz__E_Category__c>();
    public List<ccrz__E_Category__c> semicatSKU= new  List<ccrz__E_Category__c>();
    public List<ccrz__E_Category__c> childCatSKU= new  List<ccrz__E_Category__c>();
    public List<String> familyHierJSON = new List<String>();
    public List<String> SKUJson = new List<String>();
    public set<String> SKUJson1 = new set<String>();
    
    // public List<Family_Record__mdt> existFamily = new  List<Family_Record__mdt>();
    public List<Salsify_Family__mdt> existFamily = new  List<Salsify_Family__mdt>();
    public Map<String,object> existFamilymap = new Map<String,object>();
    public String fileName;
    public Set<String> prodHierimages = new Set<String>();
    public Set<String> prodHierfamimages = new Set<String>();
    //
    public Set<String> prodHiersalimages = new Set<String>();
    
    //
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        try{
            Attachment at = [select id, body, name from Attachment where Name like '%SFCC_Output%' order by createddate desc LIMIT 1] ;
            jsonInput = at.body.toString();
            jsonInput='{"TEST":'+jsonInput+'}';
            fileName=at.Name;
            at=Null;
            System.debug('Checkpoint');
            
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
            
            jsonInput = Null;
            List<Object> wholejson =  (List<Object>)results.get('TEST');
            results = Null;
            
            Map<String, Object> prod1;
            Map<String, Object> a11;
            List<Object> a;
            System.debug('Checkpoint');
            
            for(object whole1:wholejson ){
                
                prod1 = (Map<String, Object>)whole1;   
                a =  (List<Object>)prod1.get('SKU or Family');
                // system.debug(wholejson.size());
                // system.debug(a.size());
                
                a11 = (Map<String, Object>)a[0]; 
                //  system.debug(a11.get('external_id'));
                if(a11.get('external_id') == 'SKU'){
                    aSKU.add(whole1);
                    // system.debug(aSKU);  
                }
                else if(a11.get('external_id') == 'Family'){
                    aFamily.add(whole1);
                    //system.debug(aFamily);   
                }
                
            }
            System.debug('Checkpoint');
            
            wholejson=Null;
            a11=Null;
            a=Null;
            system.debug(aFamily); 
            system.debug(aFamily.size()); 
            List<ccrz__E_Spec__c> allavailspec= [select id,ccrz__DisplayName__c,ccrz__Sequence__c from ccrz__E_Spec__c];
            for(ccrz__E_Spec__c t1 :allavailspec){
                allspec.put(t1.ccrz__DisplayName__c,t1.Id);
            }
            allavailspec = Null;
            
            List<ccrz__E_Category__c> allavailscat= [select id,ccrz__CategoryID__c from ccrz__E_Category__c];
            for(ccrz__E_Category__c t1 :allavailscat){
                allcat.put(t1.ccrz__CategoryID__c,t1.Id);
            }
            allavailscat= Null;
            
            
            System.debug('Checkpoint');
            
            
            childCats=[Select id From ccrz__E_Category__c where ccrz__CategoryID__c IN ('Family Applications', 'INDOOR','CONTROLS','OUTDOOR','BRAND','FAMILY','PH1 PRODUCT LINE','PH2 APPLICATION','PH3 FAMILY')];
            childCatSKU=[Select id From ccrz__E_Category__c where ccrz__CategoryID__c IN ('PROGRAMS','PH4 CONFIGURATION','PH5 INTELLIGENCE','CONTROLS PLATFORM')];
            //semispecs=[Select id From ccrz__E_Spec__c where ccrz__DisplayName__c IN ('Technology Enabled', 'Material','Environmental Conditions','Associated Parts','Regulatory','Certifications','Product Shape')];
            semicats=[Select id From ccrz__E_Category__c where ccrz__ParentCategory__c IN:childCats OR ccrz__CategoryID__c IN ('Family Applications', 'INDOOR','CONTROLS','OUTDOOR','BRAND','FAMILY','PH1 PRODUCT LINE','PH2 APPLICATION','PH3 FAMILY')];
            semicatSKU=[Select id From ccrz__E_Category__c where ccrz__ParentCategory__c IN:childCatSKU OR ccrz__CategoryID__c IN ('PROGRAMS','PH4 CONFIGURATION','PH5 INTELLIGENCE','CONTROLS PLATFORM')];
            System.debug('Checkpoint');
            
            String checkProdHier1;
            LIST<String> prodHier1 = new LIST<String>();
            for(Object prod: aFamily){
                prod1 = (Map<String, Object>)prod;
                checkProdHier1 = (((String.valueOf(prod1.get('GTM Family ID'))).removeStart('(')).removeEnd(')'));
                if(!String.isBlank(checkProdHier1)){
                   // prodHier1=checkProdHier1.split('\\;');
                   // for(String eleHier:prodHier1){
                        familyHierJSON.add(checkProdHier1);
                   // }
                    
                }
                
            }
            System.debug('Checkpoint');
            
            for(Object prod: aSKU){
                prod1 = (Map<String, Object>)prod;
                checkProdHier1 = (((String.valueOf(prod1.get('SKU'))).removeStart('(')).removeEnd(')'));
                SKUJson.add(checkProdHier1);
            }
            existFamily = [Select id,MasterLabel,Data__c From Salsify_Family__mdt];
            
            For(Salsify_Family__mdt p :existFamily){
                existFamilymap.put(p.MasterLabel,p.Data__c);
            }
            
            Map<String, Object> metaFamily1;
            System.debug('Checkpoint');
            
            List<Object> imagedata;    
            /* for (string p :existFamilymap.Keyset()) {
// prod1 = (Map<String, Object>)existFamilymap.get(p);
metaFamily1= (Map<String, Object>)JSON.deserializeUntyped(String.valueOf(existFamilymap.get(p)));
imagedata = (List<Object>)JSON.deserializeUntyped('['+(((String.valueOf(metaFamily1.get('Product Images'))).removeStart('(')).removeEnd(')'))+']');

if(imagedata.size()!=0){
checkProdHier1 = (((String.valueOf(metaFamily1.get('SAP Product Hierarchy'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkProdHier1)){
prodHier1=checkProdHier1.split('\\;');
for(String eleHier:prodHier1){
prodHierimages.add(eleHier);
}

}
}

}*/
            
            System.debug(prodHierimages.size());   
            System.debug('Checkpoint');
            
            
            /*  for (Object prod: aFamily) {

prod1 = (Map<String, Object>)prod;
imagedata = (List<Object>)JSON.deserializeUntyped('['+(((String.valueOf(prod1.get('Product Images'))).removeStart('(')).removeEnd(')'))+']');

if(imagedata.size()!=0){
checkProdHier1 = (((String.valueOf(prod1.get('SAP Product Hierarchy'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkProdHier1)){
prodHier1=checkProdHier1.split('\\;');
for(String eleHier:prodHier1){

prodHierfamimages.add(eleHier);
}

}
}    
}*/
            System.debug('Checkpoint');
            
            string SKUNoInJson;
            for(Object prod: aSKU){
                prod1 = (Map<String, Object>)prod;
                SKUNoInJson = (((String.valueOf(prod1.get('SKU'))).removeStart('(')).removeEnd(')'));
                SKUJson1.add(SKUNoInJson);
            }
            system.debug(SKUJson1);
            
            System.debug('Checkpoint');
            
            
            /*for (Object prod: aSKU) {

prod1 = (Map<String, Object>)prod;
imagedata = (List<Object>)JSON.deserializeUntyped('['+(((String.valueOf(prod1.get('Product Images'))).removeStart('(')).removeEnd(')'))+']');

if(imagedata.size()!=0){
checkProdHier1 = (((String.valueOf(prod1.get('SAP Product Hierarchy'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkProdHier1)){
prodHier1=checkProdHier1.split('\\;');
for(String eleHier:prodHier1){

prodHierfamimages.add(eleHier);
}

}
}    
}*/
            System.debug(prodHierfamimages.size());
            system.debug('***getHeapSize()***'+Limits.getHeapSize());    
            System.debug('Checkpoint');
            
        }
        
        catch (Exception e) {
            messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            //ravi.singh@gecurrent.com',
           // message.toAddresses = new String[] {'sagar.suryawanshi@gecurrent.com'};
            message.toAddresses = new String[] {'salsify.support@gecurrent.com'};
            message.optOutPolicy = 'FILTER';
            message.subject = 'Salsify Inetgration Batch Creation Status:: Batch Creation Failed!!!';
            message.plainTextBody = 'The following exception has occurred in batch creation:' + e.getMessage();
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] result1 = Messaging.sendEmail(messages);
            
        }
        String prodStatus='Released';
        String Query = 'Select ccrz__SKU__c From ccrz__E_Product__c where ccrz__ProductStatus__c=:prodStatus';
        System.debug('Checkpoint');
        
        //String Query = 'Select ccrz__SKU__c From ccrz__E_Product__c';
        return Database.getQueryLocator(Query);
        //return Database.getQueryLocator('Select ccrz__SKU__c From ccrz__E_Product__c');
        
        
    }
    public void execute(Database.BatchableContext bc, List<ccrz__E_Product__c> scope){
        // process each batch of records
        
        try{
            System.debug(aSKU.size());
            System.debug(aFamily.size());
            system.debug('***getHeapSize()***'+Limits.getHeapSize());    
            
            //System.debug(aSKU);
            //System.debug(aFamily);
            transient boolean isexistspec = false;
            transient boolean isexistcat = false;
            transient boolean isexistmed = false;
            transient ccrz__E_ProductSpec__c updspec = new ccrz__E_ProductSpec__c();
            transient ccrz__E_ProductCategory__c updcat= new ccrz__E_ProductCategory__c();
            transient ccrz__E_ProductCategory__c tocat= new  ccrz__E_ProductCategory__c();
            transient ccrz__E_ProductMedia__c updmed= new ccrz__E_ProductMedia__c();  
            transient ccrz__E_Product__c p1 = new ccrz__E_Product__c();
            transient List<ccrz__E_ProductCategory__c> insertCatsec = new List<ccrz__E_ProductCategory__c>();
            
            
            transient Set<String> scopeprod1 = new Set<String>();
            transient Set<String> scopeprod2 = new Set<String>();
            transient Map<String,ccrz__E_Product__c> existprodmap = new Map<String,ccrz__E_Product__c>();
            transient List<String> semivalues = new List<String>();
            transient List<String> semivalues2 = new List<String>();
            transient List<String> prodHier = new List<String>();
            transient String checkNull;
            transient String checkNull2;
            transient String checkProdHier;
            
            transient List<ccrz__E_Product__c> allProductCat= new List<ccrz__E_Product__c>();
            transient Map<id,ccrz__E_ProductCategory__c> cMap; 
            transient Map<String,ccrz__E_ProductCategory__c> dMap = new Map<String,ccrz__E_ProductCategory__c>();  
            transient Map<String,ccrz__E_ProductSpec__c> bMap = new Map<String,ccrz__E_ProductSpec__c>();
            transient Map<id,ccrz__E_ProductSpec__c> aMap;
            transient Map<String,ccrz__E_ProductMedia__c> fMap = new Map<String,ccrz__E_ProductMedia__c>(); 
            transient Map<id,ccrz__E_ProductMedia__c> eMap ;
            transient Map<String,id> existrelaprod = new Map<String,id>();
            
            
            
            For(ccrz__E_Product__c p :scope){
                scopeprod2.add(p.ccrz__SKU__c);
            }
            
            transient String str;
            aMap = new Map<id,ccrz__E_ProductSpec__c>([Select Id,ccrz__Product__r.ccrz__SKU__c,ccrz__E_ProductSpec__c.ccrz__Spec__r.ccrz__DisplayName__c,ccrz__SpecValue__c from ccrz__E_ProductSpec__c where ccrz__Product__r.ccrz__SKU__c IN:scopeprod2]);       
            
            for (id key: aMap.keyset()){ 
                str= amap.get(key).ccrz__Product__r.ccrz__SKU__c + amap.get(key).ccrz__Spec__r.ccrz__DisplayName__c; 
                bmap.put(str,amap.get(key));    
            }
            System.debug(aMap.size());
            aMap = Null;
            str=Null;
            
            cMap = new Map<id,ccrz__E_ProductCategory__c>([Select Id,ccrz__Product__r.ccrz__SKU__c,ccrz__Category__r.ccrz__CategoryID__c from ccrz__E_ProductCategory__c  where ccrz__Product__r.ccrz__SKU__c IN:scopeprod2 and ccrz__Category__r.ccrz__CategoryID__c='PRODUCTS']);
            for (id key: cMap.keyset()){            
                str= cMap.get(key).ccrz__Product__r.ccrz__SKU__c + cMap.get(key).ccrz__Category__r.ccrz__CategoryID__c;
                dmap.put(str,cMap.get(key));            
            }
            System.debug(cMap.size());
            cMap = Null;  
            str=Null;
            
            eMap = new Map<id,ccrz__E_ProductMedia__c>([Select Id,ccrz__Product__r.ccrz__SKU__c,ccrz__MediaType__c from ccrz__E_ProductMedia__c where ccrz__Product__r.ccrz__SKU__c IN:scopeprod2]);
            for (id key: eMap.keyset()){ 
                str= eMap.get(key).ccrz__Product__r.ccrz__SKU__c + eMap.get(key).ccrz__MediaType__c;
                fMap.put(str,eMap.get(key));   
            } 
            System.debug(eMap.size());
            str=Null;
            eMap=Null;
            
            transient List<ccrz__E_ProductSpec__c> toInsert= new  List<ccrz__E_ProductSpec__c>();
            transient List<ccrz__E_ProductCategory__c> toUpdatecat= new  List<ccrz__E_ProductCategory__c>();
            transient List<ccrz__E_ProductCategory__c> toInsertcat= new  List<ccrz__E_ProductCategory__c>();
            transient List<ccrz__E_Product__c> toUpdateProd = new  List<ccrz__E_Product__c>();
            transient List<ccrz__E_ProductSpec__c> toUpdate= new  List<ccrz__E_ProductSpec__c>();
            transient List<ccrz__E_ProductMedia__c> toUpdateMed = new  List<ccrz__E_ProductMedia__c>();
            transient List<ccrz__E_ProductMedia__c> toInsertMed = new  List<ccrz__E_ProductMedia__c>();
            transient List<ccrz__E_RelatedProduct__c> toInsertRelProd = new List<ccrz__E_RelatedProduct__c>();
            transient List<ccrz__E_ProductTab__c> toInsertProdTab = new List<ccrz__E_ProductTab__c>();
            
            //Adding product category to each product
            
            allProductCat=[Select id,ccrz__SKU__c From ccrz__E_Product__c where ccrz__SKU__c IN:scopeprod2] ;
            for(ccrz__E_Product__c pro : allProductCat){
                
                if(!dMap.keyset().contains(pro.ccrz__SKU__c+'PRODUCTS')) {
                    ccrz__E_ProductCategory__c newcat3 = new ccrz__E_ProductCategory__c(ccrz__Product__c=pro.Id);
                    newcat3.ccrz__Category__c = allcat.get('PRODUCTS');
                    toUpdatecat.add(newcat3);
                }
                
            }
            Database.insert(toUpdatecat);
            allProductCat=Null;
            
            For(ccrz__E_Product__c p :scope){
                existprodmap.put(p.ccrz__SKU__c,p);
            }
            toUpdateProd.clear();
            toUpdate.clear();
            toUpdatecat.clear();
            toInsert.clear();    
            toInsertMed.clear();
            toUpdateMed.clear(); 
            toInsertProdTab.clear();
            toInsertRelProd.clear();
            insertCatsec.clear();
            //String xyz = DateTime.now().format('MM/dd/yyyy hh:mm a', 'US/Eastern');
            transient DateTime yesterday = DateTime.now();
            yesterday = yesterday.addMinutes(-1410);
            //List<AsyncApexJob>  cutoff = [SELECT ApexClassId,CompletedDate,Id,JobItemsProcessed,JobType,MethodName,NumberOfErrors,Status,TotalJobItems,ExtendedStatus FROM AsyncApexJob]; 
            System.debug(yesterday);
            //     transient List<ccrz__E_Product__c> newProd = [Select id,ccrz__SKU__c,LastModifiedDate,ProductHierarchy__c,GTM_Product_Family__c From ccrz__E_Product__c where ccrz__SKU__c IN:scopeprod2 and LastModifiedDate >= :yesterday];
            
           transient List<ccrz__E_Product__c> newProd = [Select id,ccrz__SKU__c,LastModifiedDate,ProductHierarchy__c,GTM_Product_Family__c From ccrz__E_Product__c where ccrz__SKU__c IN:scopeprod2 and LastModifiedDate >= :yesterday and LastModifiedBy.Name != 'Salsify Integration' and LastModifiedBy.Name != 'Product Enrichment Integration'];
            System.debug(newProd.size());
            System.debug(newProd);
            //List<ccrz__E_Product__c> newProd = [Select ccrz__SKU__c,LastModifiedDate,ProductHierarchy__c,GTM_Product_Family__c From ccrz__E_Product__c where ccrz__SKU__c IN:scopeprod2 and createddate >= :yesterday];
            for (ccrz__E_Product__c pr: newProd){ 
                existrelaprod.put(pr.ccrz__SKU__c, pr.id );    
            }
            
            if(SKUJson.size() !=0){
                transient List<ccrz__E_Product__c> prodofSKU = [Select id From ccrz__E_Product__c where  ccrz__SKU__c IN:scopeprod2 AND ccrz__SKU__c IN:SKUJson ];
                Database.delete([Select id From ccrz__E_ProductCategory__c where ccrz__Product__c IN:prodofSKU and ccrz__Category__c IN:semicatSKU]);
                
            } 
            
            if(SKUJson1.size() !=0){
                transient List<ccrz__E_Product__c> skuprodfamilyImages = [Select id From ccrz__E_Product__c where ccrz__SKU__c IN:scopeprod2 and  ccrz__SKU__c IN:SKUJson1];
              //  Database.delete([Select id From ccrz__E_ProductMedia__c where ccrz__Product__c IN:skuprodfamilyImages and ccrz__MediaType__c IN ('Product Search Image','Product Image Thumbnail','Product Image','Spec Sheet') and (NOT ccrz__URI__c LIKE 'resource%')]);
                Database.delete([Select id From ccrz__E_ProductMedia__c where ccrz__Product__c IN:skuprodfamilyImages and ccrz__MediaType__c IN ('Product Search Image','Product Image Thumbnail','Product Image','Spec Sheet')]);
                system.debug('Checkpoint');
            } 
            
            
            
            For(ccrz__E_Product__c p :newProd){
                scopeprod1.add(p.ccrz__SKU__c);
            }
            scopeprod2.removeAll(scopeprod1);
            System.debug(scopeprod1);
            System.debug(scopeprod1.size());
            system.debug('familyHierJSON'+familyHierJSON);
            system.debug('scopeprod2'+scopeprod2);
            System.debug(scopeprod2.size());
            system.debug(scopeprod2.contains('177041'));
            transient List<ccrz__E_Product__c> prodaftupd = [Select ccrz__SKU__c, ProductHierarchy__c,GTM_Product_Family__c From ccrz__E_Product__c where  ccrz__SKU__c IN:scopeprod2 and GTM_Product_Family__c IN :familyHierJSON];
            System.debug(prodaftupd);
            System.debug('scopeprod1'+scopeprod1.size());
            if(scopeprod1.size() !=0){
                transient List<ccrz__E_Product__c> prodoffamily = [Select id From ccrz__E_Product__c where  ccrz__SKU__c IN:scopeprod1];
                /// transient List<ccrz__E_Product__c> prodoffamilyImages = [Select id From ccrz__E_Product__c where  ccrz__SKU__c IN:scopeprod1 and ProductHierarchy__c IN:prodHierimages];
                //List<ccrz__E_ProductSpec__c> toDeleteSpecs = [Select id From ccrz__E_ProductSpec__c where ccrz__Product__c IN:prodoffamily and ccrz__Spec__c IN:semispecs];
                //Database.delete([Select id From ccrz__E_ProductSpec__c where ccrz__Product__c IN:prodoffamily and ccrz__Spec__c IN:semispecs]);
                Database.delete([Select id From ccrz__E_ProductCategory__c where ccrz__Product__c IN:prodoffamily and ccrz__Category__c IN:semicats]);
                // Database.delete([Select id From ccrz__E_ProductMedia__c where ccrz__Product__c IN:prodoffamily and ccrz__MediaType__c IN ('Family Features & Benefits Bullets','Alternate Images','Alternate Thumbnails','Spec Sheet')]);
                //Database.delete([Select id From ccrz__E_ProductMedia__c where ccrz__Product__c IN:prodoffamily and ccrz__MediaType__c IN ('Alternate Images','Alternate Thumbnails','Spec Sheet')]);
                
                //Database.delete([Select id From ccrz__E_ProductMedia__c where ccrz__Product__c IN:prodoffamilyImages and ccrz__MediaType__c IN ('Product Search Image','Product Image Thumbnail','Product Image')]);
                //Database.delete([Select id From ccrz__E_RelatedProduct__c where ccrz__Product__c IN:prodoffamily]);
                Database.delete([Select id From ccrz__E_ProductTab__c where ccrz__Product__c IN:prodoffamily]);
                
            }   
            transient Map<String, Object> metaFamily;
            transient List<Object> imagedata;
            transient List<Object> docData;
            if(newProd.size() != 0){
                for (string p :existFamilymap.Keyset()) {
                    // prod1 = (Map<String, Object>)existFamilymap.get(p);
                    metaFamily= (Map<String, Object>)JSON.deserializeUntyped(String.valueOf(existFamilymap.get(p)));
                    checkProdHier='';

                    
                    System.debug(metaFamily.get('GTM Family ID'));
                    /*
if(metaFamily.keyset().contains('Product Images')){
imagedata = (List<Object>)JSON.deserializeUntyped('['+(((String.valueOf(metaFamily.get('Product Images'))).removeStart('(')).removeEnd(')'))+']');
}
System.debug('Checkpoint');

if(metaFamily.keyset().contains('Product Documents')){
docData = (List<Object>)JSON.deserializeUntyped('['+(((String.valueOf(metaFamily.get('Product Documents'))).removeStart('(')).removeEnd(')'))+']');
//system.debug(prod1.get('imagedata'));
}
*/
                    System.debug('Checkpoint');
                    
                    // imagedata = (List<Object>)JSON.deserializeUntyped('['+(((String.valueOf(metaFamily.get('Product Images'))).removeStart('(')).removeEnd(')'))+']');
                    // docData = (List<Object>)JSON.deserializeUntyped('['+(((String.valueOf(metaFamily.get('Product Documents'))).removeStart('(')).removeEnd(')'))+']');
                    if(metaFamily.get('GTM Family ID') != Null){
                    	checkProdHier = (((String.valueOf(metaFamily.get('GTM Family ID'))).removeStart('(')).removeEnd(')'));
                    }
                   checkProdHier=(checkProdHier.replaceAll(' ', ''));
                    if(!String.isBlank(checkProdHier)){
                      //  prodHier=checkProdHier.split('\\;');
                      //  for(String eleHier:prodHier){
                            // for (String key: prod1.keyset()){
                            //  if (prod1.keyset().contains('salsify:data_inheritance_hierarchy_level_id')){
                            // if (key=='salsify:data_inheritance_hierarchy_level_id'){
                            //    if(prod1.get('salsify:data_inheritance_hierarchy_level_id')=='Family'){ 
                            for(ccrz__E_Product__c p3 : newProd){
                                //if((String.valueOf(p3.MaterialDescription__c)).startsWith(((String.valueOf(metaFamily.get('Family'))).removeStart('(')).removeEnd(')'))){
                                System.debug('Checkpoint');
                                gtmfam = p3.GTM_Product_Family__c;
                                If(gtmfam != Null){
 								  gtmfam=(gtmfam.replaceAll(' ', ''));  
                                }     
                                if(!String.isBlank(gtmfam)){
                                    System.debug('Checkpoint');
                                    System.debug('Checkpoint'+gtmfam);
                                    System.debug('Checkpoint'+checkProdHier);
                                if(gtmfam==checkProdHier){
                                    System.debug('Checkpoint');
                                    //system.debug(((String.valueOf(metaFamily.get('Family'))).removeStart('(')).removeEnd(')')); 
                                    //system.debug(p3); 
                                    if(metaFamily.get('Catalog Logic') != Null){
                                    p3.ccrz__SEOKeywords__c = (((String.valueOf(metaFamily.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                                    p3.Product_Family__c = (((String.valueOf(metaFamily.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                                    p3.CatalogLogic__c=(((String.valueOf(metaFamily.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));

                                    }
                                    //system.debug(p3); 
                                    System.debug('Checkpoint');
                                    // p3.ccrz__ShortDescRT__c = String.valueOf(metaFamily.get('Product Description Short'));  
                                    //p3.ccrz__LongDescRT__c = String.valueOf(metaFamily.get('Product Description Long'));
                                    
                                    if(metaFamily.get('Product Description Short') != Null){
                                        p3.ccrz__ShortDescRT__c = (((String.valueOf(metaFamily.get('Product Description Short'))).removeStart('(')).removeEnd(')'));
                                    }
                                    if(metaFamily.get('Product Description Long') != Null){
                                        p3.ccrz__LongDescRT__c = (((String.valueOf(metaFamily.get('Product Description Long'))).removeStart('(')).removeEnd(')'));
                                    }    
                                  //  p3.CatalogLogic__c=(((String.valueOf(metaFamily.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                                    System.debug('Checkpoint');
									if(metaFamily.keyset().contains('Disinfection Product')){
                                    if ((((String.valueOf(metaFamily.get('Disinfection Product'))).removeStart('(')).removeEnd(')')) != Null){
                                        //  system.debug((((String.valueOf(metaFamily.get('Disinfection Product'))).removeStart('(')).removeEnd(')')));
                                        p3.DisinfectionProduct__c = Boolean.valueOf(((((String.valueOf(metaFamily.get('Disinfection Product'))).removeStart('(')).removeEnd(')')))); 
                                    }
                                    }
                                    
                                    if(metaFamily.keyset().contains('Estimated Lead Time')){
                                    if ((((String.valueOf(metaFamily.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')')) != Null){
                                        p3.ECommItemName__c = (((String.valueOf(metaFamily.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')'));
                                    }
                                    }
                                    // system.debug(p3); 
                                    
                                    toUpdateProd.add(p3);
                                    
                                    
                                    /* isexistspec=false;
if(metaFamily.keyset().contains('UL Type')){
//checkNull = (((String.valueOf(metaFamily.get('UL Type'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank((((String.valueOf(metaFamily.get('UL Type'))).removeStart('(')).removeEnd(')')))){  
if(bMap.keyset().contains(p3.ccrz__SKU__c+'UL Type A,B,C')) {
//system.debug('Data');
checkNull = (((String.valueOf(metaFamily.get('UL Type'))).removeStart('(')).removeEnd(')'));
updspec = bMap.get(p3.ccrz__SKU__c+'UL Type A,B,C');
if(checkNull.length() > 255){
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('UL Type'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('UL Type'))).removeStart('(')).removeEnd(')'));
}
//updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('UL Type'))).removeStart('(')).removeEnd(')'));
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
checkNull = (((String.valueOf(metaFamily.get('UL Type'))).removeStart('(')).removeEnd(')'));

ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('UL Type A,B,C');
//newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('UL Type'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('UL Type'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('UL Type'))).removeStart('(')).removeEnd(')'));
}
toInsert.add(newspec);


}
}      
}*/
                                    
                                    System.debug('Checkpoint');
                                    
                                    /*
isexistspec=false;
if(metaFamily.keyset().contains('Bulb Base Type')){
if(bMap.keyset().contains(p3.ccrz__SKU__c+'Bulb Base Type')) {

updspec = bMap.get(p3.ccrz__SKU__c+'Bulb Base Type');
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Bulb Base Type'))).removeStart('(')).removeEnd(')'));
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Bulb Base Type');
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Bulb Base Type'))).removeStart('(')).removeEnd(')'));
toInsert.add(newspec);


}
}
isexistspec=false;
if(metaFamily.keyset().contains('Bulb Shape')){
if(bMap.keyset().contains(p3.ccrz__SKU__c+'Bulb Shape')) {

updspec = bMap.get(p3.ccrz__SKU__c+'Bulb Shape');
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Bulb Shape'))).removeStart('(')).removeEnd(')'));
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Bulb Shape');
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Bulb Shape'))).removeStart('(')).removeEnd(')'));
toInsert.add(newspec);


}
}                     

*/									
                                    //Estimated Lead Time
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Estimated Lead Time')){
                                        checkNull = (((String.valueOf(metaFamily.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Estimated Lead Time')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Estimated Lead Time');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Estimated Lead Time');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    }            
                                    
                                    
                                    //Operating Life (Hrs)
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Operating Life (Hrs)')){
                                        checkNull = (((String.valueOf(metaFamily.get('Operating Life (Hrs)'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Operating Life (Hrs)')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Operating Life (Hrs)');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Operating Life (Hrs)'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Operating Life (Hrs)'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Operating Life (Hrs)');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Operating Life (Hrs)'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Operating Life (Hrs)'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    }            
                                    
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Effective Projected Area')){
                                        checkNull = (((String.valueOf(metaFamily.get('Effective Projected Area'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Effective Projected Area (EPA)')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Effective Projected Area (EPA)');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Effective Projected Area'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Effective Projected Area'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Effective Projected Area (EPA)');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Effective Projected Area'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Effective Projected Area'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    }           
                                    
                                    
                                    System.debug('Checkpoint');
                                    /* isexistspec=false;
if(metaFamily.keyset().contains('Paint/Finish Description')){
// checkNull = (((String.valueOf(metaFamily.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank((((String.valueOf(metaFamily.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')')))){                                          
if(bMap.keyset().contains(p3.ccrz__SKU__c+'Paint/Finish Description')) {
checkNull = (((String.valueOf(metaFamily.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
updspec = bMap.get(p3.ccrz__SKU__c+'Paint/Finish Description');
//updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
}
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
checkNull = (((String.valueOf(metaFamily.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Paint/Finish Description');
//newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
}
toInsert.add(newspec);


}
}
} */
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Operating Temp range')){
                                        checkNull = (((String.valueOf(metaFamily.get('Operating Temp range'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Operating Temp Range (°C)')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Operating Temp Range (°C)');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Operating Temp range'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Operating Temp range'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Operating Temp Range (°C)');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Operating Temp range'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Operating Temp range'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    }  
                                    ///////////////////////////////////////////////////////////////////
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('PH1 Product Line')){
                                        checkNull = (((String.valueOf(metaFamily.get('PH1 Product Line'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'PH1 Product Line')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'PH1 Product Line');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('PH1 Product Line'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('PH1 Product Line'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('PH1 Product Line');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('PH1 Product Line'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('PH1 Product Line'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    }  
                                    
                                    
                                    System.debug('Checkpoint');
                                    /////
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('PH2 Application')){
                                        checkNull = (((String.valueOf(metaFamily.get('PH2 Application'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'PH2 Application')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'PH2 Application');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('PH2 Application'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('PH2 Application'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('PH2 Application');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('PH2 Application'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('PH2 Application'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    } 
                                    
                                    
                                    /////
                                    
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('PH3 Family')){
                                        checkNull = (((String.valueOf(metaFamily.get('PH3 Family'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'PH3 Family')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'PH3 Family');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('PH3 Family'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('PH3 Family'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('PH3 Family');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('PH3 Family'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('PH3 Family'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    }  
                                    ////////
                                    /*  isexistspec=false;
if(metaFamily.keyset().contains('Housing Description')){
checkNull = (((String.valueOf(metaFamily.get('Housing Description'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){                                          
if(bMap.keyset().contains(p3.ccrz__SKU__c+'Housing Description')) {

updspec = bMap.get(p3.ccrz__SKU__c+'Housing Description');
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Housing Description'))).removeStart('(')).removeEnd(')'));
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Housing Description');
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Housing Description'))).removeStart('(')).removeEnd(')'));
toInsert.add(newspec);


}
}    
} 
*/
                                    
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Housing Description')){
                                        checkNull = (((String.valueOf(metaFamily.get('Housing Description'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Housing Description')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Housing Description');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Housing Description'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Housing Description'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Housing Description');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Housing Description'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Housing Description'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    }  
                                    
                                    ////
                                    /*
isexistspec=false;
if(metaFamily.keyset().contains('Lensing Description')){
if(bMap.keyset().contains(p3.ccrz__SKU__c+'Lensing Description')) {

updspec = bMap.get(p3.ccrz__SKU__c+'Lensing Description');
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Lensing Description'))).removeStart('(')).removeEnd(')'));
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Lensing Description');
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Lensing Description'))).removeStart('(')).removeEnd(')'));
toInsert.add(newspec);


}
} 
*/  
                                    
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Warranty')){
                                        checkNull = (((String.valueOf(metaFamily.get('Warranty'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Warranty')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Warranty');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Warranty'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Warranty'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Warranty');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Warranty'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Warranty'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    }  
                                    
                                    /////
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Brand')){
                                        checkNull = (((String.valueOf(metaFamily.get('Brand'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Brand')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Brand');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Brand'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Brand'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Brand');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Brand'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Brand'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    }  
                                    
                                    
                                    /////
                                    
                                    
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Family Applications')){
                                        checkNull = (((String.valueOf(metaFamily.get('Family Applications'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Family Applications')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Family Applications');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Family Applications'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Family Applications'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Family Applications');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Family Applications'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Family Applications'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    }  
                                    
                                    ///
                                    
                                    
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Product Category')){
                                        checkNull = (((String.valueOf(metaFamily.get('Product Category'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Product Category')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Product Category');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Product Category'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Product Category'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Product Category');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Product Category'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Product Category'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    }  
                                    ///
                                    
                                    
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Product Subcategory')){
                                        checkNull = (((String.valueOf(metaFamily.get('Product Subcategory'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Product Subcategory')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Product Subcategory');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Product Subcategory'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Product Subcategory'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Product Subcategory');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Product Subcategory'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Product Subcategory'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    }  
                                    
                                    //////////////////////////////////////////////////////////////////////
                                    
                                    
                                    /* 
if(metaFamily.keyset().contains('Associated Parts')){
checkNull = (((String.valueOf(metaFamily.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Associated Parts');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} 
*/
                                    /* isexistspec=false;
if(metaFamily.keyset().contains('Associated Parts')){
// checkNull = (((String.valueOf(metaFamily.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank((((String.valueOf(metaFamily.get('Associated Parts'))).removeStart('(')).removeEnd(')')))){                                          
if(bMap.keyset().contains(p3.ccrz__SKU__c+'Associated Parts')) {
checkNull = (((String.valueOf(metaFamily.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
updspec = bMap.get(p3.ccrz__SKU__c+'Associated Parts');
//updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Associated Parts'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
}
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
checkNull = (((String.valueOf(metaFamily.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Associated Parts');
//newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Associated Parts'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
}
toInsert.add(newspec);


}
}    
} */
                               /*     if(metaFamily.keyset().contains('Associated Parts')){
                                        checkNull = (((String.valueOf(metaFamily.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
                                        if(!String.isBlank(checkNull)){
                                            semivalues=checkNull.split('\\;');
                                            for(String ele:semivalues){
                                                
                                                ccrz__E_RelatedProduct__c relaProd = new ccrz__E_RelatedProduct__c();
                                                relaProd.ccrz__ShortDesc__c = 'Related Parts';
                                                relaProd.ccrz__RelatedProduct__c = String.valueOf(existrelaprod.get(ele));
                                                relaProd.ccrz__RelatedProductType__c ='Related';
                                                relaProd.ccrz__Product__c = p3.id;
                                                toInsertRelProd.add(relaProd);
                                            }
                                        }
                                    }
                                    
                                */    
                                    /*
if(metaFamily.keyset().contains('Technology Enabled')){
checkNull = (((String.valueOf(metaFamily.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Technology Enabled');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} 
System.debug('Checkpoint');

*/ 
                                    /*
if(metaFamily.keyset().contains('Programs')){
checkNull = (((String.valueOf(metaFamily.get('Programs'))).removeStart('(')).removeEnd(')'));
system.debug(checkNull);
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
system.debug(semivalues);
for(String ele:semivalues){
system.debug(ele);
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Programs');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} 
*/
                                    
                                    /*
if(metaFamily.keyset().contains('Material')){
checkNull = (((String.valueOf(metaFamily.get('Material'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Material');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} 




if(metaFamily.keyset().contains('Environmental Conditions')){
checkNull = (((String.valueOf(metaFamily.get('Environmental Conditions'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Environmental Conditions');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} 


*/
                                    /*
if(metaFamily.keyset().contains('Regulatory')){
checkNull = (((String.valueOf(metaFamily.get('Regulatory'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Regulatory');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} 
*/
                                    
                                    /*   if(metaFamily.keyset().contains('Regulatory')){
checkNull = (((String.valueOf(metaFamily.get('Regulatory'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
//  semivalues=checkNull.split('\\;');
//  for(String ele:checkNull){
ccrz__E_ProductTab__c prodtab = new ccrz__E_ProductTab__c();
prodtab.ccrz__Product__c = p3.id;
prodtab.ccrz__Tab__c = 'Resources';
prodtab.ccrz__ContentRT__c = String.valueOf(checkNull);
prodtab.ccrz__Locale__c = 'en_US';
toInsertProdTab.add(prodtab);
}
}*/
                                    
                                    
                                    System.debug('Checkpoint');
                                    /* 
if(metaFamily.keyset().contains('Certifications')){
checkNull = (((String.valueOf(metaFamily.get('Certifications'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Certifications');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} 

*/ 
                                    ////////////////////////////////////////////////////
                                    
                                    /* isexistspec=false;
if(metaFamily.keyset().contains('Certifications')){
//checkNull = (((String.valueOf(metaFamily.get('Certifications'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank((((String.valueOf(metaFamily.get('Certifications'))).removeStart('(')).removeEnd(')')))){                                          
if(bMap.keyset().contains(p3.ccrz__SKU__c+'Certifications')) {
checkNull = (((String.valueOf(metaFamily.get('Certifications'))).removeStart('(')).removeEnd(')'));
updspec = bMap.get(p3.ccrz__SKU__c+'Certifications');
//updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Certifications'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Certifications'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Certifications'))).removeStart('(')).removeEnd(')'));
}
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
checkNull = (((String.valueOf(metaFamily.get('Certifications'))).removeStart('(')).removeEnd(')'));
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Certifications');
//newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Certifications'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Certifications'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Certifications'))).removeStart('(')).removeEnd(')'));
}
toInsert.add(newspec);


}
}    
} 

////
isexistspec=false;
if(metaFamily.keyset().contains('Technology Enabled')){
// checkNull = (((String.valueOf(metaFamily.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank((((String.valueOf(metaFamily.get('Technology Enabled'))).removeStart('(')).removeEnd(')')))){                                             
if(bMap.keyset().contains(p3.ccrz__SKU__c+'Technology Enabled')) {
checkNull = (((String.valueOf(metaFamily.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
updspec = bMap.get(p3.ccrz__SKU__c+'Technology Enabled');
//updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Technology Enabled'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
}
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
checkNull = (((String.valueOf(metaFamily.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Technology Enabled');
// newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Technology Enabled'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
}
toInsert.add(newspec);


}
}    
} */
                                    ///
                                    
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Material')){
                                        checkNull = (((String.valueOf(metaFamily.get('Material'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Material')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Material');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Material'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Material'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Material');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Material'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Material'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    } 
                                    
                                    
                                    
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Environmental Conditions')){
                                        checkNull = (((String.valueOf(metaFamily.get('Environmental Conditions'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Environmental Conditions')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Environmental Conditions');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Environmental Conditions'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Environmental Conditions'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Environmental Conditions');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Environmental Conditions'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Environmental Conditions'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    } 
                                    //////////////////////////////////////////////////
                                    /*
if(metaFamily.keyset().contains('Product Shape')){
checkNull = (((String.valueOf(metaFamily.get('Product Shape'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);
newspec.ccrz__Spec__c=allspec.get('Product Shape');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

}*/ 
                                    
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Product Shape')){
                                        checkNull = (((String.valueOf(metaFamily.get('Product Shape'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Product Shape')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Product Shape');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Product Shape'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Product Shape'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Product Shape');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Product Shape'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Product Shape'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    }                                     
                                    /*
isexistcat=false;
if(metaFamily.keyset().contains('Country of Origin')){
tempCat=(((String.valueOf(metaFamily.get('Country of Origin'))).removeStart('(')).removeEnd(')'));
if(dMap.keyset().contains(p3.ccrz__SKU__c+tempCat.toUpperCase()+'*COUNTRY-OF-ORIGIN')) {

isexistcat=true;

}

if(!isexistcat){
ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*COUNTRY-OF-ORIGIN');
toUpdatecat.add(newcat);

ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
newcat1.ccrz__Category__c = allcat.get('COUNTRY-OF-ORIGIN');
toUpdatecat.add(newcat1);



}
}
*/
                                    System.debug('Checkpoint');
                                    if(metaFamily.keyset().contains('PH1 Product Line')){
                                        tempCat=(((String.valueOf(metaFamily.get('PH1 Product Line'))).removeStart('(')).removeEnd(')'));
                                            if(!String.isBlank(tempCat)){
                                            ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                            newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*PH1 PRODUCT LINE');
                                            toUpdatecat.add(newcat);
                                            
                                            ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                            newcat1.ccrz__Category__c = allcat.get('PH1 PRODUCT LINE');
                                            toUpdatecat.add(newcat1);
                                            }
                                        }
                                    
                                    
                                    if(metaFamily.keyset().contains('PH2 Application')){
                                        tempCat=(((String.valueOf(metaFamily.get('PH2 Application'))).removeStart('(')).removeEnd(')'));
                                            if(!String.isBlank(tempCat)){
                                            ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                            newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*PH2 APPLICATION');
                                            toUpdatecat.add(newcat);
                                            
                                            ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                            newcat1.ccrz__Category__c = allcat.get('PH2 APPLICATION');
                                            toUpdatecat.add(newcat1);
                                            }
                                        }
                                    
                                    
                                    
                                    if(metaFamily.keyset().contains('PH3 Family')){
                                        tempCat=(((String.valueOf(metaFamily.get('PH3 Family'))).removeStart('(')).removeEnd(')'));
                                            if(!String.isBlank(tempCat)){
                                            ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                            newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*PH3 FAMILY');
                                            toUpdatecat.add(newcat);
                                            
                                            ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                            newcat1.ccrz__Category__c = allcat.get('PH3 FAMILY');
                                            toUpdatecat.add(newcat1);
                                            }
                                        }
                                    
                                    System.debug('Checkpoint');
                                    /////////////////////////////////////////////////////////////////////////////
                                    if(metaFamily.keyset().contains('Catalog Logic')){
                                        tempCat=(((String.valueOf(metaFamily.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                                            if(!String.isBlank(tempCat)){
                                            ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                            newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*FAMILY');
                                            toUpdatecat.add(newcat);
                                            
                                            ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                            newcat1.ccrz__Category__c = allcat.get('FAMILY');
                                            toUpdatecat.add(newcat1);
                                            }
                                        }
                                    
                                    
                                    
                                    
                                    ////
                                    
                                    System.debug('Checkpoint');
                                    isexistspec=False;
                                    if(metaFamily.keyset().contains('Catalog Logic')){
                                        checkNull = (((String.valueOf(metaFamily.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));                        
                                        if(bMap.keyset().contains(p3.ccrz__SKU__c+'Product Family')) {
                                            updspec = bMap.get(p3.ccrz__SKU__c+'Product Family');
                                            if(checkNull.length() > 255){
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Catalog Logic'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                updspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toUpdate.add(updspec);
                                            isexistspec=true;      
                                        }
                                        
                                        if(!isexistspec){
                                            if(!String.isBlank(checkNull)){
                                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p3.Id);                                
                                                newspec.ccrz__Spec__c=allspec.get('Product Family');
                                                if(checkNull.length() > 255){
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Catalog Logic'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                                }
                                                else{
                                                    newspec.ccrz__SpecValue__c=(((String.valueOf(metaFamily.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                                                }
                                                toInsert.add(newspec);                                    
                                            }
                                        }                                        
                                    } 
                                    ///////////
                                    /* isexistcat=false;
if(metaFamily.keyset().contains('Programs')){
tempCat=(((String.valueOf(metaFamily.get('Programs'))).removeStart('(')).removeEnd(')'));
if(dMap.keyset().contains(p3.ccrz__SKU__c+tempCat.toUpperCase()+'*Programs')) {

isexistcat=true;

}
if(!isexistcat){
ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*Programs');
toUpdatecat.add(newcat);

ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
newcat1.ccrz__Category__c = allcat.get('Programs');
toUpdatecat.add(newcat1);

}
}
*/
                                    //////////////////////////////////////////////////////////////////////////////
                                    
                                    System.debug('Checkpoint');
                                    isexistcat=false;
                                    if(metaFamily.keyset().contains('Brand')){
                                        tempCat=(((String.valueOf(metaFamily.get('Brand'))).removeStart('(')).removeEnd(')'));
                                            if(!String.isBlank(tempCat)){
                                            ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                            newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*BRAND');
                                            toUpdatecat.add(newcat);
                                            
                                            ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                            newcat1.ccrz__Category__c = allcat.get('BRAND');
                                            toUpdatecat.add(newcat1);
                                            }
                                        }
                                    
                                    
                                    
                                    System.debug('Checkpoint');
                                    
                                    if(metaFamily.keyset().contains('Family Applications')){
                                        checkNull = (((String.valueOf(metaFamily.get('Family Applications'))).removeStart('(')).removeEnd(')'));
                                        if(!String.isBlank(checkNull)){
                                            semivalues=checkNull.split('\\;');
                                            for(String ele:semivalues){
                                                ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                                newcat.ccrz__Category__c = allcat.get(ele.toUpperCase()+'*FAMILY APPLICATIONS');
                                                toUpdatecat.add(newcat);
                                            }
                                            ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                            newcat1.ccrz__Category__c = allcat.get('FAMILY Applications');
                                            toUpdatecat.add(newcat1);
                                        }
                                    } 
                                    
                                    
                                    
                                    
                                    /*if(metaFamily.keyset().contains('Product Category')){
checkNull = (((String.valueOf(metaFamily.get('Product Category'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
newcat.ccrz__Category__c = allcat.get('PRODUCT CATEGORY');
newcat.CategoryValue__c=String.valueOf(ele);
toUpdatecat.add(newcat);
}
}
}*/ 
                                    System.debug('Checkpoint');
                                    if(metaFamily.keyset().contains('Product Category')){
                                        checkNull = (((String.valueOf(metaFamily.get('Product Category'))).removeStart('(')).removeEnd(')'));
                                        if(!String.isBlank(checkNull)){
                                            semivalues=checkNull.split('\\;');
                                            if(metaFamily.keyset().contains('Product Subcategory')){
                                                checkNull2 = (((String.valueOf(metaFamily.get('Product Subcategory'))).removeStart('(')).removeEnd(')'));
                                                if(!String.isBlank(checkNull2)){
                                                    semivalues2=checkNull2.split('\\;');
                                                    for(String ele:semivalues){
                                                        for(String ele2:semivalues2){
                                                            ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                                            newcat.ccrz__Category__c = allcat.get(ele2.toUpperCase()+'*'+ele.toUpperCase().replaceAll( '\\s+', ''));
                                                            toUpdatecat.add(newcat);
                                                        }
                                                        ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
                                                        newcat1.ccrz__Category__c = allcat.get(ele.toUpperCase().replaceAll( '\\s+', ''));
                                                        toUpdatecat.add(newcat1); 
                                                    }
                                                    /*  if(!dMap.keyset().contains(p3.ccrz__SKU__c+'PRODUCTS')) {
ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
newcat1.ccrz__Category__c = allcat.get('PRODUCTS');
toUpdatecat.add(newcat1);
}*/
                                                }
                                            } 
                                        }
                                    }
                                    
                                    
                                    System.debug('Checkpoint');
                                    
                                    /*if(metaFamily.keyset().contains('Product Subcategory')){
checkNull = (((String.valueOf(metaFamily.get('Product Subcategory'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p3.Id);
newcat.ccrz__Category__c = allcat.get('PRODUCT SUBCATEGORY');
newcat.CategoryValue__c=String.valueOf(ele);
toUpdatecat.add(newcat);
}
}
}*/ 
                                    
                                    
                                    
                                    System.debug('Checkpoint');
                                    /* 

if(metaFamily.keyset().contains('Family Features & Benefits Bullets')){
checkNull = (((String.valueOf(metaFamily.get('Family Features & Benefits Bullets'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p3.Id);
newmed.ccrz__MediaType__c='Family Features & Benefits Bullets';                                             
newmed.ccrz__ProductDescription__c=String.valueOf(ele);
newmed.ccrz__ProductMediaSource__c='URI';
if(metaFamily.keyset().contains('Website Link')){
newmed.ccrz__URI__c = (((String.valueOf(metaFamily.get('Website Link'))).removeStart('(')).removeEnd(')'));
}

toInsertMed.add(newmed);
}
}
} 
*/
                                    System.debug('Checkpoint');
                                    /*  
isexistmed=false;
if(metaFamily.keyset().contains('Warranty')){
if(fMap.keyset().contains(p3.ccrz__SKU__c+'Warranty')) {

updmed = fMap.get(p3.ccrz__SKU__c+'Warranty');
updmed.ccrz__ProductDescription__c=(((String.valueOf(metaFamily.get('Warranty'))).removeStart('(')).removeEnd(')'));
toUpdateMed.add(updmed);
isexistmed=true;

}
if(!isexistmed){
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p3.Id);

newmed.ccrz__MediaType__c='Warranty';
newmed.ccrz__ProductDescription__c=(((String.valueOf(metaFamily.get('Warranty'))).removeStart('(')).removeEnd(')'));
toInsertMed.add(newmed);


}
} 

*/
                                    isexistmed=false;
                                    if(metaFamily.keyset().contains('Website Link')){
                                        if(fMap.keyset().contains(p3.ccrz__SKU__c+'Website URL')) {
                                            
                                            updmed = fMap.get(p3.ccrz__SKU__c+'Website URL');
                                            updmed.ccrz__ProductMediaSource__c='URI';
                                            updmed.ccrz__URI__c = (((String.valueOf(metaFamily.get('Website Link'))).removeStart('(')).removeEnd(')'));
                                            toUpdateMed.add(updmed);
                                            isexistmed=true;
                                            
                                        }
                                        if(!isexistmed){
                                            ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p3.Id);
                                            
                                            newmed.ccrz__MediaType__c='Website URL';
                                            newmed.ccrz__ProductMediaSource__c='URI';
                                            newmed.ccrz__URI__c = (((String.valueOf(metaFamily.get('Website Link'))).removeStart('(')).removeEnd(')'));
                                            toInsertMed.add(newmed);
                                            
                                            
                                        }
                                    } 
                                    system.debug('Checkpoint');
                                    
                                    /*  
isexistmed=false;
if(metaFamily.keyset().contains('Lensing Description')){
if(fMap.keyset().contains(p3.ccrz__SKU__c+'Lensing Description')) {

updmed = fMap.get(p3.ccrz__SKU__c+'Lensing Description');
updmed.ccrz__ProductDescription__c=(((String.valueOf(metaFamily.get('Lensing Description'))).removeStart('(')).removeEnd(')'));
toUpdateMed.add(updmed);
isexistmed=true;

}
if(!isexistmed){
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p3.Id);

newmed.ccrz__MediaType__c='Lensing Description';
newmed.ccrz__ProductDescription__c=(((String.valueOf(metaFamily.get('Lensing Description'))).removeStart('(')).removeEnd(')'));
toInsertMed.add(newmed);


}
} 
*/  /*
isexistmed=false;
if(metaFamily.keyset().contains('Housing Description')){
if(fMap.keyset().contains(p3.ccrz__SKU__c+'Housing Description')) {

updmed = fMap.get(p3.ccrz__SKU__c+'Housing Description');
updmed.ccrz__ProductDescription__c=(((String.valueOf(metaFamily.get('Housing Description'))).removeStart('(')).removeEnd(')'));
toUpdateMed.add(updmed);
isexistmed=true;

}
if(!isexistmed){
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p3.Id);

newmed.ccrz__MediaType__c='Housing Description';
newmed.ccrz__ProductDescription__c=(((String.valueOf(metaFamily.get('Housing Description'))).removeStart('(')).removeEnd(')'));
toInsertMed.add(newmed);


}
}
*/
                                    /* if(metaFamily.keyset().contains('Product Images')){

for(Object img :imagedata){
Map<String,Object> img1 = (Map<String,Object>)img;
if(String.valueOf(img1.get('Image Type'))=='Main Image'){  
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p3.Id);
newmed.ccrz__MediaType__c='Product Image';
newmed.Image_type__c=String.valueOf(img1.get('Image Type'));
newmed.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
newmed.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed);

ccrz__E_ProductMedia__c newmed1 = new ccrz__E_ProductMedia__c(ccrz__Product__c=p3.Id);
newmed1.ccrz__MediaType__c='Product Image Thumbnail';
newmed1.Image_type__c=String.valueOf(img1.get('Image Type'));
newmed1.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
newmed1.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed1);

ccrz__E_ProductMedia__c newmed2 = new ccrz__E_ProductMedia__c(ccrz__Product__c=p3.Id);
newmed2.ccrz__MediaType__c='Product Search Image';
newmed2.Image_type__c=String.valueOf(img1.get('Image Type'));
newmed2.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
newmed2.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed2);

}

else{
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p3.Id);
newmed.ccrz__MediaType__c='Alternate Images';
newmed.Image_type__c=String.valueOf(img1.get('Image Type'));
newmed.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
newmed.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed);

ccrz__E_ProductMedia__c newmed1 = new ccrz__E_ProductMedia__c(ccrz__Product__c=p3.Id);
newmed1.ccrz__MediaType__c='Alternate Thumbnails';
newmed1.Image_type__c=String.valueOf(img1.get('Image Type'));
newmed1.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
newmed1.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed1);
}

}





}
System.debug('Checkpoint');
if(metaFamily.keyset().contains('Product Documents')){
for(Object doc :docData){
Map<String,Object> doc1 = (Map<String,Object>)doc;
if(doc1.get('Document Type') == 'Spec Sheet'){
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p3.Id);
newmed.ccrz__MediaType__c='Spec Sheet';
newmed.ccrz__URI__c=String.valueOf(doc1.get('Document URL'));
newmed.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed);
}
}


}
*/ 
                                }
                            }
                            }                            
                            
                       // }  
                        
                    }
                    
                } 
                
            } 
            
            
            transient map<id,ccrz__E_Product__c> prodmap = new map<id,ccrz__E_Product__c>();
            transient map<id,ccrz__E_ProductSpec__c> prodspecmap = new map<id,ccrz__E_ProductSpec__c>();
            transient map<id,ccrz__E_ProductMedia__c> prodmedmap = new map<id,ccrz__E_ProductMedia__c>();
            
            
            prodmap.putall(toUpdateProd);
            if(prodmap.size()>0){
                update prodmap.values();
            }
            //update toUpdateProd;
            prodspecmap.putall(toUpdate);
            if(prodspecmap.size()>0){
                update prodspecmap.values();
            }
            //update toUpdate;
            for(ccrz__E_ProductCategory__c  cat: toUpdatecat){
                system.debug(cat);
                if(cat.ccrz__Category__c != null){
                    insertCatsec.add(cat);
                }
            }
            
            
            
            
            
            
            Database.insert(insertCatsec);
            System.debug('Checkpoint');
            Database.insert(toInsert);
            System.debug('Checkpoint');
            Database.insert(toInsertMed);
            Database.insert(toInsertRelProd);
            Database.insert(toInsertProdTab);
            
            prodmedmap.putall(toUpdateMed);
            if(prodmedmap.size()>0){
                update prodmedmap.values();
            }
            
            
            //update toUpdateMed;
            //update toUpdatecatex;
            toInsertProdTab.clear();
            toUpdateProd.clear();
            toUpdate.clear();
            toUpdatecat.clear();
            toInsert.clear();    
            toInsertMed.clear();
            toUpdateMed.clear(); 
            prodmap.clear();
            prodspecmap.clear();
            prodmedmap.clear();
            toInsertRelProd.clear();
            insertCatsec.clear();
            system.debug('***getCpuTime()***'+Limits.getCpuTime());
            transient String a;
            transient Map<String, Object> prod1;
            
            
            System.debug('Checkpoint');
            for (Object prod: aSKU) {
                System.debug('Checkpoint'); 
                prod1 = (Map<String, Object>)prod;
                
                if(prod1.keyset().contains('Product Images')){
                    imagedata = (List<Object>)JSON.deserializeUntyped('['+(((String.valueOf(prod1.get('Product Images'))).removeStart('(')).removeEnd(')'))+']');
                }
                system.debug(prod1.get('SKU'));
                System.debug('Checkpoint');
                system.debug(prod1.get('SKU'));
                if(prod1.keyset().contains('Product Documents')){
                    docData = (List<Object>)JSON.deserializeUntyped('['+(((String.valueOf(prod1.get('Product Documents'))).removeStart('(')).removeEnd(')'))+']');
                    //system.debug(prod1.get('imagedata'));
                }
                // for (String key: prod1.keyset()){
                // system.debug(prod1);
                // system.debug(prod1.get('UPC'));
                // system.debug(prod1.get('SKU'));
                //indelement= prod1.get('SKU');
                System.debug('Checkpoint');
                system.debug(prod1.get('SKU'));
                // system.debug(((String.valueOf(prod1.get('SKU'))).removeStart('(')).removeEnd(')'));
                if(existprodmap.keyset().contains(((String.valueOf(prod1.get('SKU'))).removeStart('(')).removeEnd(')')))
                { 
                    system.debug('***SKU Found***'+String.valueOf(prod1.get('SKU')));
                    // system.debug(prod1.get('SKU'));
                    
                    p1 = existprodmap.get(((String.valueOf(prod1.get('SKU'))).removeStart('(')).removeEnd(')'));
                    // system.debug(prod1.get(((String.valueOf(prod1.get('UPC'))).removeStart('(')).removeEnd(')')));
                    if(String.valueOf(prod1.get('UPC')) !=Null){
                        //system.debug(((String.valueOf(prod1.get('UPC'))).removeStart('(')).removeEnd(')'));
                        a =(((String.valueOf(prod1.get('UPC'))).removeStart('(')).removeEnd(')'));
                        p1.UPC__c =String.valueOf(a); 
                        toUpdateProd.add(p1);
                    }
                    if(String.valueOf(prod1.get('QuickShip')) !=Null){
                        checkNull = (((String.valueOf(prod1.get('QuickShip'))).removeStart('(')).removeEnd(')'));
                        if(!String.isBlank(checkNull)){
                            p1.Quickship__c = true ;
                            toUpdateProd.add(p1);
                        }
                        else{
                            p1.Quickship__c = false ;
                            toUpdateProd.add(p1); 
                        }
                    }
                    
                    System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Lumens')){
                        checkNull = (((String.valueOf(prod1.get('Lumens'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Lumens')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Lumens');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Lumens'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Lumens'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Lumens');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Lumens'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Lumens'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                    
                    ////////////////////////////////////////////////////////////////////////////////////////////
                    
                       System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Country of Origin')){
                        checkNull = (((String.valueOf(prod1.get('Country of Origin'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Country of Origin')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Country of Origin');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Country of Origin'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Country of Origin'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Country of Origin');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Country of Origin'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Country of Origin'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                    
                    //
                        System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Bulb Base Type')){
                        checkNull = (((String.valueOf(prod1.get('Bulb Base Type'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Bulb Base Type')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Bulb Base Type');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Bulb Base Type'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Bulb Base Type'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Bulb Base Type');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Bulb Base Type'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Bulb Base Type'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                    //
                    
                                System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('SKU Configuration')){
                        checkNull = (((String.valueOf(prod1.get('SKU Configuration'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Shape')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Shape');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('SKU Configuration'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('SKU Configuration'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Shape');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('SKU Configuration'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('SKU Configuration'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                    System.debug('Checkpoint');
                    /////
                    isexistspec=False;
                    if(prod1.keyset().contains('ProLine')){
                        checkNull = (((String.valueOf(prod1.get('ProLine'))).removeStart('(')).removeEnd(')'));
                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'ProLine')) {
                            
                            updspec = bMap.get(p1.ccrz__SKU__c+'ProLine');
                            //system.debug('updspec');
                            if(!String.isBlank(checkNull)){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('ProLine'))).removeStart('(')).removeEnd(')'));
                            }
                            else{
                                updspec.ccrz__SpecValue__c='No';
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;    
                        }
                        
                        if(!isexistspec){
                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);
                            
                            newspec.ccrz__Spec__c=allspec.get('ProLine');
                            if(!String.isBlank(checkNull)){
                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('ProLine'))).removeStart('(')).removeEnd(')'));
                            }
                            else{
                                newspec.ccrz__SpecValue__c='No';
                            }
                            toInsert.add(newspec);                                  
                        }
                        
                        
                    }
                    //
                    
                    isexistspec=False;
                    if(prod1.keyset().contains('QuickShip')){
                        checkNull = (((String.valueOf(prod1.get('QuickShip'))).removeStart('(')).removeEnd(')'));
                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'QuickShip')) {
                            
                            updspec = bMap.get(p1.ccrz__SKU__c+'QuickShip');
                            //system.debug('updspec');
                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('QuickShip'))).removeStart('(')).removeEnd(')'));
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);
                                
                                newspec.ccrz__Spec__c=allspec.get('QuickShip');
                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('QuickShip'))).removeStart('(')).removeEnd(')'));
                                toInsert.add(newspec);  
                            }
                        }
                    }     
                    // }
                                       
                    System.debug('Checkpoint');
                    //
                    /* isexistspec=False;

if(prod1.keyset().contains('Bulb Shape')){

if(bMap.keyset().contains(p1.ccrz__SKU__c+'Bulb Shape')) {

updspec = bMap.get(p1.ccrz__SKU__c+'Bulb Shape');
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Bulb Shape'))).removeStart('(')).removeEnd(')'));
toUpdate.add(updspec);
isexistspec=true;      
}

if(!isexistspec){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);

newspec.ccrz__Spec__c=allspec.get('Bulb Shape');
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Bulb Shape'))).removeStart('(')).removeEnd(')'));
toInsert.add(newspec);                                    
}
}*/
                    
                    
                  
                    System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Lensing Description')){
                        checkNull = (((String.valueOf(prod1.get('Lensing Description'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Lensing Description')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Lensing Description');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Lensing Description'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Lensing Description'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Lensing Description');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Lensing Description'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Lensing Description'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                    
                    //
                    
                    System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Efficacy (μmol/J)')){
                        checkNull = (((String.valueOf(prod1.get('Efficacy (μmol/J)'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Efficacy (μmol/J)')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Efficacy (μmol/J)');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Efficacy (μmol/J)'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Efficacy (μmol/J)'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Efficacy (μmol/J)');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Efficacy (μmol/J)'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Efficacy (μmol/J)'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  

//

                    System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Efficacy')){
                        checkNull = (((String.valueOf(prod1.get('Efficacy'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Efficacy')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Efficacy');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Efficacy'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Efficacy'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Efficacy');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Efficacy'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Efficacy'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  

//

                    System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Light Output PPF')){
                        checkNull = (((String.valueOf(prod1.get('Light Output PPF'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Light Output PPF')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Light Output PPF');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Light Output PPF'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Light Output PPF'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Light Output PPF');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Light Output PPF'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Light Output PPF'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  

//


                    System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Spectra')){
                        checkNull = (((String.valueOf(prod1.get('Spectra'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Spectra')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Spectra');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Spectra'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Spectra'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Spectra');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Spectra'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Spectra'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  

//


                    System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('UV Output')){
                        checkNull = (((String.valueOf(prod1.get('UV Output'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'UV Output')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'UV Output');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UV Output'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UV Output'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('UV Output');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UV Output'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UV Output'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  


//


                    System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('UV Range')){
                        checkNull = (((String.valueOf(prod1.get('UV Range'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'UV Range')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'UV Range');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UV Range'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UV Range'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('UV Range');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UV Range'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UV Range'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  



                    /////////
                    /*
isexistcat=false;
if(prod1.keyset().contains('Programs')){
tempCat=(((String.valueOf(prod1.get('Programs'))).removeStart('(')).removeEnd(')'));
if(dMap.keyset().contains(p1.ccrz__SKU__c+tempCat.toUpperCase()+'*Programs')) {

isexistcat=true;

}
if(!isexistcat){
ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p1.Id);
newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*Programs');
toUpdatecat.add(newcat);    

ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p1.Id);
newcat1.ccrz__Category__c = allcat.get('Programs');
toUpdatecat.add(newcat1);    

}
} 
*/
                    
                    if(prod1.keyset().contains('Programs')){
                        checkNull = (((String.valueOf(prod1.get('Programs'))).removeStart('(')).removeEnd(')'));
                        if(!String.isBlank(checkNull)){
                            semivalues=checkNull.split('\\;');
                            for(String ele:semivalues){
                                ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p1.Id);
                                newcat.ccrz__Category__c = allcat.get(ele.toUpperCase()+'*PROGRAMS');
                                toUpdatecat.add(newcat);
                            }
                            
                            ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p1.Id);
                            newcat1.ccrz__Category__c = allcat.get('PROGRAMS');
                            toUpdatecat.add(newcat1);
                        }
                    } 
                    
                    System.debug('Checkpoint');
                    
                    //////
                    /*  isexistspec=False;
//CC Product Spec Code
if(prod1.keyset().contains('Programs')){
//system.debug('updspec');
if(bMap.keyset().contains(p1.ccrz__SKU__c+'Programs')) {

updspec = bMap.get(p1.ccrz__SKU__c+'Programs');
//system.debug('updspec');
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Programs'))).removeStart('(')).removeEnd(')'));
toUpdate.add(updspec);
isexistspec=true;      
}

if(!isexistspec){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);

newspec.ccrz__Spec__c=allspec.get('Programs');
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Programs'))).removeStart('(')).removeEnd(')'));
toInsert.add(newspec);                                    
}
}
*/
                    
                    ///////////////////////////////////////////////////////////////////////////////////////////
                    
                    System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Wattage (W)')){
                        checkNull = (((String.valueOf(prod1.get('Wattage (W)'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Wattage (W)')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Wattage (W)');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Wattage (W)'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Wattage (W)'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Wattage (W)');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Wattage (W)'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Wattage (W)'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                        
                        
                    //
                     System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Voltage (V)')){
                        checkNull = (((String.valueOf(prod1.get('Voltage (V)'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Voltage (V)')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Voltage (V)');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Voltage (V)'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Voltage (V)'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Voltage (V)');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Voltage (V)'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Voltage (V)'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    } 
                    
                    //
                    
                    isexistspec=False;
                    if(prod1.keyset().contains('Color Temperature')){
                        checkNull = (((String.valueOf(prod1.get('Color Temperature'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Color Temperature')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Color Temperature');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Color Temperature'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Color Temperature'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Color Temperature');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Color Temperature'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Color Temperature'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                        //
                   
                        System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('CRI')){
                        checkNull = (((String.valueOf(prod1.get('CRI'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'CRI')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'CRI');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('CRI'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('CRI'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('CRI');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('CRI'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('CRI'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                        //
                    
                    
                       System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Optical Distribution')){
                        checkNull = (((String.valueOf(prod1.get('Optical Distribution'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Optical Distribution')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Optical Distribution');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Optical Distribution'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Optical Distribution'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Optical Distribution');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Optical Distribution'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Optical Distribution'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                        //
                    
                         System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('BUG Rating')){
                        checkNull = (((String.valueOf(prod1.get('BUG Rating'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'BUG Rating')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'BUG Rating');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('BUG Rating'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('BUG Rating'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('BUG Rating');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('BUG Rating'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('BUG Rating'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                        //
                    
                    
                        System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Item Color')){
                        checkNull = (((String.valueOf(prod1.get('Item Color'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Item Color')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Item Color');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Item Color'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Item Color'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Item Color');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Item Color'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Item Color'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                        //
                    
                        System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Accessories & Options')){
                        checkNull = (((String.valueOf(prod1.get('Accessories & Options'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Accessories & Options')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Accessories & Options');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Accessories & Options'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Accessories & Options'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Accessories & Options');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Accessories & Options'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Accessories & Options'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                    ///////////////////////////////////////////////////
                   
                         System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Associated Parts')){
                        checkNull = (((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Associated Parts')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Associated Parts');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Associated Parts');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                    /////
                    
                        System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Certifications')){
                        checkNull = (((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Certifications')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Certifications');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Certifications');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                    ///////
                    
                       System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Technology Enabled')){
                        checkNull = (((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Technology Enabled')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Technology Enabled');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Technology Enabled');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                    //////
                    
                         System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Paint/Finish Description')){
                        checkNull = (((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Paint/Finish Description')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Paint/Finish Description');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Paint/Finish Description');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                    ///////
                    
                         System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('UL Type')){
                        checkNull = (((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'UL Type')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'UL Type');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('UL Type');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                    ///////
                    if(prod1.keyset().contains('Regulatory')){
                        checkNull = (((String.valueOf(prod1.get('Regulatory'))).removeStart('(')).removeEnd(')'));
                        if(!String.isBlank(checkNull)){
                            //  semivalues=checkNull.split('\\;');
                            //  for(String ele:checkNull){
                            ccrz__E_ProductTab__c prodtab = new ccrz__E_ProductTab__c();
                            prodtab.ccrz__Product__c = p1.id;
                            prodtab.ccrz__Tab__c = 'Resources';
                            prodtab.ccrz__ContentRT__c = String.valueOf(checkNull);
                            prodtab.ccrz__Locale__c = 'en_US';
                            toInsertProdTab.add(prodtab);
                        }
                    }
                    
                    //
                    
                                System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Accessory SKU')){
                        checkNull = (((String.valueOf(prod1.get('Accessory SKU'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Accessory')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Accessory');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Accessory SKU'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Accessory SKU'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Accessory');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Accessory SKU'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Accessory SKU'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                    //
                    
                        System.debug('Checkpoint');
                    isexistspec=False;
                    if(prod1.keyset().contains('Controls Platform')){
                        checkNull = (((String.valueOf(prod1.get('Controls Platform'))).removeStart('(')).removeEnd(')'));                        
                        if(bMap.keyset().contains(p1.ccrz__SKU__c+'Controls Platform')) {
                            updspec = bMap.get(p1.ccrz__SKU__c+'Controls Platform');
                            if(checkNull.length() > 255){
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Controls Platform'))).removeStart('(')).removeEnd(')')).substring(0,250);
                            }
                            else{
                                updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Controls Platform'))).removeStart('(')).removeEnd(')'));
                            }
                            toUpdate.add(updspec);
                            isexistspec=true;      
                        }
                        
                        if(!isexistspec){
                            if(!String.isBlank(checkNull)){
                                ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p1.Id);                                
                                newspec.ccrz__Spec__c=allspec.get('Controls Platform');
                                if(checkNull.length() > 255){
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Controls Platform'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                }
                                else{
                                    newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Controls Platform'))).removeStart('(')).removeEnd(')'));
                                }
                                toInsert.add(newspec);                                    
                            }
                        }                                        
                    }  
                    //
                    if(prod1.keyset().contains('Controls Platform')){
                        checkNull = (((String.valueOf(prod1.get('Controls Platform'))).removeStart('(')).removeEnd(')'));
                        if(!String.isBlank(checkNull)){
                            semivalues=checkNull.split('\\;');
                            for(String ele:semivalues){
                                ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p1.Id);
                                newcat.ccrz__Category__c = allcat.get(ele.toUpperCase()+'*CONTROLS PLATFORM');
                                toUpdatecat.add(newcat);
                            }
                            
                            ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p1.Id);
                            newcat1.ccrz__Category__c = allcat.get('CONTROLS PLATFORM');
                            toUpdatecat.add(newcat1);
                        }
                    } 
                    
                    
                    //////////////////////////////////////////////////////
                    if(prod1.keyset().contains('PH4 Configuration')){
                        tempCat=(((String.valueOf(prod1.get('PH4 Configuration'))).removeStart('(')).removeEnd(')'));
                            if(!String.isBlank(tempCat)){
                            system.debug('Test'+p1.ccrz__SKU__c);
                            ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p1.Id);
                            newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*CONFIGURATION');
                            toUpdatecat.add(newcat);    
                            
                            ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p1.Id);
                            newcat1.ccrz__Category__c = allcat.get('PH4 CONFIGURATION');
                            toUpdatecat.add(newcat1);    
                            }
                        }
                    
                    
                    System.debug('Checkpoint');
                    if(prod1.keyset().contains('PH5 Intelligence')){
                        tempCat=(((String.valueOf(prod1.get('PH5 Intelligence'))).removeStart('(')).removeEnd(')'));
                            if(!String.isBlank(tempCat)){
                            ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p1.Id);
                            newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*INTELLIGENCE');
                            toUpdatecat.add(newcat);
                            
                            ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p1.Id);
                            newcat1.ccrz__Category__c = allcat.get('PH5 INTELLIGENCE');
                            toUpdatecat.add(newcat1); 
                            }
                        }
                    
                    
                    if(prod1.keyset().contains('Product Images')){
                        
                        for(Object img :imagedata){
                            Map<String,Object> img1 = (Map<String,Object>)img;
                            if(String.valueOf(img1.get('Image Type'))=='Main Image'){  
                                ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p1.Id);
                                newmed.ccrz__MediaType__c='Product Image';
                                newmed.Image_type__c=String.valueOf(img1.get('Image Type'));
                                newmed.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
                                newmed.ccrz__ProductMediaSource__c='URI';
                                toInsertMed.add(newmed);
                                
                                ccrz__E_ProductMedia__c newmed1 = new ccrz__E_ProductMedia__c(ccrz__Product__c=p1.Id);
                                newmed1.ccrz__MediaType__c='Product Image Thumbnail';
                                newmed1.Image_type__c=String.valueOf(img1.get('Image Type'));
                                newmed1.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
                                newmed1.ccrz__ProductMediaSource__c='URI';
                                toInsertMed.add(newmed1);
                                
                                ccrz__E_ProductMedia__c newmed2 = new ccrz__E_ProductMedia__c(ccrz__Product__c=p1.Id);
                                newmed2.ccrz__MediaType__c='Product Search Image';
                                newmed2.Image_type__c=String.valueOf(img1.get('Image Type'));
                                newmed2.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
                                newmed2.ccrz__ProductMediaSource__c='URI';
                                toInsertMed.add(newmed2);
                                
                            }
                            
                            /* else{
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p3.Id);
newmed.ccrz__MediaType__c='Alternate Images';
newmed.Image_type__c=String.valueOf(img1.get('Image Type'));
newmed.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
newmed.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed);

ccrz__E_ProductMedia__c newmed1 = new ccrz__E_ProductMedia__c(ccrz__Product__c=p3.Id);
newmed1.ccrz__MediaType__c='Alternate Thumbnails';
newmed1.Image_type__c=String.valueOf(img1.get('Image Type'));
newmed1.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
newmed1.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed1);
}*/
                            
                        }
                        
                        
                        
                        
                        
                    }
                    System.debug('Checkpoint');
                    if(prod1.keyset().contains('Product Documents')){
                        for(Object doc :docData){
                            Map<String,Object> doc1 = (Map<String,Object>)doc;
                            if(doc1.get('Document Type') == 'Spec Sheet'){
                                ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p1.Id);
                                newmed.ccrz__MediaType__c='Spec Sheet';
                                newmed.ccrz__URI__c=String.valueOf(doc1.get('Document URL'));
                                newmed.ccrz__ProductMediaSource__c='URI';
                                if((((String.valueOf(doc1.get('Document Title'))).removeStart('(')).removeEnd(')')).length() > 60){
                                newmed.ccrz__ProductDescription__c=(((String.valueOf(doc1.get('Document Title'))).removeStart('(')).removeEnd(')')).substring(0,59);
                                }
                                else{
                                 newmed.ccrz__ProductDescription__c= String.valueOf(doc1.get('Document Title')); 
                                }
                                toInsertMed.add(newmed);
                            }
                        }
                        
                        
                    }
                    
                    
                    
                }
                
                
                
            }        
            
            System.debug('Checkpoint');
            prodmap.putall(toUpdateProd);
            if(prodmap.size()>0){
                update prodmap.values();
            } 
            //update toUpdateProd;
            update toUpdate;
            for(ccrz__E_ProductCategory__c  cat: toUpdatecat){
                system.debug(cat);
                if(cat.ccrz__Category__c != null){
                    insertCatsec.add(cat);
                }
            }
            Database.insert(insertCatsec);
            Database.insert(toInsert);
            // Database.insert(toInsertMed);
            //  update toUpdateMed;
            //update toUpdatecatex;
            
            toUpdateProd.clear();
            toUpdate.clear();
            toUpdatecat.clear();
            toInsert.clear(); 
            //toUpdatecatex.clear();
            // toInsertMed.clear();
            // toUpdateMed.clear(); 
            prodmap.clear();
            prodspecmap.clear();
            prodmedmap.clear();
            insertCatsec.clear();
            system.debug('***getCpuTime()***'+Limits.getCpuTime());
            
            
            if(familyHierJSON.size() !=0){
                transient List<ccrz__E_Product__c> prodoffamily = [Select id From ccrz__E_Product__c where  ccrz__SKU__c IN:scopeprod2 and GTM_Product_Family__c IN :familyHierJSON];
                //transient List<ccrz__E_Product__c> prodoffamilyimages1 = [Select id From ccrz__E_Product__c where  ccrz__SKU__c IN:scopeprod2 and ProductHierarchy__c IN :prodHierfamimages];
                //List<ccrz__E_ProductSpec__c> toDeleteSpecs = [Select id From ccrz__E_ProductSpec__c where ccrz__Product__c IN:prodoffamily and ccrz__Spec__c IN:semispecs];
                // Database.delete([Select id From ccrz__E_ProductSpec__c where ccrz__Product__c IN:prodoffamily and ccrz__Spec__c IN:semispecs]);
                Database.delete([Select id From ccrz__E_ProductCategory__c where ccrz__Product__c IN:prodoffamily and ccrz__Category__c IN:semicats]);
                // Database.delete([Select id From ccrz__E_ProductMedia__c where ccrz__Product__c IN:prodoffamily and ccrz__MediaType__c IN ('Family Features & Benefits Bullets','Alternate Images','Alternate Thumbnails','Spec Sheet')]);
                //Database.delete([Select id From ccrz__E_ProductMedia__c where ccrz__Product__c IN:prodoffamily and ccrz__MediaType__c IN ('Alternate Images','Alternate Thumbnails','Spec Sheet')]);
                
                //Database.delete([Select id From ccrz__E_ProductMedia__c where ccrz__Product__c IN:prodoffamilyimages1 and ccrz__MediaType__c IN ('Product Search Image','Product Image Thumbnail','Product Image')]);
               // Database.delete([Select id From ccrz__E_RelatedProduct__c where ccrz__Product__c IN:prodoffamily]);
                Database.delete([Select id From ccrz__E_ProductTab__c where ccrz__Product__c IN:prodoffamily]);
            } 
            
            System.debug('Checkpoint');
			System.debug(aFamily.size());       
            for (Object prod: aFamily) {
                
                //system.debug(prod);
                prod1 = (Map<String, Object>)prod;
                System.debug(prod1.get('Family'));
                checkProdHier='';
                //system.debug(prod1.get('Product Images'));
                /* if(prod1.keyset().contains('Product Images')){
imagedata = (List<Object>)JSON.deserializeUntyped('['+(((String.valueOf(prod1.get('Product Images'))).removeStart('(')).removeEnd(')'))+']');
}

if(prod1.keyset().contains('Product Documents')){
docData = (List<Object>)JSON.deserializeUntyped('['+(((String.valueOf(prod1.get('Product Documents'))).removeStart('(')).removeEnd(')'))+']');
//system.debug(prod1.get('imagedata'));
}*/
                System.debug('Checkpoint');
                if(prod1.get('GTM Family ID') != Null){
                	checkProdHier = (((String.valueOf(prod1.get('GTM Family ID'))).removeStart('(')).removeEnd(')'));
                }
                   checkProdHier=(checkProdHier.replaceAll(' ', ''));
                    System.debug('Checkpoint');
                if(!String.isBlank(checkProdHier)){
                    System.debug('Checkpoint');

                   // prodHier=checkProdHier.split('\\;');
                   // for(String eleHier:prodHier){
                        // system.debug('Data');
                        // for (String key: prod1.keyset()){
                        //  if (prod1.keyset().contains('salsify:data_inheritance_hierarchy_level_id')){
                        // if (key=='salsify:data_inheritance_hierarchy_level_id'){
                        //    if(prod1.get('salsify:data_inheritance_hierarchy_level_id')=='Family'){ 
                        System.debug('Checkpoint'+prodaftupd.size());
                    for(ccrz__E_Product__c p2 : prodaftupd){
                            //system.debug(p2.ccrz__SKU__c);
                            //system.debug(p2.MaterialDescription__c);
                            //system.debug(((String.valueOf(prod1.get('Family'))).removeStart('(')).removeEnd(')'));
                            //system.debug((((String.valueOf(prod1.get('Disinfection Product'))).removeStart('(')).removeEnd(')')));
                            //if((String.valueOf(p2.MaterialDescription__c)).startsWith(((String.valueOf(prod1.get('Family'))).removeStart('(')).removeEnd(')'))){
                            gtmfam = p2.GTM_Product_Family__c;
                                If(gtmfam != Null){
 								  gtmfam=(gtmfam.replaceAll(' ', ''));  
                                }  
                           System.debug('Checkpoint'+gtmfam);
                           System.debug('Checkpoint1'+checkProdHier);

                                if(!String.isBlank(gtmfam)){
                            if(gtmfam==checkProdHier){
                                //system.debug('Data');
                                if(prod1.get('Product Description Short') != Null){
                                	p2.ccrz__SEOKeywords__c = (((String.valueOf(prod1.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                                	p2.Product_Family__c = (((String.valueOf(prod1.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                                	p2.CatalogLogic__c=(((String.valueOf(prod1.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                                }
                                //system.debug(p2); 
                                
                                // p2.ccrz__ShortDescRT__c = String.valueOf(prod1.get('Product Description Short'));  
                                //p2.ccrz__LongDescRT__c = String.valueOf(prod1.get('Product Description Long'));
                                
                                if(prod1.get('Product Description Short') != Null){
                                    p2.ccrz__ShortDescRT__c = (((String.valueOf(prod1.get('Product Description Short'))).removeStart('(')).removeEnd(')'));
                                }
                                if(prod1.get('Product Description Long') != Null){
                                    p2.ccrz__LongDescRT__c = (((String.valueOf(prod1.get('Product Description Long'))).removeStart('(')).removeEnd(')'));
                                }
                              //  p2.CatalogLogic__c=(((String.valueOf(prod1.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                                    if(prod1.keyset().contains('Disinfection Product')){                                
                                    if ((((String.valueOf(prod1.get('Disinfection Product'))).removeStart('(')).removeEnd(')')) != Null){
                                    //  system.debug((((String.valueOf(prod1.get('Disinfection Product'))).removeStart('(')).removeEnd(')')));
                                    p2.DisinfectionProduct__c = Boolean.valueOf(((((String.valueOf(prod1.get('Disinfection Product'))).removeStart('(')).removeEnd(')')))); 
                                }
                                 }
                                
                                if(prod1.keyset().contains('Estimated Lead Time')){
                                    if ((((String.valueOf(prod1.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')')) != Null){
                                        p2.ECommItemName__c = (((String.valueOf(prod1.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')'));
                                    }
                                    }
                                toUpdateProd.add(p2);
                                
                                
                                /* isexistspec=false;
if(prod1.keyset().contains('UL Type')){
// checkNull = (((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank((((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')')))){                                   
if(bMap.keyset().contains(p2.ccrz__SKU__c+'UL Type A,B,C')) {
//system.debug('Data');
checkNull = (((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')'));
updspec = bMap.get(p2.ccrz__SKU__c+'UL Type A,B,C');
//updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')'));
}
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
checkNull = (((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')'));
//system.debug('Data');
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('UL Type A,B,C');
//newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('UL Type'))).removeStart('(')).removeEnd(')'));
}
toInsert.add(newspec);


}
}
}*/
                                /*
isexistspec=false;
if(prod1.keyset().contains('Bulb Base Type')){
if(bMap.keyset().contains(p2.ccrz__SKU__c+'Bulb Base Type')) {

updspec = bMap.get(p2.ccrz__SKU__c+'Bulb Base Type');
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Bulb Base Type'))).removeStart('(')).removeEnd(')'));
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Bulb Base Type');
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Bulb Base Type'))).removeStart('(')).removeEnd(')'));
toInsert.add(newspec);


}
}
isexistspec=false;
if(prod1.keyset().contains('Bulb Shape')){
if(bMap.keyset().contains(p2.ccrz__SKU__c+'Bulb Shape')) {

updspec = bMap.get(p2.ccrz__SKU__c+'Bulb Shape');
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Bulb Shape'))).removeStart('(')).removeEnd(')'));
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Bulb Shape');
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Bulb Shape'))).removeStart('(')).removeEnd(')'));
toInsert.add(newspec);


}
} 
*/
                                //Estimated Lead Time
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Estimated Lead Time')){
                                    checkNull = (((String.valueOf(prod1.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Lead Time')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Lead Time');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Estimated Lead Time');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Estimated Lead Time'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                
                                
                                
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Operating Life (Hrs)')){
                                    checkNull = (((String.valueOf(prod1.get('Operating Life (Hrs)'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Operating Life (Hrs)')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Operating Life (Hrs)');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Operating Life (Hrs)'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Operating Life (Hrs)'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Operating Life (Hrs)');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Operating Life (Hrs)'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Operating Life (Hrs)'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                }           
                                
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Effective Projected Area')){
                                    checkNull = (((String.valueOf(prod1.get('Effective Projected Area'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Effective Projected Area (EPA)')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Effective Projected Area (EPA)');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Effective Projected Area'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Effective Projected Area'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Effective Projected Area (EPA)');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Effective Projected Area'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Effective Projected Area'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                }          
                                /*  isexistspec=false;
if(prod1.keyset().contains('Paint/Finish Description')){
//  checkNull = (((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank((((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')')))){  
if(bMap.keyset().contains(p2.ccrz__SKU__c+'Paint/Finish Description')) {
checkNull = (((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
updspec = bMap.get(p2.ccrz__SKU__c+'Paint/Finish Description');
// updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
}
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
checkNull = (((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Paint/Finish Description');
// newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Paint/Finish Description'))).removeStart('(')).removeEnd(')'));
}
toInsert.add(newspec);


}
}     
} */
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Operating Temp range')){
                                    checkNull = (((String.valueOf(prod1.get('Operating Temp range'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Operating Temp Range (°C)')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Operating Temp Range (°C)');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Operating Temp range'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Operating Temp range'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Operating Temp Range (°C)');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Operating Temp range'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Operating Temp range'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                }  
                                System.debug('Checkpoint');
                                /////////////////////////////////////////////////////////
                                
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('PH1 Product Line')){
                                    checkNull = (((String.valueOf(prod1.get('PH1 Product Line'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'PH1 Product Line')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'PH1 Product Line');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('PH1 Product Line'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('PH1 Product Line'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('PH1 Product Line');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('PH1 Product Line'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('PH1 Product Line'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                
                                
                                System.debug('Checkpoint');
                                /////
                                isexistspec=False;
                                if(prod1.keyset().contains('PH2 Application')){
                                    checkNull = (((String.valueOf(prod1.get('PH2 Application'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'PH2 Application')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'PH2 Application');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('PH2 Application'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('PH2 Application'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('PH2 Application');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('PH2 Application'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('PH2 Application'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                
                                /////
                                
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('PH3 Family')){
                                    checkNull = (((String.valueOf(prod1.get('PH3 Family'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'PH3 Family')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'PH3 Family');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('PH3 Family'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('PH3 Family'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('PH3 Family');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('PH3 Family'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('PH3 Family'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                ////
                                /*   System.debug('Checkpoint');
isexistspec=false;
if(prod1.keyset().contains('Housing Description')){
checkNull = (((String.valueOf(prod1.get('Housing Description'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){                                      
if(bMap.keyset().contains(p2.ccrz__SKU__c+'Housing Description')) {

updspec = bMap.get(p2.ccrz__SKU__c+'Housing Description');
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Housing Description'))).removeStart('(')).removeEnd(')'));
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Housing Description');
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Housing Description'))).removeStart('(')).removeEnd(')'));
toInsert.add(newspec);


}
}
}*/
                                
                                
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Housing Description')){
                                    checkNull = (((String.valueOf(prod1.get('Housing Description'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Housing Description')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Housing Description');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Housing Description'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Housing Description'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Housing Description');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Housing Description'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Housing Description'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                
                                
                                
                                
                                
                                ////
                                /* isexistspec=false;
if(prod1.keyset().contains('Lensing Description')){
if(bMap.keyset().contains(p2.ccrz__SKU__c+'Lensing Description')) {

updspec = bMap.get(p2.ccrz__SKU__c+'Lensing Description');
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Lensing Description'))).removeStart('(')).removeEnd(')'));
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Lensing Description');
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Lensing Description'))).removeStart('(')).removeEnd(')'));
toInsert.add(newspec);


}
} 
*/ 
                                //
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Warranty')){
                                    checkNull = (((String.valueOf(prod1.get('Warranty'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Warranty')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Warranty');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Warranty'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Warranty'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Warranty');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Warranty'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Warranty'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                
                                ///
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Brand')){
                                    checkNull = (((String.valueOf(prod1.get('Brand'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Brand')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Brand');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Brand'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Brand'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Brand');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Brand'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Brand'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                //
                                
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Family Applications')){
                                    checkNull = (((String.valueOf(prod1.get('Family Applications'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Family Applications')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Family Applications');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Family Applications'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Family Applications'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Family Applications');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Family Applications'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Family Applications'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Product Category')){
                                    checkNull = (((String.valueOf(prod1.get('Product Category'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Product Category')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Product Category');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Product Category'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Product Category'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Product Category');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Product Category'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Product Category'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                
                                
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Product Subcategory')){
                                    checkNull = (((String.valueOf(prod1.get('Product Subcategory'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Product Subcategory')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Product Subcategory');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Product Subcategory'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Product Subcategory'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Product Subcategory');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Product Subcategory'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Product Subcategory'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                
                                System.debug('Checkpoint');
                                //////////////////////////////////////////////////////////
                                /*
if(prod1.keyset().contains('Associated Parts')){
checkNull = (((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Associated Parts');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

}*/
                                
                                /*isexistspec=false;
if(prod1.keyset().contains('Associated Parts')){
// checkNull = (((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank((((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')')))){                                      
if(bMap.keyset().contains(p2.ccrz__SKU__c+'Associated Parts')) {
checkNull = (((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
updspec = bMap.get(p2.ccrz__SKU__c+'Associated Parts');
// updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
}
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
checkNull = (((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Associated Parts');
//newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
}
toInsert.add(newspec);


}
}
} 
*/
                            /*    if(prod1.keyset().contains('Associated Parts')){
                                    checkNull = (((String.valueOf(prod1.get('Associated Parts'))).removeStart('(')).removeEnd(')'));
                                    if(!String.isBlank(checkNull)){
                                        semivalues=checkNull.split('\\;');
                                        for(String ele:semivalues){
                                            ccrz__E_RelatedProduct__c relaProd = new ccrz__E_RelatedProduct__c();
                                            relaProd.ccrz__ShortDesc__c = 'Related Parts';
                                            relaProd.ccrz__RelatedProduct__c = String.valueOf(existrelaprod.get(ele));
                                            relaProd.ccrz__RelatedProductType__c ='Related';
                                            relaProd.ccrz__Product__c = p2.id;
                                            toInsertRelProd.add(relaProd);
                                            
                                            
                                        }  
                                    }
                                }
                                
                               */ 
                                System.debug('Checkpoint');
                                
                                /*
if(prod1.keyset().contains('Technology Enabled')){
checkNull = (((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Technology Enabled');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} 

*/
                                /* 
if(prod1.keyset().contains('Programs')){
checkNull = (((String.valueOf(prod1.get('Programs'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Programs');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} 
*/
                                
                                /* 
if(prod1.keyset().contains('Material')){
checkNull = (((String.valueOf(prod1.get('Material'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Material');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} 



if(prod1.keyset().contains('Environmental Conditions')){
checkNull = (((String.valueOf(prod1.get('Environmental Conditions'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Environmental Conditions');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} 


*/
                                /*  
if(prod1.keyset().contains('Regulatory')){
checkNull = (((String.valueOf(prod1.get('Regulatory'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Regulatory');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} 
*/ 
                                /*  if(prod1.keyset().contains('Regulatory')){
checkNull = (((String.valueOf(prod1.get('Regulatory'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
//  semivalues=checkNull.split('\\;');
//  for(String ele:checkNull){
ccrz__E_ProductTab__c prodtab = new ccrz__E_ProductTab__c();
prodtab.ccrz__Product__c = p2.id;
prodtab.ccrz__Tab__c = 'Resources';
prodtab.ccrz__ContentRT__c = String.valueOf(checkNull);
prodtab.ccrz__Locale__c = 'en_US';
toInsertProdTab.add(prodtab);
}
}*/
                                System.debug('Checkpoint');
                                /* 
if(prod1.keyset().contains('Certifications')){
checkNull = (((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Certifications');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} 
*/ 
                                ///////////////////////////////////////////////// 
                                /*  isexistspec=false;
if(prod1.keyset().contains('Certifications')){
//checkNull = (((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank((((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')')))){                                      
if(bMap.keyset().contains(p2.ccrz__SKU__c+'Certifications')) {
checkNull = (((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')'));
updspec = bMap.get(p2.ccrz__SKU__c+'Certifications');
//updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')'));
}
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
checkNull = (((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')'));
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Certifications');
// newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Certifications'))).removeStart('(')).removeEnd(')'));
}
toInsert.add(newspec);


}
}
} 
/////////
isexistspec=false;
if(prod1.keyset().contains('Technology Enabled')){
//  checkNull = (((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank((((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')')))){                                      
if(bMap.keyset().contains(p2.ccrz__SKU__c+'Technology Enabled')) {
checkNull = (((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
updspec = bMap.get(p2.ccrz__SKU__c+'Technology Enabled');
//updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
}
toUpdate.add(updspec);
isexistspec=true;

}
if(!isexistspec){
checkNull = (((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Technology Enabled');
// newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
if(checkNull.length() > 255){
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')')).substring(0,250);
}
else{
newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Technology Enabled'))).removeStart('(')).removeEnd(')'));
}
toInsert.add(newspec);


}
}
} */
                                ///
                                
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Material')){
                                    checkNull = (((String.valueOf(prod1.get('Material'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Material')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Material');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Material'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Material'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Material');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Material'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Material'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                //
                                
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Environmental Conditions')){
                                    checkNull = (((String.valueOf(prod1.get('Environmental Conditions'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Environmental Conditions')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Environmental Conditions');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Environmental Conditions'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Environmental Conditions'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Environmental Conditions');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Environmental Conditions'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Environmental Conditions'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                ////////////////////////////////////////////////////
                                /*
if(prod1.keyset().contains('Product Shape')){
checkNull = (((String.valueOf(prod1.get('Product Shape'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);
newspec.ccrz__Spec__c=allspec.get('Product Shape');
newspec.ccrz__SpecValue__c=String.valueOf(ele);
toInsert.add(newspec);
}
}

} */
                                
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Product Shape')){
                                    checkNull = (((String.valueOf(prod1.get('Product Shape'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Product Shape')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Product Shape');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Product Shape'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Product Shape'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Product Shape');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Product Shape'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Product Shape'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                /*

isexistcat=false;
if(prod1.keyset().contains('Country of Origin')){
tempCat=(((String.valueOf(prod1.get('Country of Origin'))).removeStart('(')).removeEnd(')'));
if(dMap.keyset().contains(p2.ccrz__SKU__c+tempCat.toUpperCase()+'*COUNTRY-OF-ORIGIN')) {

isexistcat=true;

}

if(!isexistcat){
ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*COUNTRY-OF-ORIGIN');
toUpdatecat.add(newcat);

ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
newcat1.ccrz__Category__c = allcat.get('COUNTRY-OF-ORIGIN');
toUpdatecat.add(newcat1);

}
}
*/
                                
                                
                                if(prod1.keyset().contains('PH1 Product Line')){
                                    tempCat=(((String.valueOf(prod1.get('PH1 Product Line'))).removeStart('(')).removeEnd(')'));
                           				if(!String.isBlank(tempCat)){
                                        ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                        newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*PH1 PRODUCT LINE');
                                        toUpdatecat.add(newcat);
                                        
                                        ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                        newcat1.ccrz__Category__c = allcat.get('PH1 PRODUCT LINE');
                                        toUpdatecat.add(newcat1);
                                        }
                                    }
                                
                                
                                if(prod1.keyset().contains('PH2 Application')){
                                    tempCat=(((String.valueOf(prod1.get('PH2 Application'))).removeStart('(')).removeEnd(')'));
                           				if(!String.isBlank(tempCat)){
                                        ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                        newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*PH2 APPLICATION');
                                        toUpdatecat.add(newcat);
                                        
                                        ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                        newcat1.ccrz__Category__c = allcat.get('PH2 APPLICATION');
                                        toUpdatecat.add(newcat1);
                                        } 
                                    }
                                
                                
                                
                                isexistcat=false;
                                if(prod1.keyset().contains('PH3 Family')){
                                    tempCat=(((String.valueOf(prod1.get('PH3 Family'))).removeStart('(')).removeEnd(')'));
                           				if(!String.isBlank(tempCat)){
                                        ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                        newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*PH3 FAMILY');
                                        toUpdatecat.add(newcat);
                                        
                                        ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                        newcat1.ccrz__Category__c = allcat.get('PH3 FAMILY');
                                        toUpdatecat.add(newcat1);
                                        }
                                    }
                                
                                
                                //////////////////////////////////////////////////////////////////////
                                isexistcat=false;
                                if(prod1.keyset().contains('Catalog Logic')){
                                    tempCat=(((String.valueOf(prod1.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                           				if(!String.isBlank(tempCat)){
                                        ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                        newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*FAMILY');
                                        toUpdatecat.add(newcat);
                                        
                                        ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                        newcat1.ccrz__Category__c = allcat.get('FAMILY');
                                        toUpdatecat.add(newcat1);
                                        }
                                    }
                                
                                
                                ///
                                
                                System.debug('Checkpoint');
                                isexistspec=False;
                                if(prod1.keyset().contains('Catalog Logic')){
                                    checkNull = (((String.valueOf(prod1.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));                        
                                    if(bMap.keyset().contains(p2.ccrz__SKU__c+'Product Family')) {
                                        updspec = bMap.get(p2.ccrz__SKU__c+'Product Family');
                                        if(checkNull.length() > 255){
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Catalog Logic'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                        }
                                        else{
                                            updspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                                        }
                                        toUpdate.add(updspec);
                                        isexistspec=true;      
                                    }
                                    
                                    if(!isexistspec){
                                        if(!String.isBlank(checkNull)){
                                            ccrz__E_ProductSpec__c newspec = new ccrz__E_ProductSpec__c(ccrz__Product__c=p2.Id);                                
                                            newspec.ccrz__Spec__c=allspec.get('Product Family');
                                            if(checkNull.length() > 255){
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Catalog Logic'))).removeStart('(')).removeEnd(')')).substring(0,250);
                                            }
                                            else{
                                                newspec.ccrz__SpecValue__c=(((String.valueOf(prod1.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                                            }
                                            toInsert.add(newspec);                                    
                                        }
                                    }                                        
                                } 
                                //////
                                /*  isexistcat=false;
if(prod1.keyset().contains('Programs')){
tempCat=(((String.valueOf(prod1.get('Programs'))).removeStart('(')).removeEnd(')'));
if(dMap.keyset().contains(p2.ccrz__SKU__c+tempCat.toUpperCase()+'*Programs')) {

isexistcat=true;

}
if(!isexistcat){
ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*Programs');
toUpdatecat.add(newcat);

ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
newcat1.ccrz__Category__c = allcat.get('Programs');
toUpdatecat.add(newcat1);

}
}
*/
                                ////////////////////////////////////////////////////////////////////
                                
                                
                                if(prod1.keyset().contains('Brand')){
                                    tempCat=(((String.valueOf(prod1.get('Brand'))).removeStart('(')).removeEnd(')'));
                           				if(!String.isBlank(tempCat)){
                                        ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                        newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*BRAND');
                                        toUpdatecat.add(newcat);
                                        
                                        ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                        newcat1.ccrz__Category__c = allcat.get('BRAND');
                                        toUpdatecat.add(newcat1);
                                        }
                                    }
                                
                                
                                
                                
                                
                                if(prod1.keyset().contains('Family Applications')){
                                    checkNull = (((String.valueOf(prod1.get('Family Applications'))).removeStart('(')).removeEnd(')'));
                                    if(!String.isBlank(checkNull)){
                                        semivalues=checkNull.split('\\;');
                                        for(String ele:semivalues){
                                            ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                            newcat.ccrz__Category__c = allcat.get(ele.toUpperCase()+'*FAMILY APPLICATIONS');
                                            toUpdatecat.add(newcat);
                                        }
                                        
                                        ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                        newcat1.ccrz__Category__c = allcat.get('FAMILY Applications');
                                        toUpdatecat.add(newcat1);
                                    }
                                } 
                                System.debug('Checkpoint');
                                /*  
isexistcat=false;
if(prod1.keyset().contains('Family Applications')){
tempCat=(((String.valueOf(prod1.get('Family Applications'))).removeStart('(')).removeEnd(')'));
if(dMap.keyset().contains(p2.ccrz__SKU__c+tempCat.toUpperCase()+'*Family Applications')) {

isexistcat=true;

}
if(!isexistcat){
ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
newcat.ccrz__Category__c = allcat.get(tempCat.toUpperCase()+'*Family Applications');
toUpdatecat.add(newcat);

ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
newcat1.ccrz__Category__c = allcat.get('Family Applications');
toUpdatecat.add(newcat1);

}
}*/
                                
                                
                                
                                /*if(prod1.keyset().contains('Product Category')){
checkNull = (((String.valueOf(prod1.get('Product Category'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
newcat.ccrz__Category__c = allcat.get('PRODUCT CATEGORY');
newcat.CategoryValue__c=String.valueOf(ele);
toUpdatecat.add(newcat);
}
}
}*/ 
                                
                                if(prod1.keyset().contains('Product Category')){
                                    checkNull = (((String.valueOf(prod1.get('Product Category'))).removeStart('(')).removeEnd(')'));
                                    if(!String.isBlank(checkNull)){
                                        semivalues=checkNull.split('\\;');
                                        if(prod1.keyset().contains('Product Subcategory')){
                                            checkNull2 = (((String.valueOf(prod1.get('Product Subcategory'))).removeStart('(')).removeEnd(')'));
                                            if(!String.isBlank(checkNull2)){
                                                semivalues2=checkNull2.split('\\;');
                                                for(String ele:semivalues){
                                                    for(String ele2:semivalues2){
                                                        ccrz__E_ProductCategory__c newcat = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                                        newcat.ccrz__Category__c = allcat.get(ele2.toUpperCase()+'*'+ele.toUpperCase().replaceAll( '\\s+', ''));
                                                        toUpdatecat.add(newcat);
                                                    }
                                                    ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
                                                    newcat1.ccrz__Category__c = allcat.get(ele.toUpperCase().replaceAll( '\\s+', ''));
                                                    toUpdatecat.add(newcat1); 
                                                    
                                                }
                                                
                                                /* if(!dMap.keyset().contains(p2.ccrz__SKU__c+'PRODUCTS')) {
ccrz__E_ProductCategory__c newcat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c=p2.Id);
newcat1.ccrz__Category__c = allcat.get('PRODUCTS');
toUpdatecat.add(newcat1);
}*/
                                                
                                            }
                                        } 
                                    }
                                }
                                
                                
                                
                                
                                System.debug('Checkpoint');
                                /* 
if(prod1.keyset().contains('Family Features & Benefits Bullets')){
checkNull = (((String.valueOf(prod1.get('Family Features & Benefits Bullets'))).removeStart('(')).removeEnd(')'));
if(!String.isBlank(checkNull)){
semivalues=checkNull.split('\\;');
for(String ele:semivalues){
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p2.Id);
newmed.ccrz__MediaType__c='Family Features & Benefits Bullets';
newmed.ccrz__ProductDescription__c=String.valueOf(ele);
newmed.ccrz__ProductMediaSource__c='URI';
if(prod1.keyset().contains('Website Link')){
newmed.ccrz__URI__c = (((String.valueOf(prod1.get('Website Link'))).removeStart('(')).removeEnd(')')); 
}

toInsertMed.add(newmed);
}
}
} */
                                
                                
                                /*
isexistmed=false;
if(prod1.keyset().contains('Warranty')){
if(fMap.keyset().contains(p2.ccrz__SKU__c+'Warranty')) {

updmed = fMap.get(p2.ccrz__SKU__c+'Warranty');
updmed.ccrz__ProductDescription__c=(((String.valueOf(prod1.get('Warranty'))).removeStart('(')).removeEnd(')'));
toUpdateMed.add(updmed);
isexistmed=true;

}
if(!isexistmed){
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p2.Id);

newmed.ccrz__MediaType__c='Warranty';
newmed.ccrz__ProductDescription__c=(((String.valueOf(prod1.get('Warranty'))).removeStart('(')).removeEnd(')'));
toInsertMed.add(newmed);


}
} 
*/
                                System.debug('Checkpoint');
                                isexistmed=false;
                                if(prod1.keyset().contains('Website Link')){
                                    if(fMap.keyset().contains(p2.ccrz__SKU__c+'Website URL')) {
                                        
                                        updmed = fMap.get(p2.ccrz__SKU__c+'Website URL');
                                        updmed.ccrz__ProductMediaSource__c='URI';
                                        updmed.ccrz__URI__c = (((String.valueOf(prod1.get('Website Link'))).removeStart('(')).removeEnd(')'));
                                        toUpdateMed.add(updmed);
                                        isexistmed=true;
                                        
                                    }
                                    if(!isexistmed){
                                        ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p2.Id);
                                        
                                        newmed.ccrz__MediaType__c='Website URL';
                                        newmed.ccrz__ProductMediaSource__c='URI';
                                        newmed.ccrz__URI__c = (((String.valueOf(prod1.get('Website Link'))).removeStart('(')).removeEnd(')'));
                                        toInsertMed.add(newmed);
                                        
                                        
                                    }
                                } 
                                /*
isexistmed=false;
if(prod1.keyset().contains('Lensing Description')){
if(fMap.keyset().contains(p2.ccrz__SKU__c+'Lensing Description')) {

updmed = fMap.get(p2.ccrz__SKU__c+'Lensing Description');
updmed.ccrz__ProductDescription__c=(((String.valueOf(prod1.get('Lensing Description'))).removeStart('(')).removeEnd(')'));
toUpdateMed.add(updmed);
isexistmed=true;

}
if(!isexistmed){
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p2.Id);

newmed.ccrz__MediaType__c='Lensing Description';
newmed.ccrz__ProductDescription__c=(((String.valueOf(prod1.get('Lensing Description'))).removeStart('(')).removeEnd(')'));
toInsertMed.add(newmed);


}
} 
*/
                                /*        isexistmed=false;
if(prod1.keyset().contains('Housing Description')){
if(fMap.keyset().contains(p2.ccrz__SKU__c+'Housing Description')) {

updmed = fMap.get(p2.ccrz__SKU__c+'Housing Description');
updmed.ccrz__ProductDescription__c=(((String.valueOf(prod1.get('Housing Description'))).removeStart('(')).removeEnd(')'));
toUpdateMed.add(updmed);
isexistmed=true;

}
if(!isexistmed){
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p2.Id);

newmed.ccrz__MediaType__c='Housing Description';
newmed.ccrz__ProductDescription__c=(((String.valueOf(prod1.get('Housing Description'))).removeStart('(')).removeEnd(')'));
toInsertMed.add(newmed);


}
}  
*/
                                /* if(prod1.keyset().contains('Product Images')){

for(Object img :imagedata){

Map<String,Object> img1 = (Map<String,Object>)img;
if(String.valueOf(img1.get('Image Type'))=='Main Image'){
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p2.Id);
newmed.ccrz__MediaType__c='Product Image';
newmed.Image_type__c=String.valueOf(img1.get('Image Type'));
newmed.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
newmed.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed);

ccrz__E_ProductMedia__c newmed1 = new ccrz__E_ProductMedia__c(ccrz__Product__c=p2.Id);
newmed1.ccrz__MediaType__c='Product Image Thumbnail';
newmed1.Image_type__c=String.valueOf(img1.get('Image Type'));
newmed1.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
newmed1.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed1);

ccrz__E_ProductMedia__c newmed2 = new ccrz__E_ProductMedia__c(ccrz__Product__c=p2.Id);
newmed2.ccrz__MediaType__c='Product Search Image';
newmed2.Image_type__c=String.valueOf(img1.get('Image Type'));
newmed2.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
newmed2.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed2);

}

else{
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p2.Id);
newmed.ccrz__MediaType__c='Alternate Images';
newmed.Image_type__c=String.valueOf(img1.get('Image Type'));
newmed.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
newmed.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed);

ccrz__E_ProductMedia__c newmed1 = new ccrz__E_ProductMedia__c(ccrz__Product__c=p2.Id);
newmed1.ccrz__MediaType__c='Alternate Thumbnails';
newmed1.Image_type__c=String.valueOf(img1.get('Image Type'));
newmed1.ccrz__URI__c=String.valueOf(img1.get('Image URL'));
newmed1.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed1);
}
}
}

if(prod1.keyset().contains('Product Documents')){
for(Object doc :docData){
Map<String,Object> doc1 = (Map<String,Object>)doc;
if(doc1.get('Document Type') == 'Spec Sheet'){
ccrz__E_ProductMedia__c newmed = new ccrz__E_ProductMedia__c(ccrz__Product__c=p2.Id);
newmed.ccrz__MediaType__c='Spec Sheet';
newmed.ccrz__URI__c=String.valueOf(doc1.get('Document URL'));
newmed.ccrz__ProductMediaSource__c='URI';
toInsertMed.add(newmed);
}
}


}
*/
                            }
                        }
                        }
                        
                        
                 //   }
                }
                
            }
            System.debug('Checkpoint');
            prodmap.putall(toUpdateProd);
            if(prodmap.size()>0){
                update prodmap.values();
            }            
            //update toUpdateProd;
            prodspecmap.putall(toUpdate);
            if(prodspecmap.size()>0){
                update prodspecmap.values();
            }
            //update toUpdate;
            for(ccrz__E_ProductCategory__c  cat: toUpdatecat){
                system.debug(cat);
                if(cat.ccrz__Category__c != null){
                    insertCatsec.add(cat);
                }
            }
            Database.insert(insertCatsec);
            Database.insert(toInsert);
            Database.insert(toInsertMed);
            Database.insert(toInsertRelProd);
            Database.insert(toInsertProdTab);
            prodmedmap.putall(toUpdateMed);
            if(prodmedmap.size()>0){
                update prodmedmap.values();
            }
            
            //update toUpdateMed;
            //update toUpdatecatex;
            toInsertProdTab.clear();
            toUpdateProd.clear();
            toUpdate.clear();
            toUpdatecat.clear();
            toInsert.clear();    
            toInsertMed.clear();
            toUpdateMed.clear();  
            //toUpdatecatex.clear();
            prodmap.clear();
            prodspecmap.clear();
            prodmedmap.clear(); 
            toInsertRelProd.clear();
            insertCatsec.clear();
            system.debug('***getCpuTime()***'+Limits.getCpuTime());
            system.debug('***getHeapSize()***'+Limits.getHeapSize());
            
            
            // CR changes by Sagar...
            // delete logic
             Database.delete([Select id From ccrz__E_ProductSpec__c where ccrz__Product__r.ccrz__ProductStatus__c='Released' and ( ccrz__SpecValue__c='' or ccrz__SpecValue__c=' ')]);
            //ccrz__SpecValue__c='N/A' or
        }
        catch (Exception e) {
            batchesFailed=batchesFailed+1;
            messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] {'salsify.support@gecurrent.com'};
           // message.toAddresses = new String[] {'sagar.suryawanshi@gecurrent.com'};
 
            message.optOutPolicy = 'FILTER';
            message.subject = 'Salsify Inetgration Individual Batch Execution Status:: Batch Failed!!!';
            message.plainTextBody = 'The following exception has occurred for current batch:' + e.getMessage();
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] result1 = Messaging.sendEmail(messages);
           system.debug('Error'+e.getMessage()); 
        }
        
    }
    public void finish(Database.BatchableContext bc){
        system.debug('***getHeapSize()***'+Limits.getHeapSize());    
        
        List<ccrz__E_Product__c> totalProducts = [Select ccrz__SKU__c From ccrz__E_Product__c];
        Set<String> totalExistSku = new Set<String>();
        Set<String> jsonSku = new Set<String>();
        
        for(ccrz__E_Product__c p :totalProducts){
            totalExistSku.add(p.ccrz__SKU__c);
        }
        
        transient Map<String, Object> prod1;
        for (Object prod: aSKU) {
            prod1 = (Map<String, Object>)prod;
            
            jsonSku.add(((String.valueOf(prod1.get('SKU'))).removeStart('(')).removeEnd(')'));
        }
        
        jsonSku.removeAll(totalExistSku);
        
        
        String finalstr='\n';
        for(String t1 : jsonSku){
            
            finalstr = finalstr +t1+'\n';
            
        }
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:bc.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        //'ravi.singh@gecurrent.com',
        message.toAddresses = new String[] {'salsify.support@gecurrent.com'};
      //  message.toAddresses = new String[] {'sagar.suryawanshi@gecurrent.com'};
        message.optOutPolicy = 'FILTER';
        message.subject = 'Salsify Inetgration Batch Execution Status: ' + a.Status;
        message.plainTextBody = 'The batch Apex job processed ' + a.TotalJobItems + ' batch(es) with '+ batchesFailed + ' batch(es) failures.\nPlease find attached list of '+jsonSku.size() +' SKU(s) which are not available in Salesforce.\n'+'This execution is for file: '+fileName;
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('SKU_Logs.txt');
        efa.setBody(Blob.valueOf(finalstr));
        message.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] result1 = Messaging.sendEmail(messages);
        system.debug(result1);
        
        /*if(!Test.isRunningTest()){
CCIndexing.CCADminTask(); 
}*/
        
        
    }
}