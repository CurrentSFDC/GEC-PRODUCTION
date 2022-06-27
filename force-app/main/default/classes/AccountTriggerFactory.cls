public without sharing class AccountTriggerFactory {

	public static void beforeIntegration ( Map<id, Account> oldAccMap, Map<id, Account> newAccMap, List<Account> accList ){

		AccountMethods.updateCustomerNumbers( accList );
		AccountMethods.updateCustomerCodes(oldAccMap, newAccMap, accList );
		AccountMethods.updateAccountOwners(oldAccMap, newAccMap, accList );
	}

	public static void afterIntegration ( Map<id, Account> oldAccMap, Map<id, Account> newAccMap, List<Account> accList ){

		set<id> agentSet  = new Set<id>();
		set<id> hierarchySet  = new Set<id>();
		set<id> parAgentSet  = new Set<id>();
		set<string> custnoSet  = new Set<string>();

		for ( Account acc : accList ){
			
			// QUEUE UP ACCOUNTS FOR STRATEGIC HIERARCHY ASSIGNMENT

			if ( Trigger.isInsert || Trigger.isDelete ){
				//if (  ( acc.Account_Group__c == 'ZSTG' || acc.Account_Group__c == 'ZSH5' ) && acc.GE_LGT_EM_SAP_Customer_Number__c != null && acc.SAP_Parent_Customer_No__c != null ){
				hierarchySet.add(acc.Id);
				custnoSet.add( acc.SAP_Parent_Customer_No__c );
				//custnoSet.add(acc.GE_LGT_EM_SAP_Customer_Number__c );
				custnoSet.add(acc.Customer_Integration_Key__c );
				//}
			}

			if ( Trigger.isUpdate ){

				//if ( oldAccMap.get(acc.id).Account_Group__c != newAccMap.get(acc.id).Account_Group__c ){

				//if ( ( oldAccMap.get(acc.id).Account_Group__c == 'ZSTG' || oldAccMap.get(acc.id).Account_Group__c == 'ZSH5' ) && newAccMap.get(acc.id).Account_Group__c != 'ZSTG' && newAccMap.get(acc.id).Account_Group__c != 'ZSH5' ){
				hierarchySet.add(acc.Id);
				custnoSet.add( acc.Customer_Integration_Key__c );
				custnoSet.add( acc.SAP_Parent_Customer_No__c  );
				//}

				/*//if ( ( newAccMap.get(acc.id).Account_Group__c == 'ZSTG' ||  newAccMap.get(acc.id).Account_Group__c == 'ZSH5' ) && oldAccMap.get(acc.id).Account_Group__c != 'ZSTG' && oldAccMap.get(acc.id).Account_Group__c != 'ZSH5' ){
                    hierarchySet.add(acc.id);
                    custnoSet.add( acc.GE_LGT_EM_SAP_Customer_Number__c  );
                    custnoSet.add( acc.SAP_Parent_Customer_No__c  );
                //}
            //}

            //if ( oldAccMap.get(acc.id).GE_LGT_EM_SAP_Customer_Number__c != newAccMap.get(acc.id).GE_LGT_EM_SAP_Customer_Number__c || oldAccMap.get(acc.id).SAP_Parent_Customer_No__c != newAccMap.get(acc.id).SAP_Parent_Customer_No__c ){

                //if ( acc.Account_Group__c == 'ZSTG' || acc.Account_Group__c == 'ZSH5' ){
                    hierarchySet.add(acc.id);
                    custnoSet.add( oldAccMap.get(acc.id).GE_LGT_EM_SAP_Customer_Number__c );
                    custnoSet.add( newAccMap.get(acc.id).GE_LGT_EM_SAP_Customer_Number__c );
                    custnoSet.add( oldAccMap.get(acc.id).SAP_Parent_Customer_No__c );
                    custnoSet.add( newAccMap.get(acc.id).SAP_Parent_Customer_No__c );
                //}
            //}*/
			}
			
			// 	QUEUE UP ACCOUNTS FOR AGENT TYPE ASSIGNMENT

			if ( trigger.isInsert || trigger.isDelete ) {

				if ( acc.ParentId != null ){
					parAgentSet.add(acc.ParentId);
				}
			}

			if ( trigger.isUpdate ){
								
				if ( oldAccMap.get(acc.id).ParentId != newAccMap.get(acc.id).ParentId ){
					parAgentSet.add( newAccMap.get(acc.id).ParentId == null ? oldAccMap.get(acc.id).ParentId : newAccMap.get(acc.id).ParentId );
				}

				if ( acc.ParentId != null ){

					if ( oldAccMap.get(acc.id).GE_LGT_Architecture__c != newAccMap.get(acc.id).GE_LGT_Architecture__c ||
							oldAccMap.get(acc.id).GE_LGT_Controls__c != newAccMap.get(acc.id).GE_LGT_Controls__c ||
							oldAccMap.get(acc.id).Lamp_Ballast__c != newAccMap.get(acc.id).Lamp_Ballast__c ||
							oldAccMap.get(acc.id).Others__c != newAccMap.get(acc.id).Others__c ||
							oldAccMap.get(acc.id).GE_LGT_Roadway__c != newAccMap.get(acc.id).GE_LGT_Roadway__c ||
							oldAccMap.get(acc.id).GE_LGT_C_I__c != newAccMap.get(acc.id).GE_LGT_C_I__c ||
							oldAccMap.get(acc.id).GE_LGT_Utility__c != newAccMap.get(acc.id).GE_LGT_Utility__c ||
							oldAccMap.get(acc.id).GE_LGT_DOT__c != newAccMap.get(acc.id).GE_LGT_DOT__c ||
							oldAccMap.get(acc.id).GE_LGT_Sports__c != newAccMap.get(acc.id).GE_LGT_Sports__c ){
						parAgentSet.add(acc.ParentId);
					}
				}
			}
		}
		custnoSet.remove(null);
		hierarchySet.remove(null);
		parAgentSet.remove(null);

		if ( hierarchySet.size() > 0 ){
			AccountMethods.updateStrategicHierarchy(custnoSet, hierarchySet);
		}
		
		if ( parAgentSet.size() > 0 ){
			AccountMethods.updateParentAgentTypes(parAgentSet);
		}		
	}
}