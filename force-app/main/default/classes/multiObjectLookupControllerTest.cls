@IsTest
public class multiObjectLookupControllerTest {
    @IsTest
    public static void testSub(){
       /* String objectName = 'Account';
        String filterField = 'Name';
        String searchString = 'cc';
        String value = '0012F00000jr7O3QAI';
        String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
        
         if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
             system.debug('query'+query);
         } else {
                query += ' WHERE '+filterField+
                		' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';
             system.debug('query'+query);
            }
       // List<RecordsData> recordsDataList = new List<RecordsData>();
        for(SObject s : Database.query(query)) {
	           // recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
	        } */

        
        Test.startTest();
        try
        {
            
            multiObjectLookupController.fetchRecords('Test','Test1','Test2','');
           // multiObjectLookupController.RecordsData obj = new multiObjectLookupController.RecordsData('test','test2');
           // obj.RecordsData();
        }
        catch(exception e)
        {
        }  
        Test.stopTest();
        
    }
    
    @IsTest
    public static void testSub1(){
        
        Test.startTest();
        try
        {
            multiObjectLookupController.fetchRecords('Test','Test1','Test2','');
        }
        catch(exception e)
        {
        }                     Test.stopTest();
        
    }
    
    @IsTest
    public static void testSub2(){
        
        Test.startTest();       
            multiObjectLookupController.RecordsData obj = new multiObjectLookupController.RecordsData('test','test2');
        Test.stopTest();
    }
        
}