/**
 * Controller used by TLS_WarningMessage component to display TLS warning message if needed
 */
public with sharing class TLS_WarningMessageController {
    public Boolean isTls11  {get; set; }
    public String  message  {get; set; }
    public String  helpPage {get; set; }
    public String  helpUrlLinkText {get; set; }
    public Integer daysBetweenWarning {get; set; }
    public Boolean isMessageProfileSpecific {get; set; }

    /* Constructor
     * Check TLS and set variables used by component   
    */
    public TLS_WarningMessageController() {
        isTls11  = false;
        String tlsVersion = ApexPages.currentPage().getHeaders().get('CipherSuite');
        
        TLS_Checker checker = new TLS_Checker(tlsVersion);
        isTls11  = checker.isTlsVersionOneDotOne();
        message = (isTls11) ? checker.getMessage() : '';
        helpPage = (isTls11) ? checker.getHelpPage() : '';
        helpUrlLinkText = (isTls11) ? checker.getHelpUrlLinkText() : '';
        daysBetweenWarning = (isTls11) ? checker.getDaysBetweenWarnings() : 0;
        isMessageProfileSpecific = (isTls11) ? checker.isMessageProfileSpecific() : false;
    } 

}