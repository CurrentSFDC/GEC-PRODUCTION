public class GE_LGT_EM_InstallBase_Mass_Upload { 
    
    public GE_LGT_EM_InstallBase_Mass_Upload(ApexPages.StandardController controller) 
    {         
        
    }
    
    public GE_LGT_EM_InstallBase_Mass_Upload(ApexPages.StandardSetController controller) 
    {
        
    }  
    
    Public String OpptyStage{get;set;}
    Public Map<string,string> RecrdIdMap= new Map<string,string>();
    Public List<RecordType> recrdlist=new List<RecordType>();
    
    public void getPrerequisite()
    {
        System.debug('*******'+optyid);
        OpptyStage=[select StageName from Opportunity where id=:optyid].StageName;
        System.debug('*******'+OpptyStage);
        recrdlist=new List<RecordType>([select id,Name from RecordType where sobjecttype=:'Install_Base__c']);               
        for(Recordtype rt:recrdlist) {        
            RecrdIdMap.put(rt.Name,rt.Id);          
        }         
        System.debug('*******'+recrdlist);
        System.debug('*******'+RecrdIdMap);
    }
    
    public String nameFile{get;set;}
    public static integer InsertC=0;
    public static integer UpdateC=0;
    public blob contentFile{get;set;}
    String[] filelines = new String[]{}; 
        Public List<Install_Base__c> ibstoupload;
    Id Optyid = System.currentPageReference().getParameters().get('id');
    
    public string getoptyTitle()
    {
        Return [SELECT Name FROM Opportunity WHERE id = :optyid].Name;
    }
    
    
    Public void getShowError()
    {        
        
        if(OpptyStage=='S1 Consult'||OpptyStage=='S2 Audit'||OpptyStage=='Closed Lost'){                
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Installed Bases cannot be Uploaded for an Opportunity with stage in S1 Consult,S2 Audit and Closed Lost.');
            ApexPages.addMessage(errormsg);                          
        }        
    }
    
    public string OpptyName=[select GE_LGT_GE_Opportunity_Id__c from Opportunity where id=:optyid].GE_LGT_GE_Opportunity_Id__c;               
    
    public Pagereference ReadFile()
    {          
        Set<String> bs = new Set<String>();     
        try {    
            
            if(OpptyStage=='S1 Consult'||OpptyStage=='S2 Audit'||OpptyStage=='Closed Lost'){                
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Installed Bases cannot be Uploaded for an Opportunity with stage in S1 Consult,S2 Audit and Closed Lost');
                ApexPages.addMessage(errormsg);                     
            }
            else
            {
                if (contentFile!= null) 
                {
                    if (nameFile.endsWith('.csv'))
                    {   
                        nameFile=contentfile.Tostring();
                        filelines = nameFile.split('\n');
                        Install_Base__c ib;
                        ibstoupload = new List<Install_Base__c>();
                        String[] colhd = new String[]{};
                            if (filelines[0].contains(';'))
                        {
                            colhd = filelines[0].split(';');
                        }
                        else
                        {
                            colhd = filelines[0].split(',');
                        }
                        if ( (colhd[0].trim() == 'Installation Site ID') && (colhd[1].trim() == 'Installed Base Name') && (colhd[2].trim() == 'Street Address') && (colhd[3].trim() == 'City') && (colhd[4].trim() == 'Zip code') && (colhd[5].trim() == 'Region') && (colhd[6].trim() == 'Country') && (colhd[7].trim() == 'Site Contact Name') && (colhd[8].trim() == 'Site Contact Phone') && (colhd[9].trim() == 'Site Contact Email') && (colhd[10].trim() == 'Ins.Warrianty yrs') && (colhd[11].trim() == 'Location coordinates') && (colhd[12].trim() == 'Drawing number') && (colhd[13].trim() == 'Invoice number') && (colhd[14].trim() == 'SAP SO Number') && (colhd[15].trim() == 'Electrical metering') && (colhd[16].trim() == 'Audit Date (plan)') && (colhd[17].trim() == 'Design Completed date (plan)') && (colhd[18].trim() == 'Quotation issue date (plan)') && (colhd[19].trim() == 'Equipment order date (plan)') && (colhd[20].trim() == 'Equipment delivery date (plan)') && (colhd[21].trim() == 'Installation Start date (plan)') && (colhd[22].trim() == 'Installation Completion Date (plan)') && (colhd[23].trim() == 'Installation Completion Date (actual)') && (colhd[24].trim() == 'Warranty start date') && (colhd[25].trim() == 'Daily operating hours') && (colhd[26].trim() == 'Working days / week') && (colhd[27].trim() == 'Energy rate / KWh')&& (colhd[28].trim() == 'File Storage'))
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
                                    ib = new Install_Base__c();
                                    ib.Installation_Site_ID__c = inputvalues[0]; 
                                    ib.recordtypeid = RecrdIdMap.get('Integrated');
                                    bs.add(ib.Installation_Site_ID__c);
                                    
                                    if ((inputvalues[1] != null) && (inputvalues[1] != ''))
                                    {
                                        ib.Name = inputvalues[1]; 
                                    }                               
                                    else
                                    {
                                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,' Could not upload the file, since there are blank Installed Base Name(s) in the file');
                                        ApexPages.addMessage(errormsg);                                
                                    }
                                    if ((inputvalues[2] != null) && (inputvalues[2] != ''))
                                    {
                                        ib.Ship_to_Site_Address_Street__c = inputvalues[2];
                                    } 
                                    if ((inputvalues[3] != null) && (inputvalues[3] != ''))
                                    {
                                        ib.City__c = inputvalues[3]; 
                                    }  
                                    if ((inputvalues[4] != null) && (inputvalues[4] != ''))
                                    {
                                        ib.Zip_code__c = inputvalues[4];
                                    }
                                    if ((inputvalues[5] != null) && (inputvalues[5] != ''))
                                    {
                                        ib.Region__c = inputvalues[5];
                                    }                                
                                    if ((inputvalues[6] != null) && (inputvalues[6] != ''))
                                    {
                                        ib.Country__c = inputvalues[6];
                                    }                       
                                    ib.Opportunity__c = Optyid;                                
                                    ib.InstallBase_site_with_Name__c = String.valueof(inputvalues[0] + OpptyName);
                                    if ((inputvalues[7] != null) && (inputvalues[7] != ''))
                                    {
                                        ib.Site_Contact_Name__c = inputvalues[7];
                                    }
                                    if ((inputvalues[8] != null) && (inputvalues[8] != ''))
                                    {
                                        ib.Site_Contact_Phone__c = inputvalues[8];
                                    }
                                    if ((inputvalues[9] != null) && (inputvalues[9] != ''))
                                    {
                                        ib.Site_Contact_Email__c = inputvalues[9];
                                    }
                                    if ((inputvalues[10].trim() != null) && (inputvalues[10].trim() != ''))
                                    {
                                        ib.Ins_Warrianty_yrs__c = decimal.valueOf(inputvalues[10].trim());
                                    }
                                    
                                    
                                    if ((inputvalues[12] != null) && (inputvalues[12] != ''))
                                    {
                                        ib.Drawing_number__c = inputvalues[12];
                                    }
                                    
                                    if ((inputvalues[13] != null) && (inputvalues[13] != ''))
                                    {
                                        if(inputvalues[13].isNumericSpace()==true) 
                                            ib.Invoice_number__c = inputvalues[13];
                                        else
                                        {
                                            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,' Value for Invoice number should contain only digits and spaces between. Please change and try uploading again.');
                                            ApexPages.addMessage(errormsg); 
                                        }
                                    }
                                    
                                    if ((inputvalues[14] != null) && (inputvalues[14] != ''))
                                    {
                                        if(inputvalues[14].isNumericSpace()==true) 
                                            ib.SAP_PO_number__c = inputvalues[14];
                                        else
                                        {
                                            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,' Value for SAP SO Number should contain only digits and spaces between. Please change and try uploading again.');
                                            ApexPages.addMessage(errormsg); 
                                        }
                                    }
                                    
                                    if ((inputvalues[15] != null) && (inputvalues[15] != ''))
                                    {
                                        if(inputvalues[15]=='Auto'||inputvalues[15]=='Manual')
                                        {                                    
                                            ib.Electrical_metering__c = inputvalues[15];  
                                        }
                                        else{
                                            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,' Value for Electrical Metering should only be either "Auto" or "Manual". Please change and try uploading again.');
                                            ApexPages.addMessage(errormsg);
                                        }
                                    }                                                                                            
                                    if ((inputvalues[16] != null) && (inputvalues[16].trim() != ''))
                                    {
                                        ib.Planned_Audit_date__c = date.parse(inputvalues[16].trim());
                                    }
                                    if ((inputvalues[17] != null) && (inputvalues[17].trim() != ''))     
                                    {
                                        ib.Planned_Designed_Completed_date__c = date.parse(inputvalues[17].trim());
                                    }          
                                    if ((inputvalues[18] != null) && (inputvalues[18].trim() != ''))     
                                    {
                                        ib.Quotation_issued_date_plan__c = date.parse(inputvalues[18].trim());
                                    }
                                    if ((inputvalues[19] != null) && (inputvalues[19].trim() != ''))     
                                    {
                                        ib.Equipment_ordered_date_plan__c = date.parse(inputvalues[19].trim());
                                    }
                                    if ((inputvalues[20] != null) && (inputvalues[20].trim() != ''))
                                    {
                                        ib.Planned_Order_Receive_date__c = date.parse(inputvalues[20].trim());
                                    }
                                    if ((inputvalues[21] != null) && (inputvalues[21].trim() != ''))
                                    {
                                        ib.Planned_Installation_Start_date__c = date.parse(inputvalues[21].trim());
                                    }
                                    if ((inputvalues[22] != null) && (inputvalues[22] != ''))
                                    {
                                        ib.Planned_Installation_Completion_date__c = date.parse(inputvalues[22].trim());
                                    }
                                    if ((inputvalues[23] != null) && (inputvalues[23] != ''))
                                    {
                                        ib.Actual_Installation_Completion_date__c = date.parse(inputvalues[23].trim());
                                    }
                                    if ((inputvalues[24] != null) && (inputvalues[24] != ''))
                                    {
                                        ib.Warranty_start_date__c = date.parse(inputvalues[24].trim());
                                    }  
                                    if ((inputvalues[25] != null) && (inputvalues[25] != ''))
                                    {
                                        ib.Daily_operating_hours__c = integer.valueof(inputvalues[25]);
                                    }
                                    if ((inputvalues[26] != null) && (inputvalues[26] != ''))
                                    {
                                        ib.Working_days_week__c = integer.valueof(inputvalues[26]);
                                    }
                                    if ((inputvalues[27] != null) && (inputvalues[27] != ''))
                                    {
                                        ib.Energy_rate_kw_h__c = decimal.valueof(inputvalues[27]);
                                    }
                                    if ((inputvalues[28] != null) && (inputvalues[28] != ''))
                                    {
                                        ib.File_storage__c = inputvalues[28];
                                    }                                
                                    else
                                    {
                                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.WARNING,'Please fill out the file storage column with the url where we find all documents, input files of Installed base. Ensure that do not use http(s):// in the source value');
                                        ApexPages.addMessage(errormsg);                                
                                    }
                                    ibstoupload.add(ib);
                                }
                            }
                            else
                            {
                                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.WARNING,'The File selected does not have any data, Please upload a file filled with data');
                                ApexPages.addMessage(errormsg);
                            } 
                        }  
                        else if((colhd[0].trim() == 'Installation Site ID') && (colhd[1].trim() == 'Installed Base Name') && (colhd[2].trim() == 'Street Address') && (colhd[3].trim() == 'City') && (colhd[4].trim() == 'Zip code') && (colhd[5].trim() == 'Region') && (colhd[6].trim() == 'Country') && (colhd[7].trim() == 'Site Contact Name') && (colhd[8].trim() == 'Site Contact Phone') && (colhd[9].trim() == 'Site Contact Email') && (colhd[10].trim() == 'Ins.Warrianty yrs') && (colhd[11].trim() == 'Location coordinates') && (colhd[12].trim() == 'Drawing number') && (colhd[13].trim() == 'Invoice number') && (colhd[14].trim() == 'SAP SO Number') && (colhd[15].trim() == 'Electrical metering') && (colhd[16].trim() == 'Audit Date (Actual)') && (colhd[17].trim() == 'Design Completed date (Actual)') && (colhd[18].trim() == 'Quotation issue date (Actual)') && (colhd[19].trim() == 'Equipment order date (Actual)') && (colhd[20].trim() == 'Equipment delivery date (Actual)') && (colhd[21].trim() == 'Installation Start date (Actual)') && (colhd[22].trim() == 'Installation Completion Date (actual)') && (colhd[23].trim() == 'Warranty start date') && (colhd[24].trim() == 'Daily operating hours') && (colhd[25].trim() == 'Working days / week') && (colhd[26].trim() == 'Energy rate / KWh') && (colhd[27].trim() == 'File Storage'))
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
                                    ib = new Install_Base__c();        
                                    ib.Installation_Site_ID__c = inputvalues[0]; 
                                    ib.recordtypeid = RecrdIdMap.get('Simple');
                                    bs.add(ib.Installation_Site_ID__c);   
                                    if ((inputvalues[1] != null) && (inputvalues[1] != ''))
                                    {
                                        ib.Name = inputvalues[1]; 
                                    }                               
                                    else
                                    {
                                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,' Could not upload the file, since there are blank Installed Base Name(s) in the file');
                                        ApexPages.addMessage(errormsg);                                
                                    }                               
                                    if ((inputvalues[2] != null) && (inputvalues[2] != ''))
                                    {
                                        ib.Ship_to_Site_Address_Street__c = inputvalues[2];
                                    } 
                                    if ((inputvalues[3] != null) && (inputvalues[3] != ''))
                                    {
                                        ib.City__c = inputvalues[3]; 
                                    }  
                                    if ((inputvalues[4] != null) && (inputvalues[4] != ''))
                                    {
                                        ib.Zip_code__c = inputvalues[4];
                                    }
                                    if ((inputvalues[5] != null) && (inputvalues[5] != ''))
                                    {
                                        ib.Region__c = inputvalues[5];
                                    }                                
                                    if ((inputvalues[6] != null) && (inputvalues[6] != ''))
                                    {
                                        ib.Country__c = inputvalues[6];
                                    }                       
                                    ib.Opportunity__c = Optyid;                                
                                    ib.InstallBase_site_with_Name__c = String.valueof(inputvalues[0] + OpptyName);
                                    if ((inputvalues[7] != null) && (inputvalues[7] != ''))
                                    {
                                        ib.Site_Contact_Name__c = inputvalues[7];
                                    }
                                    if ((inputvalues[8] != null) && (inputvalues[8] != ''))
                                    {
                                        ib.Site_Contact_Phone__c = inputvalues[8];
                                    }
                                    if ((inputvalues[9] != null) && (inputvalues[9] != ''))
                                    {
                                        ib.Site_Contact_Email__c = inputvalues[9];
                                    }
                                    if ((inputvalues[10].trim() != null) && (inputvalues[10].trim() != ''))
                                    {
                                        ib.Ins_Warrianty_yrs__c = decimal.valueOf(inputvalues[10].trim());
                                    }
                                    
                                    
                                    if ((inputvalues[12] != null) && (inputvalues[12] != ''))
                                    {
                                        ib.Drawing_number__c = inputvalues[12];
                                    }
                                    
                                    if ((inputvalues[13] != null) && (inputvalues[13] != ''))
                                    {
                                        if(inputvalues[13].isNumericSpace()==true) 
                                            ib.Invoice_number__c = inputvalues[13];
                                        else
                                        {
                                            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,' Value for Invoice Number should contain only digits and spaces between. Please change and try uploading again.');
                                            ApexPages.addMessage(errormsg); 
                                        }
                                    }
                                    
                                    if ((inputvalues[14] != null) && (inputvalues[14] != ''))
                                    {
                                        if(inputvalues[14].isNumericSpace()==true) 
                                            ib.SAP_PO_number__c = inputvalues[14];
                                        else
                                        {
                                            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,' Value for SAP SO Number should contain only digits and spaces between. Please change and try uploading again.');
                                            ApexPages.addMessage(errormsg); 
                                        }
                                    }
                                    
                                    if ((inputvalues[15] != null) && (inputvalues[15] != ''))
                                    {
                                        if(inputvalues[15]=='Auto'||inputvalues[15]=='Manual')
                                        {                                    
                                            ib.Electrical_metering__c = inputvalues[15];  
                                        }
                                        else{
                                            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,' Value for Electrical Metering should only be either "Auto" or "Manual". Please change and try uploading again.');
                                            ApexPages.addMessage(errormsg);
                                        }
                                    }                                                                                         
                                    if ((inputvalues[16] != null) && (inputvalues[16].trim() != ''))
                                    {
                                        ib.Actual_Audit_date__c = date.parse(inputvalues[16].trim());
                                    }
                                    if ((inputvalues[17] != null) && (inputvalues[17].trim() != ''))     
                                    {
                                        ib.Actual_Designed_Completed_date__c = date.parse(inputvalues[17].trim());
                                    }          
                                    if ((inputvalues[18] != null) && (inputvalues[18].trim() != ''))     
                                    {
                                        ib.Quotation_issued_date_actual__c = date.parse(inputvalues[18].trim());
                                    }
                                    if ((inputvalues[19] != null) && (inputvalues[19].trim() != ''))     
                                    {
                                        ib.Equipment_ordered_date_actual__c = date.parse(inputvalues[19].trim());
                                    }
                                    if ((inputvalues[20] != null) && (inputvalues[20].trim() != ''))
                                    {
                                        ib.Actual_Order_Receive_date__c = date.parse(inputvalues[20].trim());
                                    }
                                    if ((inputvalues[21] != null) && (inputvalues[21] != ''))
                                    {
                                        ib.Inst_Completion_Date__c = date.parse(inputvalues[21].trim());
                                    }
                                    if ((inputvalues[22] != null) && (inputvalues[22] != ''))
                                    {
                                        ib.Actual_Installation_Completion_date__c = date.parse(inputvalues[22].trim());
                                    }
                                    if ((inputvalues[23] != null) && (inputvalues[23].trim() != ''))
                                    {
                                        ib.Warranty_start_date__c = date.parse(inputvalues[23].trim());
                                    }  
                                    if ((inputvalues[24] != null) && (inputvalues[24] != ''))
                                    {
                                        ib.Daily_operating_hours__c = integer.valueof(inputvalues[24]);
                                    } 
                                    if ((inputvalues[25] != null) && (inputvalues[25] != ''))
                                    {
                                        ib.Working_days_week__c = integer.valueof(inputvalues[25]);
                                    } 
                                    if ((inputvalues[26] != null) && (inputvalues[26] != ''))
                                    {
                                        ib.Energy_rate_kw_h__c = decimal.valueof(inputvalues[26]);
                                    } 
                                    if ((inputvalues[27] != null) && (inputvalues[27] != ''))
                                    {
                                        ib.File_storage__c = inputvalues[27];
                                    }                                
                                    else
                                    {
                                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.WARNING,'Please fill out the file storage column with the url where we find all documents, input files of Installed base. Ensure that do not use http(s):// in the source value');
                                        ApexPages.addMessage(errormsg);                                
                                    }
                                    ibstoupload.add(ib);
                                }                                                           
                            }
                            else                        
                            {
                                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.WARNING,'The File selected does not have any data, Please upload a file filled with data');
                                ApexPages.addMessage(errormsg);
                            }                           
                        }                       
                        else
                        {
                            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'File format is not correct, please use template, download and after you filled it with data, try to upload again.');
                            ApexPages.addMessage(errormsg); 
                        }
                        if(ApexPages.hasMessages()==false)
                        {
                            if ((filelines.size() - 1) == bs.size())
                            {
                                Database.UpsertResult[] srlist= Database.upsert(ibstoupload, Schema.Install_Base__c.InstallBase_site_with_Name__c, false);
                                
                                for (Database.UpsertResult sr : srList) 
                                {
                                    if (sr.isSuccess())                             
                                    {
                                        if(sr.isCreated()==true)
                                        {
                                            InsertC=InsertC+1;                                    
                                        }
                                        else if(sr.isCreated()==false)
                                        {
                                            UpdateC=UpdateC+1;
                                        }                                                                                                
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
                                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.INFO, InsertC +' Records Inserted successfully');
                                ApexPages.addMessage(errormsg); 
                                
                                ApexPages.Message errormsg1 = new ApexPages.Message(ApexPages.severity.INFO, UpdateC +' Records Updated successfully');
                                ApexPages.addMessage(errormsg1);                                                           
                            }
                            else
                            {
                                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Upload failed, duplicate Site IDs found in the Input data file');
                                ApexPages.addMessage(errormsg);
                            }
                        }                                               
                        return null;
                    }
                    else
                    {
                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'The file format (extension) you try to upload is not matching. Please upload csv format and try again.');
                        ApexPages.addMessage(errormsg);    
                    }
                }
                else
                {
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Please choose a file, you can use the template download and after you filled it with data, try to upload again.');
                    ApexPages.addMessage(errormsg);
                }               
            }
            return null;
        }
        catch(Exception ee)
        {                                
            if (ee.getMessage().contains('Invalid date')) 
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Invalid Date Format, please use the following format and try upload it again: MM/DD/CCYY');
                ApexPages.addMessage(errormsg); 
            }
            else if(ee.getMessage().contains('Invalid number')||ee.getMessage().contains('Invalid decimal')) 
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Please  enter a valid warranty year min. 1 year max. 15 years, and try to upload again.');
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