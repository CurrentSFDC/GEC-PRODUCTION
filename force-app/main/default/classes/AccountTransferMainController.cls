public with sharing class AccountTransferMainController 
{
	//Rashmitha Changed the API vesion from 34 to 45 on 6-Mar-2019 as per 1447 request
    public string oldAccountId = System.currentPagereference().getParameters().get('id');
    public string accountName {get;set;}
    public Id accountId {get; set;}
    public Account oldAccount {get;set;}
    
    public void autoRun(){
        oldAccount=[select name, type, owner.name from Account where Id =: oldAccountId];
       }
    
    
    public PageReference TransferData(){
        if(null!=accountId){
        //Create a database save point to be able to roll back if a insert or update fails during the account transfer
        Savepoint sp = Database.setSavepoint();

        try {
        
                Account SAPAccount = [SELECT Id, Name FROM Account WHERE Id =: accountId];
            
            
            
            
                merge SAPAccount oldAccount;
            
            
            
                 /*********************************************************
                  * Transfer of Account Teams To new Account
                 *********************************************************/
                  
                  List<AccountTeamMember> AccountTeam = [SELECT Id,AccountId,UserId,TeamMemberRole,AccountAccessLevel,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,IsDeleted FROM AccountTeamMember WHERE AccountId = : oldAccountId];
                  
                  
                  //Lists for inserting and deleting partners
                 List<AccountTeamMember> AccountTeamMembersToInsert = new List<AccountTeamMember>();
                 List<AccountTeamMember> AccountTeamMembersToDelete = new List<AccountTeamMember>();
                
                //temporary partner object to use while cloning.
                AccountTeamMember tempAccountTeamMember;
                
                  // Loop through each Account Team Member clone it, update the AccountId
                  // Adds Cloned AccountTeamMembers to AccountTeamMembersToInsert List and old AccountTeamMembers to AccountTeamMembersToDelete List
                  for(AccountTeamMember member : AccountTeam){
                                    tempAccountTeamMember = member.clone(false,false);
                                    tempAccountTeamMember.AccountId = accountId;
                                    AccountTeamMembersToInsert.add(tempAccountTeamMember);
                                    AccountTeamMembersToDelete.add(member);     
                      }
                      
                    if(AccountTeamMembersToInsert.isEmpty()){
                         //No account team members to transfer
                    }else{
                         insert AccountTeamMembersToInsert;
                         delete AccountTeamMembersToDelete;
                    }
                                
                    ApexPages.Message Message = new ApexPages.Message(ApexPages.Severity.INFO,'Transfer Completed. Please click <a href="/' + accountId + '">here</a> to go to the new account.' );
                    ApexPages.addMessage(Message);
                    
            }catch(DMlException e){
                //If there was an error while executing rollback the database and show the error.
                Database.rollback(sp);
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
                ApexPages.addMessage(msg);
            }
        }
                    return null;
            
    }
}