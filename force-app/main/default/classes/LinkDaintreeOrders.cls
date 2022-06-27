/*
Class - LinkDaintreeOrders
Test Class - DaintreeLicensingTests
Author - Dharmendra Oswal
Purpose - This is a daily scheduled, Schedulable apex class, that populates the 'Order' lookup field on new CSM tracker records.
		  Also, it attempts to populates the 'Opportunity' lookup field on all CSM Trackers where its not set.
for the day.

Revision History(Date, Version, author, comments):
*******************************************************************
21 SEP 2018, Version 1.0, Dharmendra Oswal, Initial Version 
*/
public class LinkDaintreeOrders implements System.Schedulable{
	public void execute(System.SchedulableContext SC)
    {
        Daintree_Licensing__c defaultCS = Daintree_Licensing__c.getOrgDefaults();
		
		string orderSummary = linkOrders();
        string oppSummary = linkOpportunities();
        string summary = orderSummary + '\n' + oppSummary;
        
        Messaging.SingleEmailMessage summaryNotif = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {defaultCS.Batch_Monitor_Email__c};
        summaryNotif.setToAddresses(toAddresses);
        summaryNotif.setSubject('Daintree CSM Trackers linking Summary for ' + dateTime.now().format('MM/dd/YYYY'));
    	summaryNotif.setplainTextBody(summary);
        Messaging.SendEmailResult[] notifResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {summaryNotif}, False);
        
        if (notifResults[0].success) 
		{
    		System.debug('The Daintree daily notification email was sent successfully.');
		} 
		else 
		{
    		System.debug('The Daintree daily notification sending failed: ' + notifResults[0].errors[0].message+ '\n' + summary);
		}
    }
    
    private static string linkOrders()
    {
        Set<string> soSet = new Set<string>{};
        Map<Id, string> trackerMap= new Map<Id, string>{};
        List<Daintree_Order_Tracker__c> trackersToUpdate = new List<Daintree_Order_Tracker__c>{};
        string failureMessages= '';
        integer numSuccess = 0;
        integer numFailure = 0;
                
        List<Daintree_Order_Tracker__c> trackersToLink = [select CSM_License_asset__r.name, order_flag__c, SO_Number__c, 
                                                          Order__c from Daintree_Order_Tracker__c where order_flag__c = True];
        
        for (Daintree_Order_Tracker__c tracker: trackersToLink)
        {
            string salesOrderNo = (tracker.SO_Number__c == NULL)? 
                				   '':tracker.SO_Number__c.replaceFirst('^[0 ]+','');
            trackerMap.put(tracker.Id, salesOrderNo);
            if (salesOrderNo != '')
            {
                soSet.add(salesOrderNo);
            }
        }
        
        List<Order> orderList = [select GE_Order_NO__c from order where GE_Order_NO__c IN :soSet];

        for (Daintree_Order_Tracker__c tracker: trackersToLink)
        {
            string salesOrderNo = trackerMap.get(tracker.Id);
            if (salesOrderNo == '')
            {
                failureMessages = failureMessages + 'Id ' + tracker.Id + tracker.Id + ', Asset ' 
                    			  + tracker.CSM_License_asset__r.name + ': ' + 'Blank/Invalid Sales Order No\n';
                numFailure++;                
            }
            else
            {
            	boolean orderFound = False;
            	for (order o: orderList)
            	{
                	if (o.GE_Order_NO__c == salesOrderNo)
                	{
                    	orderFound = True;
                    	tracker.Order__c = o.Id;
                    	tracker.Order_flag__c = False;
                    	trackersToUpdate.add(tracker);
                    	break;
                	}
            	}
            	if (orderFound == False)
            	{
            		failureMessages = failureMessages + 'Id ' + tracker.Id + ', Asset ' + tracker.CSM_License_asset__r.name 
                        			  + ': ' + 'Order (' + tracker.SO_Number__c + ') not found\n';
            		numFailure++;
            	}
            }
        }
        
        Database.saveResult[] results;
        if (trackersToUpdate.size() > 0)
        {
            results = Database.update(trackersToUpdate, False);
            for (integer i = 0; i < trackersToUpdate.size(); i++) 
			{
    			if (!results[i].isSuccess()) 
    			{
					Database.error err = results[i].getErrors()[0];
					failureMessages = failureMessages + 'Id ' + trackersToUpdate[i].Id + ', Asset ' 
                        			  + trackersToUpdate[i].CSM_License_asset__r.name + ': ' + 'DML failed - ' 
                        			  + err.getStatusCode() + ', ' + err.getMessage() + '\n';
                    numFailure++;                  
   				}
                else
                {
                    numSuccess++;
                }
			}
        }
        
        string summary = 'ORDERS LINKING SUMMARY\n\n' + 'Total number of Tracker records in the batch: ' + trackersToLink.size() 
            			+ '\n' + 'Total number of Order records successfully linked: ' + numSuccess + '\n';
        if (failureMessages != '')
        {
            failureMessages = 'Following errors occured(' + numFailure + '):\n' + failureMessages + '\n';
        }
        
        summary = summary + failureMessages;
        return summary;
    }
    
    private static string linkOpportunities()
    {
        List<Daintree_Order_Tracker__c> trackersToUpdate = new List<Daintree_Order_Tracker__c>{};
        string failureMessages= '';
        integer numSuccess = 0;
        integer numFailure = 0;
        integer numOppNotAvailable = 0;
                
        List<Daintree_Order_Tracker__c> trackersToLink = [select CSM_License_asset__r.name, SO_Number__c, Order__r.OpportunityId, 
                                                          Opportunity__c from Daintree_Order_Tracker__c where Opportunity__c = NULL];
        
        for (Daintree_Order_Tracker__c tracker: trackersToLink)
        {
            if (tracker.Order__r == NULL)
            {
             	failureMessages = failureMessages + 'Id ' + tracker.Id + ', Asset ' + tracker.CSM_License_asset__r.name + ': ' 
                    			  + 'Parent Order not set (' + tracker.SO_Number__c + ')\n';
                numFailure++;   
            }
            else if (tracker.Order__r.OpportunityId == NULL)
            {
                numOppNotAvailable++;
            }
            else
            {
                tracker.Opportunity__c = tracker.Order__r.OpportunityId;
                trackersToUpdate.add(tracker);
            }
        }
               
        Database.saveResult[] results;
        if (trackersToUpdate.size() > 0)
        {
            results = Database.update(trackersToUpdate, False);
            for (integer i = 0; i < trackersToUpdate.size(); i++) 
			{
    			if (!results[i].isSuccess()) 
    			{
					Database.error err = results[i].getErrors()[0];
					failureMessages = failureMessages + 'Id ' + trackersToUpdate[i].Id + ', Asset ' 
                        			  + trackersToUpdate[i].CSM_License_asset__r.name + ': ' + 'DML failed - ' 
                        			  + err.getStatusCode() + ', ' + err.getMessage() + '\n';
                    numFailure++;                  
   				}
                else
                {
                    numSuccess++;
                }
			}
        }
        
        string summary = 'OPPORTUNITIES LINKING SUMMARY\n\n' + 'Total number of Trackers records in the batch: ' 
            			+ trackersToLink.size() + '\n' + 'Total number of Opportunity records successfully linked: ' 
            			+ numSuccess + '\n' + 'Total number of Tracker records with Opportunity not set on parent Order record: ' 
            			+ numOppNotAvailable + '\n';
        if (failureMessages != '')
        {
            failureMessages = 'Following errors occured(' + numFailure + '):\n' + failureMessages + '\n';
        }
        
        summary = summary + failureMessages;
        return summary;
    }
}