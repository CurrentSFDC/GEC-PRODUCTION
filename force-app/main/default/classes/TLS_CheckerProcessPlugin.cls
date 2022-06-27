global class TLS_CheckerProcessPlugin implements Process.Plugin {
    // The main method called by the Flow at run time.
global Process.PluginResult invoke(Process.PluginRequest request) { 

    //  ERROR Check: If ApexPages is NULL then the Login Flow is likely set to run in the Lightning Runtime which will not work
    if( ApexPages.currentPage() == NULL ) {
        // Return misconfigured message to Flow
        Map<String,Object> error = new Map<String,Object>(); 
        error.put('Is TLS1.0', true);
        error.put('Message', 'CONFIG ERROR: Ensure the Login Flow is NOT running in Lightning Runtime');
        error.put('Help Page', '');
        error.put('Help Page Url Text', '');
        return new Process.PluginResult(error); 
    } 
    
    // Get the Cipher Suite
    String cipher_suite = ApexPages.currentPage().getHeaders().get('CipherSuite');
    System.debug('STONE: ;' + cipher_suite);

    //Check if TLS1.1 and if so get the message/help page
    TLS_Checker tlsChecker = new TLS_Checker(cipher_suite);
    String helpPage = (tlsChecker.isTlsVersionOneDotOne()) ? tlsChecker.getHelpPage() : '';
    String message  = (tlsChecker.isTlsVersionOneDotOne()) ? tlsChecker.getMessage() : '';
    String helpUrlLinkText = (tlsChecker.isTlsVersionOneDotOne()) ? tlsChecker.getHelpUrlLinkText() : '';
        
    // Return values to Flow
    Map<String,Object> result = new Map<String,Object>(); 
        result.put('Is TLS1.0', tlsChecker.isTlsVersionOneDotOne());
        result.put('Message', message);
        result.put('Help Page', helpPage);
        result.put('Help Page Url Text', helpUrlLinkText);
        return new Process.PluginResult(result); 
    } 

    // Returns the describe information for the interface
    global Process.PluginDescribeResult describe() { 
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'TLS1.0 Checker';
        result.Tag = 'Login Plugin';
        
        //Set userid as an input parameter. Not used currently but it's available from the flow so requesting it.
        result.inputParameters = new 
           List<Process.PluginDescribeResult.InputParameter>{ 
               new Process.PluginDescribeResult.InputParameter('userid', 
               Process.PluginDescribeResult.ParameterType.STRING, true) 
            }; 

       //Returns the answer to the TLS1.0 check and message/helpPage for the user's profile if set in the Custom MetaData settings
       result.outputParameters = new 
         List<Process.PluginDescribeResult.OutputParameter>{              
            new Process.PluginDescribeResult.OutputParameter('Is TLS1.0', 
                Process.PluginDescribeResult.ParameterType.BOOLEAN),
            new Process.PluginDescribeResult.OutputParameter('Message', 
                Process.PluginDescribeResult.ParameterType.STRING), 
            new Process.PluginDescribeResult.OutputParameter('Help Page', 
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('Help Page Url Text', 
                Process.PluginDescribeResult.ParameterType.STRING)
                }; 
      
      return result; 
    }
}