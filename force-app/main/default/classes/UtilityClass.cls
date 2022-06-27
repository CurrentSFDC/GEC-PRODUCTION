/*
Test Class - UtilityClass_Test
Purpose - UtilityClass for currency convertion rate.
Date - September-2016
*/
public class UtilityClass 
{
    List<DatedConversionRate> currencyList;
    Map<String,Decimal> conversionRateMap;
    Map<String,List<DatedConversionRate>> exchangeMap = new Map<String,List<DatedConversionRate>>();

    // Returns the UOM code belonging to the given UOM label, or the label itself if there isn't a match
    public static String convertUomLabelToUomCode(String uomLabel) {
        for (Object uomObject : HeaderActions.getUomCodeLabelMap(null)) {
            UOM_Mapping__mdt uomMdt = (UOM_Mapping__mdt) uomObject;
            if (uomMdt.Label == uomLabel) {
                return uomMdt.Code__c;
            }
        }
        return uomLabel;
    }

    // Returns the UOM label belonging to the given UOM code, or the code itself if there isn't a match
    public static String convertUomCodeToUomLabel(String uomCode) {
        for (Object uomObject : HeaderActions.getUomCodeLabelMap(null)) {
            UOM_Mapping__mdt uomMdt = (UOM_Mapping__mdt) uomObject;
            if (uomMdt.Code__c == uomCode) {
                return uomMdt.Label;
            }
        }
        return uomCode;
    }


    public UtilityClass()
    {
        currencyList = [SELECT ISOCode, ConversionRate,StartDate,NextStartDate FROM DatedConversionRate Order by isocode,startdate desc];
        conversionRateMap=new Map<String,Decimal>();
        for(DatedConversionRate currType:currencyList)
        {
            if(!conversionRateMap.containsKey(currType.ISOCode))
            {
                conversionRateMap.put(currType.ISOCode,currType.ConversionRate);
                //System.debug('ISOCode:'+currType.ISOCode+' '+'ConversionRate:'+currType.ConversionRate);
            }
            
        }
        for(DatedConversionRate currTypeVar:currencyList)
        {
            if(!exchangeMap.containsKey(currTypeVar.ISOCode))
            {
                List<DatedConversionRate> tempInnerMap = new List<DatedConversionRate>();
                tempInnerMap.add(currTypeVar);
                exchangeMap.put(currTypeVar.ISOCode,tempInnerMap);
            }
            else
            {
                List<DatedConversionRate> tempInnerMap = exchangeMap.get(currTypeVar.ISOCode);
                tempInnerMap.add(currTypeVar);
                exchangeMap.put(currTypeVar.ISOCode,tempInnerMap);
            }
        }
    }
    public Decimal convertCurrencyMethod(String sourceCur,String destCur,Decimal sourceVal)
    {
        Decimal currInUSD=0;
        Decimal currInDestination=0;
        if(conversionRateMap.containsKey(sourceCur))
        {
            currInUSD=sourceVal/conversionRateMap.get(sourceCur);
        }
        if(conversionRateMap.containsKey(destCur))
        {
            currInDestination=currInUSD*conversionRateMap.get(destCur);
        }
        return currInDestination.setScale(2);
    }
    
    public Decimal convertCurrencyMethod(String sourceCur,String destCur,Decimal sourceVal,Date orderStartDate)
    {
        Decimal currInUSD=0;
        Decimal currInDestination=0;
        Decimal exchangeRate = 0;
        if(exchangeMap.containsKey(sourceCur))
        {
            for(DatedConversionRate var : exchangeMap.get(sourceCur))
            {
                if(orderStartDate >= var.StartDate && orderStartDate <= var.NextStartDate)
                {
                    currInUSD=sourceVal/var.ConversionRate;
                    System.debug('Exchange Rate:'+var.ConversionRate+'::'+currInUSD);
                    break;
                }
            }
            for(DatedConversionRate var : exchangeMap.get(destCur))
            {
                if(orderStartDate >= var.StartDate && orderStartDate <= var.NextStartDate)
                {
                    System.debug('Exchange Rate11:'+var.ConversionRate+'::'+var.ConversionRate);
                    currInDestination=currInUSD*var.ConversionRate;
                    break;
                }
            }
        }
        return currInDestination.setScale(2);
    }
}