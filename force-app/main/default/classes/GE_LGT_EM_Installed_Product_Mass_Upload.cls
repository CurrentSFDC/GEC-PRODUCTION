public class GE_LGT_EM_Installed_Product_Mass_Upload
{ 
    public GE_LGT_EM_Installed_Product_Mass_Upload(ApexPages.StandardController controller) 
    {
        
    }
    public GE_LGT_EM_Installed_Product_Mass_Upload(ApexPages.StandardSetController controller) 
    {
        
    }
    
    Public String Error{get;set;}
    public static integer InsertC=0;    
    public static integer UpdateC=0;
    Public static integer Count=0;
    public String nameFile{get;set;}
    public List<String> skuList = new List<String>();  
    public Blob contentFile{get;set;}
    String[] filelines = new String[]{}; 
        Public List<Installed_Product__c> ipstoupload;
    public Map<String,Id> mmMap = new Map<String,Id>();  
    public Map<String,Integer> sapMaterial = new Map<String,Integer>();
    Public List<GE_LGT_EM_MaterialMaster__c> mmList = new List<GE_LGT_EM_MaterialMaster__c>();
    Id ibId = System.currentPageReference().getParameters().get('id');
    
    public string getIPTitle()
    {
        Return [SELECT Name FROM Install_Base__c WHERE id = :ibId].Name;
    }  
    
    public Pagereference ReadFile()
    {   
        try {        
            if (contentFile != null)
            {     
                Error = '';
                if (nameFile.endsWith('.csv'))
                {
                    nameFile = contentFile.toString();           
                    filelines = nameFile.split('\n');
                    ipstoupload = new List<Installed_Product__c>();
                    String[] colhd = new String[]{};
                        Set<String> ips = new Set<String>();
                    if (filelines[0].contains(';'))
                    {
                        colhd = filelines[0].split(';');
                    }
                    else
                    {
                        colhd = filelines[0].split(',');
                    }
                    system.debug('******'+filelines);
                    if ( (colhd[0].trim() == 'SKU') && (colhd[1].trim() == 'Product Manual Description') && (colhd[2].trim() == 'Designed qty') && (colhd[3].trim() == 'Ordered qty') && (colhd[4].trim() == 'Installed qty') && (colhd[5].trim() == 'Product Warranty Years') && (colhd[6].trim() == 'Area') && (colhd[7].trim() == 'Floor') && (colhd[8].trim() == 'Room') && (colhd[9].trim() == 'Sales price/unit')&& (colhd[10].trim() == 'Product Wattage'))
                    {
                        if (filelines.size() > 1)
                        {                             
                            for (Integer i=1; i<filelines.size(); i++)
                            {
                                String[] inputvalues = new String[]{};
                                    if (filelines[0].contains(';'))
                                {
                                    inputvalues = filelines[i].split(';');
                                }
                                else
                                {
                                    inputvalues = filelines[i].split(',');
                                }
                                Installed_Product__c ip = new Installed_Product__c();                            
                                ip.Install_Base_Name__c = ibId;
                                sapMaterial.put(inputvalues[0].trim(),1);
                                ips.add(inputvalues[0].trim());   
                                
                                skuList.add(inputvalues[0].trim());
                                
                                if ((inputvalues[1] != null) && (inputvalues[1] != ''))
                                {
                                    ip.Product_Manual_Description__c = inputvalues[1];
                                }
                                
                                if((inputvalues[2].trim() == null || inputvalues[2].trim() == '' || inputvalues[2].trim() == '0' ) && 
                                   (inputvalues[3].trim() == null || inputvalues[3].trim() == '' || inputvalues[3].trim() == '0' ) && 
                                   (inputvalues[4].trim() == null || inputvalues[4].trim() == '' || inputvalues[4].trim() == '0' )){
                                       
                                       ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'There should be at least one Quantity (designed / ordered / installed) entered per product. Also only Numeric Values are allowed for Quantities.');
                                       ApexPages.addMessage(errormsg);
                                       return null;
                                   }                                                                                              
                                
                                if(inputvalues[2].trim() != null && inputvalues[2].trim() != '' && inputvalues[2].trim() != '0' ) {
                                    
                                    ip.Qty__c = Integer.valueOf(inputvalues[2].trim());  
                                } 
                                if(inputvalues[3].trim() != null && inputvalues[3].trim() != '' && inputvalues[3].trim() != '0' ) {
                                    ip.Ordered_Qty__c = Integer.valueOf(inputvalues[3].trim());
                                }
                                if(inputvalues[4].trim() != null && inputvalues[4].trim() != '' && inputvalues[4].trim() != '0' ) {
                                    ip.Installed_Qty__c = Integer.valueOf(inputvalues[4].trim());
                                }
                                if ((inputvalues[5] != null) && (inputvalues[5] != '') && (inputvalues[5].trim()).isNumeric() )
                                {
                                    ip.Product_Warranty_Years__c = Integer.valueOf(inputvalues[5]);
                                }
                                if ((inputvalues[6] != null) && (inputvalues[6] != ''))
                                {
                                    ip.Area__c = inputvalues[6];
                                }
                                if ((inputvalues[7] != null) && (inputvalues[7] != ''))
                                {
                                    ip.Floor__c = inputvalues[7];
                                }
                                if ((inputvalues[8] != null) && (inputvalues[8] != ''))
                                {
                                    ip.Room__c = inputvalues[8];
                                }
                                if (((inputvalues[9].trim()) != null) && ((inputvalues[9].trim()) != ''))
                                {
                                    ip.sales_price_per_unit__c = Decimal.valueOf(inputvalues[9].trim());
                                }                         
                                if (((inputvalues[10].trim()) != null) && ((inputvalues[10].trim()) != ''))
                                {
                                    ip.Product_Wattage__c = Integer.valueOf(inputvalues[10].trim());
                                }                                                                             
                                ipstoupload.add(ip);                                                                                                                                                              
                            }
                            system.debug('******'+ipstoupload);                     
                            mmList = [SELECT GE_LGT_EM_SAP_MaterialNumber__c, Id FROM GE_LGT_EM_MaterialMaster__c WHERE GE_LGT_EM_SAP_MaterialNumber__c IN :sapMaterial.keySet()];    
                            for (GE_LGT_EM_MaterialMaster__c mm :mmList)
                            {
                                mmMap.put(mm.GE_LGT_EM_SAP_MaterialNumber__c,mm.Id);    
                            }
                            
                            for (Integer i=0; i<ipstoupload.size(); i++)
                            {
                                
                                Installed_Product__c ipu = new Installed_Product__c();
                                ipu = ipstoupload.get(i);
                                ipu.SFDC_Material_ID__c = mmMap.get(skuList.get(i));
                                If (ipu.SFDC_Material_ID__c == Null)
                                {
                                    count=count+1;
                                }
                            } 
                            
                            
                            Database.SaveResult[] srList = Database.insert(ipstoupload, false);
                            
                            
                            for (Database.SaveResult sr : srList) 
                            {                            
                                if (sr.isSuccess())                             
                                {
                                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.INFO,' Records Inserted successfully');
                                    ApexPages.addMessage(errormsg);                                                                                          
                                }
                                else 
                                {
                                    for(Database.Error err : sr.getErrors()) 
                                    {
                                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,err.getStatusCode() + ': ' + err.getMessage() + 'Fields effected by' + err.getFields());
                                        ApexPages.addMessage(errormsg);
                                    }
                                }
                            }
                            
                            ApexPages.Message errormsg2 = new ApexPages.Message(ApexPages.severity.INFO, Count +' Records without existing SKU, please go and check where you need to add the SKU name');
                            ApexPages.addMessage(errormsg2);                        
                            
                        }
                        else
                        {
                            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'The File selected does not have any data, Please upload a file filled with data');
                            ApexPages.addMessage(errormsg);
                            
                            return null;
                        }   
                    }
                    else
                    {
                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'File format is not correct, please use template, download and after you filled it with data, try to upload again.');
                        ApexPages.addMessage(errormsg);
                        
                    }   
                }
                else
                {
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'The file format (extension) you try to upload is not matching. Please upload csv format and try again.');
                    ApexPages.addMessage(errormsg);
                    return null;
                }
            }
            else
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Please choose a file, you can use the template download and after you filled it with data, try to upload again.');               
                ApexPages.addMessage(errormsg);
                
                return null;
            }  
            return null;
            
        } catch(Exception ee) {
            if (ee.getMessage().contains('Invalid integer')) 
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Invalid Quantity Entered. Only Numeric Values are Allowed.');
                ApexPages.addMessage(errormsg); 
            }            
            else
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,ee.getmessage()+' '+ee.getStackTraceString());
                ApexPages.addMessage(errormsg); 
            }
            return null;
        }                           
    }
}