public class importDataFromCSVController {
public Blob csvFileBody{get;set;}
public string csvAsString{get;set;}
public String[] csvFileLines{get;set;}
public Account OldAcc{get;set;}
public Account SAPAcc{get;set;}
    
    
  public importDataFromCSVController(){
    csvFileLines = new String[]{};
  }
  
  public void importCSVFile(){
     //Create a database save point to be able to roll back if a insert or update fails during the account transfer
        Savepoint sp = Database.setSavepoint();
  
       try{
           csvAsString = csvFileBody.toString();
           csvAsString =  csvAsString.replaceAll('(\\r)', '');
           csvFileLines = csvAsString.split('\n'); 
            
            
           for(Integer i=0;i<csvFileLines.size();i++){
          
               string[] csvRecordData = csvFileLines[i].split(',');
               
                OldAcc = [SELECT Id, Name, AccountNumber FROM Account WHERE Id =: csvRecordData[0]];
                SAPAcc = [SELECT Id, Name, AccountNumber FROM Account WHERE Id =: csvRecordData[1]];

              merge SAPAcc OldAcc;
           }
           
            ApexPages.Message Message = new ApexPages.Message(ApexPages.severity.INFO, 'Done.');
            ApexPages.addMessage(Message);
           
        }
        catch (Exception e)
        {
         //If there was an error while executing rollback the database and show the error.
            Database.rollback(sp);
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,String.valueOf(e));
            ApexPages.addMessage(errorMessage);
        }  
  }
}