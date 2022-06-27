global class iLiteWebService {
    webService static List<String> getAccounts(String SSOID) {
        String sfdcUserID = '';
        List<String> lstOutput = new List<String>();
        for(User usr:[SELECT ID FROM USER WHERE FederationIdentifier=:SSOID LIMIT 1])
        {
            sfdcUserID = usr.ID;   
        }
        List<Account> lstAccount = new List<Account>();
        if(sfdcUserID != '')
            lstAccount = [SELECT ID,NAME FROM ACCOUNT WHERE OWNERID=:sfdcUserID];
            for(Account acc :lstAccount)
            {
                lstOutput.add(acc.Name);
            }
        return lstOutput;
    }

    webService static List<String> getContacts(String SSOID, String AccountName) {
        List<Contact> lstContact = new List<Contact>();
        String sfdcUserID = '';
        List<String> lstOutput = new List<String>();
        for(User usr:[SELECT ID FROM USER WHERE FederationIdentifier=:SSOID LIMIT 1])
        {
            sfdcUserID = usr.ID;   
        }
        List<Account> lstAccount = new List<Account>();
        if(sfdcUserID != '')
        {
            lstAccount = [SELECT ID,NAME FROM ACCOUNT WHERE OWNERID=:sfdcUserID AND NAME=:AccountName LIMIT 1];
            if(lstAccount.size() >0)
            {
                lstContact = [SELECT FirstName,LastName,eMail,Phone,OtherPhone FROM CONTACT WHERE ACCOUNTID=:lstAccount[0].ID];
                for(Contact con:lstContact)
                {
                     lstOutput.add(con.FirstName + '&&&' + con.LastName + '&&&' + con.eMail + '&&&' + con.Phone + '&&&' + con.OtherPhone);       
                }
            }
        }
        return lstOutput;
    }
}