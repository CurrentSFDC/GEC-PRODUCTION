trigger GE_LGT_EM_IB_Stage on Install_Base__c (Before Insert, Before Update) {
    for (Install_Base__c ib :Trigger.New){
        if(ib.recordtypeid == [select id from recordtype where name=:'Integrated' and sobjecttype=:'Install_Base__c'].id)
        {
            //S7 Prerequisites
            if (ib.Planned_Audit_date__c != Null && ib.S6_Got_all_original_drawings__c == True)
            {
                ib.Install_Stage__c = 'S7-Audit';
                if (ib.Actual_Audit_date__c != Null && ib.Application_Engineer__c != Null && ib.S7_Red_line_drawings__c == True)
                {
                    ib.Install_Stage__c = 'S8-Design';
                    if (ib.Actual_Designed_Completed_date__c != Null && ib.Planned_Designed_Completed_date__c != Null && ib.Designer__c != Null && ib.S8_Design_completed_and_uploaded__c == True && ib.S8_Final_design_flag_checked__c == True && ib.S8_Design_files_and_BOQ_sent__c == True)
                    {
                        ib.Install_Stage__c = 'S9-Services';
                        //Added Equipment_ordered_date_plan__c by Anudeep
                        if (ib.Equipment_ordered_date_plan__c!= Null && ib.Planned_Order_Receive_date__c != Null && ib.Planned_Installation_Start_date__c != Null && ib.Planned_Installation_Completion_date__c != Null && ib.S9_Contractor_quotes_install_received__c == True && ib.S9_Customer_approved_GE_quotes__c == True && ib.S9_GE_converted_quotes_were_sent__c == True && ib.S9_Order_Placed_on_Services__c == True)
                        {
                            ib.Install_Stage__c = 'S10-Order&Ship';
                            //Added Equipment_ordered_date_actual__c by Anudeep
                            if (ib.Equipment_ordered_date_actual__c!= Null && ib.Actual_Order_Receive_date__c != Null && ib.SAP_PO_number__c != Null && ib.S10_Order_placed_on_Lighting_equipment__c == True)
                            {
                                ib.Install_Stage__c = 'S11-Install';
                                //Added S11_Site_entered_in_ROI__c by Anudeep
                                if (ib.Inst_Completion_Date__c != Null && ib.Actual_Installation_Completion_date__c != Null && ib.S11_Installation_accepted_by_Customer__c == True && ib.S11_Red_line_drawings_checked_uploaded__c == True && ib.S11_Site_entered_in_ROI__c == True)
                                {
                                    ib.Install_Stage__c = 'S12-Billing';
                                    if (ib.S12_Customer_invoiced__c == True)
                                    {
                                        ib.Install_Stage__c = 'Completed';    
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else
            {
               ib.Install_Stage__c = 'S6-Prepare';
            } 
        } 
        else 
        {
               ib.Install_Stage__c = 'N/A';
        }
    }
}