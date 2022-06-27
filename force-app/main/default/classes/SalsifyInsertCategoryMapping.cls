public class SalsifyInsertCategoryMapping {
    @future(callout=true)
    Public static void CategoryMapping(id newAttach){
        
        try{
            Attachment at = [select id,body,name from Attachment where id =:newAttach order by createddate desc LIMIT 1] ;
            String fName=at.name;
            String jsonInput = at.body.toString();
            at=null;
            jsonInput='{"TEST":'+jsonInput+'}';
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
            jsonInput=Null;
            
            //system.debug(results.get('TEST'));
            List<Object> wholejson =  (List<Object>)results.get('TEST');
            results=Null;
            List<Object> aSKU = new List<Object>();
            List<Object> aFamily = new List<Object>(); 
            Map<String, Object> prod1;
            Map<String, Object> a11;
            List<Object> a;
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
            wholejson=Null;
            a11=Null;
            a=Null;
            Set<String> ph4Config= new Set<String>();
            Set<String> ph5Intel= new Set<String>();
            Set<String> programs= new Set<String>();
            Set<String> controls= new Set<String>();
            List<String> semivalues= new List<String>();
            List<String> semivaluescontrols= new List<String>();
            String checkNull;
            
            List<ccrz__E_Category__c> allavailscat= [select id,ccrz__CategoryID__c from ccrz__E_Category__c];
            Map<String,id> allcat = new Map<String,id>(); 
            for(ccrz__E_Category__c t1 :allavailscat){
                allcat.put(t1.ccrz__CategoryID__c.toUpperCase(),t1.Id);
            }
            for (Object prod: aSKU) {
                prod1 = (Map<String, Object>)prod;
                
                if(prod1.keyset().contains('PH4 Configuration')){
                    checkNull = (((String.valueOf(prod1.get('PH4 Configuration'))).removeStart('(')).removeEnd(')'));
                    if(!String.isBlank(checkNull)){
                        ph4Config.add((((String.valueOf(prod1.get('PH4 Configuration'))).removeStart('(')).removeEnd(')')));
                    }
                } 
                
                if(prod1.keyset().contains('PH5 Intelligence')){
                    checkNull = (((String.valueOf(prod1.get('PH5 Intelligence'))).removeStart('(')).removeEnd(')'));
                    if(!String.isBlank(checkNull)){
                        ph5Intel.add((((String.valueOf(prod1.get('PH5 Intelligence'))).removeStart('(')).removeEnd(')')));
                    }
                }
                
                if(prod1.keyset().contains('Programs')){
                    checkNull = (((String.valueOf(prod1.get('Programs'))).removeStart('(')).removeEnd(')'));
                    if(!String.isBlank(checkNull)){
                        semivalues=checkNull.split('\\;');
                        for(String ele:semivalues){
                            programs.add(ele);
                        } 
                    } 
                }
                
                 if(prod1.keyset().contains('Controls Platform')){
                    checkNull = (((String.valueOf(prod1.get('Controls Platform'))).removeStart('(')).removeEnd(')'));
                    if(!String.isBlank(checkNull)){
                        semivaluescontrols=checkNull.split('\\;');
                        for(String ele1:semivaluescontrols){
                            controls.add(ele1);
                        } 
                    } 
                }
            }
            
            aSKU=null;
            System.debug(ph4Config);
            System.debug(ph5Intel);
            System.debug(programs);
            
            List<ccrz__E_Category__c> newcatlist =new  List<ccrz__E_Category__c>();
            
            for (string cat1: ph4Config) {
                if(!allcat.keyset().contains(cat1.toUpperCase()+'*CONFIGURATION')){
                    //  if(!allcat.keyset().containsIgnoreCase(cat1) ){
                    ccrz__E_Category__c newcat = new ccrz__E_Category__c();
                    newcat.Name = cat1;
                    newcat.ccrz__CategoryID__c = cat1.toUpperCase()+'*CONFIGURATION'; 
                    newcat.ccrz__ParentCategory__c = allcat.get('PH4 CONFIGURATION');
                    newcatlist.add(newcat);
                    // system.debug(newcat1);
                }
            }
            ph4Config = Null;
            for (string cat1: ph5Intel) {
                if(!allcat.keyset().contains(cat1.toUpperCase()+'*INTELLIGENCE')){
                    //  if(!allcat.keyset().containsIgnoreCase(cat1) ){
                    ccrz__E_Category__c newcat = new ccrz__E_Category__c();
                    newcat.Name = cat1;
                    newcat.ccrz__CategoryID__c = cat1.toUpperCase()+'*INTELLIGENCE'; 
                    newcat.ccrz__ParentCategory__c = allcat.get('PH5 INTELLIGENCE');
                    newcatlist.add(newcat);
                    // system.debug(newcat1);
                }
            }   
            System.debug(ph5Intel.size());
            ph5Intel = Null;
            
            for (string cat1: programs) {
                if(!allcat.keyset().contains(cat1.toUpperCase()+'*PROGRAMS')){
                    //  if(!allcat.keyset().containsIgnoreCase(cat1) ){
                    ccrz__E_Category__c newcat = new ccrz__E_Category__c();
                    newcat.Name = cat1;
                    newcat.ccrz__CategoryID__c = cat1.toUpperCase()+'*PROGRAMS'; 
                    newcat.ccrz__ParentCategory__c = allcat.get('PROGRAMS');
                    newcatlist.add(newcat);
                    // system.debug(newcat1);
                }
            }   
            System.debug(programs.size());
            programs = Null;
            
            for (string cat1: controls) {
                if(!allcat.keyset().contains(cat1.toUpperCase()+'*CONTROLS PLATFORM')){
                    //  if(!allcat.keyset().containsIgnoreCase(cat1) ){
                    ccrz__E_Category__c newcat = new ccrz__E_Category__c();
                    newcat.Name = cat1;
                    newcat.ccrz__CategoryID__c = cat1.toUpperCase()+'*CONTROLS PLATFORM'; 
                    newcat.ccrz__ParentCategory__c = allcat.get('CONTROLS PLATFORM');
                    newcatlist.add(newcat);
                    system.debug(newcat);
                }
            }   
            System.debug(controls.size());
            
            System.debug(newcatlist.size());
            Database.insert(newcatlist);
            newcatlist.clear();
            
            
            Set<String> brand= new Set<String>();
            //Set<String> Country= new Set<String>();
            Set<String> familyApp= new Set<String>();
            Set<String> ph1Prod= new Set<String>();
            Set<String> ph2App= new Set<String>();
            Set<String> ph3Fam= new Set<String>();
            Set<String> prodCat= new Set<String>();
            Set<String> prodsubCat= new Set<String>();
            //List<String> semivalues= new List<String>();
            Set<String> family= new Set<String>();
            
            //String checkNull;
            for (Object prod: aFamily) {
                prod1 = (Map<String, Object>)prod;
                
                if(prod1.keyset().contains('Brand')){
                    checkNull = (((String.valueOf(prod1.get('Brand'))).removeStart('(')).removeEnd(')'));
                    if(!String.isBlank(checkNull)){
                        brand.add((((String.valueOf(prod1.get('Brand'))).removeStart('(')).removeEnd(')')));
                    }
                } 
                
                /*if(prod1.keyset().contains('Country of Origin')){
Country.add((((String.valueOf(prod1.get('Country of Origin'))).removeStart('(')).removeEnd(')')));

}*/
                
                if(prod1.keyset().contains('Family Applications')){
                    checkNull = (((String.valueOf(prod1.get('Family Applications'))).removeStart('(')).removeEnd(')'));
                    if(!String.isBlank(checkNull)){
                        semivalues=checkNull.split('\\;');
                        for(String ele:semivalues){
                            
                            familyApp.add(ele);
                            
                        } 
                        
                    } 
                    
                }
                if(prod1.keyset().contains('PH1 Product Line')){
                    checkNull = (((String.valueOf(prod1.get('PH1 Product Line'))).removeStart('(')).removeEnd(')'));
                    if(!String.isBlank(checkNull)){
                        ph1Prod.add((((String.valueOf(prod1.get('PH1 Product Line'))).removeStart('(')).removeEnd(')')));
                    }    
                } 
                
                if(prod1.keyset().contains('PH2 Application')){
                    checkNull = (((String.valueOf(prod1.get('PH2 Application'))).removeStart('(')).removeEnd(')'));
                    if(!String.isBlank(checkNull)){
                        ph2App.add((((String.valueOf(prod1.get('PH2 Application'))).removeStart('(')).removeEnd(')')));
                    }  
                }
                
                if(prod1.keyset().contains('PH3 Family')){
                    checkNull = (((String.valueOf(prod1.get('PH3 Family'))).removeStart('(')).removeEnd(')'));
                    if(!String.isBlank(checkNull)){
                        ph3Fam.add((((String.valueOf(prod1.get('PH3 Family'))).removeStart('(')).removeEnd(')')));
                    } 
                }
                
                if(prod1.keyset().contains('Product Category')){
                    checkNull = (((String.valueOf(prod1.get('Product Category'))).removeStart('(')).removeEnd(')'));
                    if(!String.isBlank(checkNull)){
                        semivalues=checkNull.split('\\;');
                        for(String ele:semivalues){
                            prodCat.add(ele.replaceAll( '\\s+', ''));
                        } 
                    } 
                }
                
                if(prod1.keyset().contains('Product Subcategory')){
                    checkNull = (((String.valueOf(prod1.get('Product Subcategory'))).removeStart('(')).removeEnd(')'));
                    if(!String.isBlank(checkNull)){
                        semivalues=checkNull.split('\\;');
                        for(String ele:semivalues){
                            prodsubCat.add(ele);
                        } 
                    } 
                }
                
                if(prod1.keyset().contains('Catalog Logic')){
                    checkNull = (((String.valueOf(prod1.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                    if(!String.isBlank(checkNull)){     
                        family.add((((String.valueOf(prod1.get('Catalog Logic'))).removeStart('(')).removeEnd(')')));
                    }  
                }     
                
            }
            
            aFamily=Null;
            System.debug(brand.size());
            //System.debug(Country.size());    
            System.debug(familyApp.size());    
            System.debug(ph1Prod.size());    
            System.debug(ph2App.size());    
            System.debug(ph3Fam.size());    
            System.debug(prodCat.size());
            System.debug(prodsubCat.size());
            System.debug(prodCat);
            System.debug(prodsubCat);
            System.debug(family.size());
            
            for (string cat1: prodCat) {
                if(!allcat.keyset().contains(cat1.toUpperCase())){
                    //  if(!allcat.keyset().containsIgnoreCase(cat1) ){
                    ccrz__E_Category__c newcat = new ccrz__E_Category__c();
                    newcat.Name = cat1;
                    newcat.ccrz__CategoryID__c = cat1.toUpperCase(); 
                    newcat.ccrz__ParentCategory__c = allcat.get('PRODUCTS');
                    newcatlist.add(newcat);
                    // system.debug(newcat1);
                }
            }
            System.debug(newcatlist.size());
            for (string cat1: brand) {
                if(!allcat.keyset().contains(cat1.toUpperCase()+'*BRAND')){
                    //  if(!allcat.keyset().containsIgnoreCase(cat1) ){
                    ccrz__E_Category__c newcat = new ccrz__E_Category__c();
                    newcat.Name = cat1;
                    newcat.ccrz__CategoryID__c = cat1.toUpperCase()+'*BRAND'; 
                    newcat.ccrz__ParentCategory__c = allcat.get('BRAND');
                    newcatlist.add(newcat);
                    // system.debug(newcat1);
                }
            }
            
            /*for (string cat1: Country) {
if(!allcat.keyset().contains(cat1.toUpperCase()+'*COUNTRY-OF-ORIGIN')){
//  if(!allcat.keyset().containsIgnoreCase(cat1) ){
ccrz__E_Category__c newcat = new ccrz__E_Category__c();
newcat.Name = cat1;
newcat.ccrz__CategoryID__c = cat1.toUpperCase()+'*COUNTRY-OF-ORIGIN'; 
newcat.ccrz__ParentCategory__c = allcat.get('COUNTRY-OF-ORIGIN');
newcatlist.add(newcat);
// system.debug(newcat1);
}
}*/
            
            for (string cat1: familyApp) {
                if(!allcat.keyset().contains(cat1.toUpperCase()+'*FAMILY APPLICATIONS')){
                    //  if(!allcat.keyset().containsIgnoreCase(cat1) ){
                    ccrz__E_Category__c newcat = new ccrz__E_Category__c();
                    newcat.Name = cat1;
                    newcat.ccrz__CategoryID__c = cat1.toUpperCase()+'*FAMILY APPLICATIONS'; 
                    newcat.ccrz__ParentCategory__c = allcat.get('FAMILY APPLICATIONS');
                    newcatlist.add(newcat);
                    // system.debug(newcat1);
                }
            }
            
            for (string cat1: ph1Prod) {
                if(!allcat.keyset().contains(cat1.toUpperCase()+'*PH1 PRODUCT LINE')){
                    //  if(!allcat.keyset().containsIgnoreCase(cat1) ){
                    ccrz__E_Category__c newcat = new ccrz__E_Category__c();
                    newcat.Name = cat1;
                    newcat.ccrz__CategoryID__c = cat1.toUpperCase()+'*PH1 PRODUCT LINE'; 
                    newcat.ccrz__ParentCategory__c = allcat.get('PH1 PRODUCT LINE');
                    newcatlist.add(newcat);
                    // system.debug(newcat1);
                }
            }
            
            for (string cat1: ph2App) {
                if(!allcat.keyset().contains(cat1.toUpperCase()+'*PH2 APPLICATION')){
                    //  if(!allcat.keyset().containsIgnoreCase(cat1) ){
                    ccrz__E_Category__c newcat = new ccrz__E_Category__c();
                    newcat.Name = cat1;
                    newcat.ccrz__CategoryID__c = cat1.toUpperCase()+'*PH2 APPLICATION'; 
                    newcat.ccrz__ParentCategory__c = allcat.get('PH2 APPLICATION');
                    newcatlist.add(newcat);
                    // system.debug(newcat1);
                }
            }
            
            for (string cat1: ph3Fam) {
                if(!allcat.keyset().contains(cat1.toUpperCase()+'*PH3 FAMILY')){
                    //  if(!allcat.keyset().containsIgnoreCase(cat1) ){
                    ccrz__E_Category__c newcat = new ccrz__E_Category__c();
                    newcat.Name = cat1;
                    newcat.ccrz__CategoryID__c = cat1.toUpperCase()+'*PH3 FAMILY'; 
                    newcat.ccrz__ParentCategory__c = allcat.get('PH3 FAMILY');
                    newcatlist.add(newcat);
                    // system.debug(newcat1);
                }
            }
            
            for (string cat1: family) {
                if(!allcat.keyset().contains(cat1.toUpperCase()+'*FAMILY')){
                    //  if(!allcat.keyset().containsIgnoreCase(cat1) ){
                    ccrz__E_Category__c newcat = new ccrz__E_Category__c();
                    newcat.Name = cat1;
                    newcat.ccrz__CategoryID__c = cat1.toUpperCase()+'*FAMILY'; 
                    newcat.ccrz__ParentCategory__c = allcat.get('FAMILY');
                    newcatlist.add(newcat);
                    // system.debug(newcat1);
                }
            }
            
            System.debug(newcatlist.size());
            Database.insert(newcatlist);
            newcatlist.clear();
            allavailscat.clear();
            allcat.clear();
            allavailscat= [select id,ccrz__CategoryID__c from ccrz__E_Category__c];
            allcat = new Map<String,id>(); 
            for(ccrz__E_Category__c t1 :allavailscat){
                allcat.put(t1.ccrz__CategoryID__c.toUpperCase(),t1.Id);
            }
            
            
            for (string cat1: prodCat) {
                for (string catsub: prodsubCat) {
                    if(!allcat.keyset().contains(catsub.toUpperCase()+'*'+cat1.toUpperCase())){
                        //  if(!allcat.keyset().containsIgnoreCase(cat1) ){
                        ccrz__E_Category__c newcat = new ccrz__E_Category__c();
                        newcat.Name = catsub;
                        newcat.ccrz__CategoryID__c = catsub.toUpperCase()+'*'+cat1.toUpperCase(); 
                        newcat.ccrz__ParentCategory__c = allcat.get(cat1.toUpperCase());
                        newcatlist.add(newcat);
                        // system.debug(newcat1);
                    }
                }
                
            }
            System.debug(newcatlist.size());
            System.debug(newcatlist);
            Database.insert(newcatlist);
        }
        
        catch (Exception e) {
            
        }
    }
}