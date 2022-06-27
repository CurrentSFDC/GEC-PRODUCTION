@isTest
public class UtilityClass_Test 
{
    static testmethod void method1()
    {
        UtilityClass currancyconverter=new UtilityClass();
        decimal euramt=currancyconverter.convertCurrencyMethod('USD','EUR',2);
         decimal euramt1=currancyconverter.convertCurrencyMethod('USD','EUR',2,system.today()-6);
    }
    static testmethod void method2()
    {
        UtilityClass.convertUomLabelToUomCode('Each');
        UtilityClass.convertUomCodeToUomLabel('EA');
    }
}