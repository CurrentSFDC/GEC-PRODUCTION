/*
Class - CSMTrackerTriggerHelper
Test Class - DaintreeLicensingTests
Author - Dharmendra Oswal
Purpose - This class is used by the Trigger (After Update) on CSM Tracker, and serves the following 3 functionalities:
1. Order Update Notifications (Method updateOrder)
2. Validate the following for finish build on CSM Tracker, under appropriate business cases:
	->For New CSM, there should be exactly one access record on the parent asset before build is finished
	->For New CSM, the CSM Username and CSM Password should be filled on the corresponding access record
	->For On Premise Add-On, Renewal and Add-On with Renewal, if the 'Attach License File?' indicates 'YES', then exactly one 
	  License file attachment should be available on the record
3. Send customer notifications after validations, for New CSM, and for On Prem Renewal/Add-On with attachments

Revision History(Date, Version, author, comments):
*******************************************************************
06 SEP 2018, Version 1.0, Dharmendra Oswal, Initial Version 
*/
public class CSMTrackerTriggerHelper {
    
    static Map<string, string> refSKUs;
    
    //This method serves as the main entry point for the trigger on CSM Tracker. It identifies and isolates records to be 
    //processed for different logic: Order update, Build finish for New CSM, Build finish for On Prem with attachment
    public static void processTrackers(list<Daintree_Order_Tracker__c> oldTrackerList, list<Daintree_Order_Tracker__c> newTrackerList)
    {
        List<Daintree_Order_Tracker__c> trackerListUpdateOrderOld = new List<Daintree_Order_Tracker__c>{};
        List<Daintree_Order_Tracker__c> trackerListUpdateOrderNew = new List<Daintree_Order_Tracker__c>{};
        List<Daintree_Order_Tracker__c> trackerListNewCsm = new List<Daintree_Order_Tracker__c>{};
        List<Daintree_Order_Tracker__c> trackerListOnPremAddon = new List<Daintree_Order_Tracker__c>{};
        List<Daintree_Order_Tracker__c> trackerListOnPremRenewal = new List<Daintree_Order_Tracker__c>{};
        List<Daintree_Order_Tracker__c> trackerListOnPremRenewalWithAddon = new List<Daintree_Order_Tracker__c>{};
        List<Id> parentAssetIdList = new List<Id>{};
            
        for (integer i = 0; i < newTrackerList.size(); i++)
        {
            if (newTrackerList[i].Order_Products__c != oldTrackerList[i].Order_Products__c)
            {
                trackerListUpdateOrderOld.add(oldTrackerList[i]);
                trackerListUpdateOrderNew.add(newTrackerList[i]);
            }
            
            if ((newTrackerList[i].Finish_Build__c != oldTrackerList[i].Finish_Build__c) &&
                (newTrackerList[i].Finish_Build__c == TRUE))
            {
                if ((newTrackerList[i].Order_Type__c == 'New CSM') &&
                    ((newTrackerList[i].CSM_License_Location__c == 'ON CLOUD') ||
                	 (newTrackerList[i].CSM_License_Location__c == 'ON PREMISE')))
                {
                    trackerListNewCsm.add(newTrackerList[i]);
                    if (newTrackerList[i].CSM_License_Asset__c != NULL) 
                        parentAssetIdList.add(newTrackerList[i].CSM_License_Asset__c);                   
                }
                else if ((newTrackerList[i].CSM_License_Location__c == 'ON PREMISE') &&
                         (newTrackerList[i].Attach_License_File__c == 'YES'))
                {
                    if (newTrackerList[i].Order_Type__c == 'Add-On')
                        trackerListOnPremAddon.add(newTrackerList[i]);
                    else if (newTrackerList[i].Order_Type__c == 'Renewal')
                        trackerListOnPremRenewal.add(newTrackerList[i]);
                    else if (newTrackerList[i].Order_Type__c == 'Renewal with Add-On')
                        trackerListOnPremRenewalWithAddon.add(newTrackerList[i]);                   
                }
            }           
        }
        
        if (trackerListUpdateOrderNew.size() > 0) updateOrder(trackerListUpdateOrderOld, trackerListUpdateOrderNew);
        if (trackerListNewCsm.size() > 0) sendEmailNewCsm(trackerListNewCsm, parentAssetIdList);
        if (trackerListOnPremAddon.size() > 0) sendEmailWithLicenseFile(trackerListOnPremAddon, 1);
        if (trackerListOnPremRenewal.size() > 0) sendEmailWithLicenseFile(trackerListOnPremRenewal, 2);
        if (trackerListOnPremRenewalWithAddon.size() > 0) sendEmailWithLicenseFile(trackerListOnPremRenewalWithAddon, 3);
    }
    
    // This method processes records where an update on ordered products is identified- Quantity change, product added or 
    // removed. It sends email notification indicating what was changed.
    private static void updateOrder(list<Daintree_Order_Tracker__c> trackerListOld, list<Daintree_Order_Tracker__c> trackerListNew)
    {
        if (refSKUs == NULL) refSKUs = getReferenceSKUs();
        string licenseCreatorEmail = getCreatorEmail();
        list<Messaging.SingleEmailMessage> orderUpdateNotifications = new list<Messaging.SingleEmailMessage>{};
        final string productsTableHead = '<table style="width:100%" border="1">' +
    					   		   		 '<tr>' +
       							  		 '<th style ="text-align:left">SKU</th>' +
       						     	     '<th style ="text-align:left">Quantity</th>' +
             					         '<th style ="text-align:left">Material Description</th>' + 
    						             '</tr>';
    	final string tableTail =         '</table>';
        final string updateTableHead   = '<table style="width:100%" border="1">' +
    						       		 '<tr>' +
       							   		 '<th style ="text-align:left">SKU</th>' +
       						       		 '<th style ="text-align:left">Material Description</th>' +
       					           		 '<th style ="text-align:left">Previous Quantity</th>' + 
               					   		 '<th style ="text-align:left">New Quantity</th>' +
               					   		 '<th style ="text-align:left">Change</th>' +
    					           		 '</tr>';
        
        for (integer z = 0; z < trackerListNew.size(); z++)
        {
    		string productsTable = '';
            integer numOfProducts = 0;
            list<string> fullOrder;
            Map<string, string> LicenseProductsNewMap = new Map<string, string>{};

        	if (trackerListNew[z].Order_Products__c != NULL) 
            {
         		fullOrder = trackerListNew[z].Order_Products__c.split(',');
        		numOfProducts = fullOrder.size(); 
                system.debug(fullOrder);
            }
       	
        	if (numOfProducts > 0) 
    		{  
        		list<string> orderItem;                                   
        		for (integer i = 0; i < numOfProducts; i++)
        		{
           			orderItem = fullOrder[i].split('-');
                	system.debug(orderItem);
                    string SKU = orderItem[0].trim(); 
           			if (orderItem.size() == 2 && refSKUs.containsKey(SKU)) 
           			{
                        string quantity = formatQuantity(orderItem[1]); 
                        productsTable = productsTable + addTableRow(new list<string>{SKU, quantity, refSKUs.get(SKU)});
                        LicenseProductsNewMap.put(SKU, quantity);
           			}
        		}
    		}
            else
            {
                System.debug('No order products found for update on Sales Order ' 
                             + trackerListNew[z].SO_Number__c);
            }
             
            string updateTable = '';
            numOfProducts = 0;
            
        	if (trackerListOld[z].Order_Products__c != NULL) 
            {
         		fullOrder = trackerListOld[z].Order_Products__c.split(',');
        		numOfProducts = fullOrder.size(); 
                system.debug(fullOrder);
            }
       	
        	if (numOfProducts > 0) 
    		{  
        		list<string> orderItem;                                   
        		for (integer i = 0; i < numOfProducts; i++)
        		{
           			orderItem = fullOrder[i].split('-');
                	system.debug(orderItem);
                    string SKU = orderItem[0].trim(); 
           			if (orderItem.size() == 2 && refSKUs.containsKey(SKU))  
           			{
                        string quantity = formatQuantity(orderItem[1]);
                        if (LicenseProductsNewMap.containsKey(SKU))
                        {
                            if (quantity != LicenseProductsNewMap.get(SKU))
                            {
                                updateTable = updateTable + addTableRow(new list<string>{SKU, refSKUs.get(SKU), quantity, 
                                    									LicenseProductsNewMap.get(SKU), 'Quantity Updated'});
                            }
                            LicenseProductsNewMap.remove(SKU);
                        }
                        else
                        {
                           updateTable = updateTable + addTableRow(new list<string>{SKU, refSKUs.get(SKU), quantity, 
                                    							   '0', 'Product Removed'}); 
                        }                        
           			}
        		}                   
    		}
            else
            {
                System.debug('No previous license products found for update on Sales Order ' 
                             + trackerListNew[z].SO_Number__c);
            }
            
            if (LicenseProductsNewMap.size() > 0)
            {
               for (string newSKU: LicenseProductsNewMap.keyset())
               {
                   updateTable = updateTable + addTableRow(new list<string>{newSKU, refSKUs.get(newSKU), '0', 
                                    					   LicenseProductsNewMap.get(newSKU), 'Product Added'}); 
               }
            }
            
            system.debug(updatetable);
            if (updateTable == '')
            {
                System.debug('No license products changed for update on Sales Order ' 
                             + trackerListNew[z].SO_Number__c);
            }
            else
            {
                productsTable = productsTableHead + productsTable + tableTail;
                updateTable = updateTableHead + updateTable + tableTail;
                Messaging.SingleEmailMessage orderUpdateNotif = new Messaging.SingleEmailMessage();
                string[] toAddresses = new string[]{'daintree.orders@ge.com', 'matthew.gugumuck@ge.com'};
                string trackerURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + trackerListNew[z].id;
                if ((trackerListNew[z].status__c == 'Approved' ||
                    trackerListNew[z].status__c == 'Built') &&
                    licenseCreatorEmail != '')
                {	
                    toAddresses.add(licenseCreatorEmail);
                }
                orderUpdateNotif.setToAddresses(toAddresses);
            	orderUpdateNotif.setSubject('Update on eLight Daintree Digital Order SO: '
                                        + trackerListNew[z].SO_Number__c
                                        + ' / PO: '
                                        + trackerListNew[z].PO_Number__c);
                orderUpdateNotif.setHtmlBody('The Sales Order '
                                             + '<a href = "'
                                             + trackerURL
                                             + '">'
                                             + trackerListNew[z].SO_Number__c
                                             + '</a>'
                                             + ' for '
                                             + trackerListNew[z].End_User_Co__c
                                             + ' has been updated. Below is a summary of the update:'
                                             + '<br/>'
                                             + updateTable
                                             + '<br/>'
                                             + 'Following are the new Licensing Requirements:'
                                             + '<br/>'
                                             + productsTable);
                orderUpdateNotifications.add(orderUpdateNotif);                                             
            }
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(orderUpdateNotifications, False);
        for(Messaging.SendEmailResult r: results)
		{
    		if (!r.success) 
            {
				system.debug('Sending Order update notification falied: ' + r.errors[0].message);
    		}
		}           
    }
    
    //This method processes records where build is finished for order type 'New CSM'. Appropriate notification is sent to
    //customer depending on 'ON CLOUD' or 'ON PREMISE', containing the unencrypted CSM Username and Password.
    private static void sendEmailNewCsm(list<Daintree_Order_Tracker__c> trackerListNew, List<Id> parentAssetIdList)
    {
        Daintree_Licensing__c defaultCS = Daintree_Licensing__c.getOrgDefaults();
        List<Messaging.SingleEmailMessage> custNotifications = new list<Messaging.SingleEmailMessage>{};
        List<Daintree_Order_Tracker__c> trackerList = new List<Daintree_Order_Tracker__c>{};    
        
        Map<Id, Asset> assetMap = new Map<Id, Asset>([select (select GE_DT_CSM_Login__c, GE_DT_CSM_Password__c 
                                                                from childAssets) from Asset where Id IN :parentAssetIdList]);    
        for (Daintree_Order_Tracker__c tracker: trackerListNew)
        {	
            if (tracker.CSM_License_Asset__c == NULL)
            {
                tracker.addError('Access Record not found');              
            }
            else if (!assetMap.containsKey(tracker.CSM_License_Asset__c))
            {
				tracker.addError('Access Record not found');                
            }
            else
            {
                List<Asset> accessRecords = assetMap.get(tracker.CSM_License_Asset__c).childAssets;
                Integer numAccessRecords = accessRecords.size();
                if (numAccessRecords == 0)
                {
					tracker.addError('Access Record not found');                    
                }
                else if (numAccessRecords > 1)
                {
					tracker.addError('Multiple Access Records found(' + numAccessRecords + ')');                    
                }
                else if (String.isBlank(accessRecords[0].GE_DT_CSM_Login__c) || 
                         String.isBlank(accessRecords[0].GE_DT_CSM_Password__c))
                {
                    tracker.addError('The CSM Login and/or CSM Password are blank');
                }
                else
                {
                    Messaging.SingleEmailMessage custNotif = new Messaging.SingleEmailMessage();
                    //VAR Email address on the parent asset 
            		String[] toAddresses = new String[] {tracker.eLight_Submitter_Email__c};
            		//Daintree Orders email address
            		String[] bccAddresses = new String[] {'daintree.orders@ge.com', 'matthew.gugumuck@ge.com'};   
					custNotif.setToAddresses(toAddresses);
            		custNotif.setBccAddresses(bccAddresses);
            		//Org wide email address to be used as 'From' address
            		custNotif.setOrgWideEmailAddressId(defaultCS.Org_Wide_email_address_ID__c);
                    if (tracker.CSM_License_Location__c == 'ON CLOUD')
                    {
                        custNotif.setSubject('BEMaaS Provisioning Notification');
                        custNotif.setHtmlBody('Dear Sir/Madam,<br/><br/>' 
                                          	+ 'This email is to notify you that the BEMaaS system ordered in your Purchase Order '
                                          	+ tracker.PO_Number__c 
                                          	+ ' / GE Sales Order '
                                     	  	+ '<a href = "'
                                     	  	+ defaultCS.eLight_Order_Link_Static__c
                                     	  	+ tracker.SO_Number__c
                                     	  	+ '">'
                                     	  	+ tracker.SO_Number__c
                                     	  	+ '</a>'
                                     	  	+ ' has now been provisioned and is available for your use. The access details for the system are described below,'
                                          	+ ' but please note we have not explicitly included the Domain Name for security reasons.<br/><br/>'
                                          	+ '•    Domain Name: As requested (please prefix with https://)<br/>'
                                          	+ '•    Username: '
                                          	+ accessRecords[0].GE_DT_CSM_Login__c 
                                     	  	+ '<br/>'
                                          	+ '•    Password: '
                                          	+ accessRecords[0].GE_DT_CSM_Password__c 
                                     	  	+ '<br/><br/>'
                                          	+ 'Do not hesitate to contact us should you have any questions.<br/><br/>'
                                          	+ 'Respectfully,<br/>'
                                          	+ 'Daintree Licensing Team<br/>'
                                          	+ '<a href = "mailto:daintree.orders@ge.com">daintree.orders@ge.com</a><br/>'
                                          	+ 'T: '
                                          	+ defaultCS.Daintree_Orders_Phone__c 
                                       	  	+ '<br/><br/>'
                                          	+ 'For technical support, please contact '
                                          	+ defaultCS.Daintree_Support_Phone__c
                                          	+ ' or <a href = "mailto:daintree.support@ge.com">daintree.support@ge.com</a>.');
                    }
                    else if (tracker.CSM_License_Location__c == 'ON PREMISE')
                    {
                        custNotif.setSubject('ON PREMISE Server Shipment Notification');
                        custNotif.setHtmlBody('Dear Sir/Madam,<br/><br/>' 
                                          	+ 'This email is to notify you that the ON PREMISE Server ordered in your Purchase Order '
                                          	+ tracker.PO_Number__c 
                                          	+ ' / GE Sales Order '
                                     	  	+ '<a href = "'
                                     	  	+ defaultCS.eLight_Order_Link_Static__c
                                     	  	+ tracker.SO_Number__c
                                     	  	+ '">'
                                     	  	+ tracker.SO_Number__c
                                     	  	+ '</a>'
                                     	  	+ ' has now been provisioned and is is being prepared for shipment. The access details for' 
                                            + ' the server are described below:<br/><br/>'
                                          	+ '•    Username: '
                                          	+ accessRecords[0].GE_DT_CSM_Login__c 
                                     	  	+ '<br/>'
                                          	+ '•    Password: '
                                          	+ accessRecords[0].GE_DT_CSM_Password__c 
                                     	  	+ '<br/><br/>'
                                          	+ 'Do not hesitate to contact us should you have any questions.<br/><br/>'
                                          	+ 'Respectfully,<br/>'
                                          	+ 'Daintree Licensing Team<br/>'
                                          	+ '<a href = "mailto:daintree.orders@ge.com">daintree.orders@ge.com</a><br/>'
                                          	+ 'T: '
                                          	+ defaultCS.Daintree_Orders_Phone__c 
                                       	  	+ '<br/><br/>'
                                          	+ 'For technical support, please contact '
                                          	+ defaultCS.Daintree_Support_Phone__c
                                          	+ ' or <a href = "mailto:daintree.support@ge.com">daintree.support@ge.com</a>.');
                    }
					
                    custNotifications.add(custNotif);
                    trackerList.add(tracker);
                }              
            }                                                          
        }
 		
        if (custNotifications.size() > 0)
        {
        	Messaging.SendEmailResult[] results = Messaging.sendEmail(custNotifications, False);
        	for(integer i = 0; i < custNotifications.size(); i++)
			{
    			if (!results[i].success) 
            	{
                    trackerList[i].addError(results[i].errors[0].getMessage());
    			}
			}              
        }         
    }
    
    //This method processes records where build is finished for ON PREMISE with attachment. Appropriate notification is sent to
    //customer depending on order type (Add-On, Renewal or Renewal with Add-On), with the license file sent as an attachment.
    private static void sendEmailWithLicenseFile(list<Daintree_Order_Tracker__c> trackerListNew, Integer type)
    {
        Daintree_Licensing__c defaultCS = Daintree_Licensing__c.getOrgDefaults();
        List<Messaging.SingleEmailMessage> custNotifications = new list<Messaging.SingleEmailMessage>{};
        List<Daintree_Order_Tracker__c> trackerList = new List<Daintree_Order_Tracker__c>{};    
        
        List<Attachment> licenseFileList = [Select name, body, parentId from Attachment where parentId IN :trackerListNew and name like '%.license'];    
        Id templateId = getTemplateId(type);    
    
        for (Daintree_Order_Tracker__c tracker: trackerListNew)
        {
            List<messaging.EmailFileAttachment> licenseFiles = new List<Messaging.Emailfileattachment>();
            for (attachment a: licenseFileList)
            {
                if (a.parentId == tracker.Id) 
                {
                    Messaging.Emailfileattachment licenseFile = new Messaging.Emailfileattachment();
       				licenseFile.setFileName(a.Name);
       				licenseFile.setBody(a.Body);
			        licenseFiles.add(licenseFile);
                }
            }
            Integer numOfLicensefiles = licenseFiles.size();
            if (numOfLicensefiles == 0)
            {
				tracker.addError('License File Attachment not found');                    
            }
            else if (numOfLicensefiles > 1)
            {
				tracker.addError('Multiple License File Attachments found(' + numOfLicensefiles + ')');                    
            }
            else
            {
                Messaging.SingleEmailMessage custNotif = new Messaging.SingleEmailMessage();
                //VAR Email address on the parent asset 
            	String[] toAddresses = new String[] {tracker.eLight_Submitter_Email__c};
            	//Daintree Orders email address
            	String[] bccAddresses = new String[] {'daintree.orders@ge.com', 'matthew.gugumuck@ge.com'};   
				custNotif.setToAddresses(toAddresses);
            	custNotif.setBccAddresses(bccAddresses);
            	//Org wide email address to be used as 'From' address
            	custNotif.setOrgWideEmailAddressId(defaultCS.Org_Wide_email_address_ID__c);
                custNotif.setTargetObjectId(defaultCS.CSM_License_Creator__c);
                custNotif.setTreatTargetObjectAsRecipient(False);
                custNotif.setSaveAsActivity(False);
				custNotif.setTemplateId(templateId);
                custNotif.setWhatId(tracker.Id);
				custNotif.setFileAttachments(licenseFiles);
                custNotifications.add(custNotif);
                trackerList.add(tracker);
            }                                                                        
        }
 		
        if (custNotifications.size() > 0)
        {
        	Messaging.SendEmailResult[] results = Messaging.sendEmail(custNotifications, False);
        	for(integer i = 0; i < custNotifications.size(); i++)
			{
    			if (!results[i].success) 
            	{
                    trackerList[i].addError(results[i].errors[0].getMessage());
    			}
			}              
        }         
    }
    
    //This utility method retrieves the list of Daintree licensing SKUs along with their Material descriptions, into a Map 
    public static map<string, string> getReferenceSKUs()
    {
        Map<string, string> referenceSKUs = new Map<String, String>{};
        list<GE_LGT_EM_MaterialMaster__c> refMaterialMasters = [select GE_LGT_EM_SAP_MaterialNumber__c, 
                                                                GE_LGT_EM_MaterialDescription__c from 
                                                                GE_LGT_EM_MaterialMaster__c where 
                                                                License_Flag_text__c = 'Daintree CSM'];
        if (refMaterialMasters.size() > 0)
        {
            for (GE_LGT_EM_MaterialMaster__c m: refMaterialMasters)
            {
                if (m.GE_LGT_EM_SAP_MaterialNumber__c != NULL)
                {
                    referenceSKUs.put(m.GE_LGT_EM_SAP_MaterialNumber__c, 
                                      m.GE_LGT_EM_MaterialDescription__c == NULL? '':m.GE_LGT_EM_MaterialDescription__c);
                }
                
            }
        }
        else
        {
            System.debug('No Daintree License products found');
        }
        return referenceSKUs;
    }
    
    //This utility method wraps a list of strings as a single HTML table row 
    private static string addTableRow (list<string> rowElements)
    {
        string tableRow = '';
        for (string rowElement: rowElements)
        {
            tableRow = tableRow + '<td>' + rowElement + '</td>';
        }
        tableRow = '<tr>' + tableRow + '</tr>';
        return tableRow;
    }
    
    //This utility method receives the quantity of product ordered, and properly formats it by removing any decimals, zeroes
    //or spaces
    public static string formatQuantity (string quantity)
    {
        integer quantityNum;
        try
        {
            quantityNum = integer.valueOf(quantity.trim());
        }
        catch(Exception E)
        {
           quantityNum = 1; 
        }
        
        return string.valueOf(quantityNum);
    }
    
    //This utility method retrieves the email address of the CSM License creator, using the custom setting field
    private static string getCreatorEmail()
    {
        Daintree_Licensing__c defaultCS = Daintree_Licensing__c.getOrgDefaults();
        string creatorEmail;
        
        try
        {
            creatorEmail = [select email from user where id = :defaultCS.CSM_License_Creator__c].email;
        }
        catch (Exception E)
        {
            System.debug('Error while getting CSM License Creator email address: ' + E.getMessage());
            creatorEmail = '';
        }
        return creatorEmail;
    }
    
    //This utility method retrieves the template ID of the appropriate email template for customer notification for ON PREMISE
    //with attachment, depending on the order type
    private static Id getTemplateId(Integer type)
    {
        Id templateId;
        string templateDeveloperName;
        
        If (type == 1)
        {
            templateDeveloperName = 'Daintree_Addon_with_Attachment';           
        }
        else If (type == 2)
        {
            templateDeveloperName = 'Daintree_Renewal_with_Attachment';
        }
        else If (type == 3)
        {
            templateDeveloperName = 'Daintree_Renewal_Addon_with_Attachment';
        }
        
        try
        {
            templateId = [select Id from emailTemplate where developerName = :templateDeveloperName].Id;
        }
        catch (Exception E)
        {
            System.debug('Error while getting Template Id: ' + E.getMessage());
        }
        return templateId;
    }                        
}