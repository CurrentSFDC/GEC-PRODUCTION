public with sharing class ComboboxOptionBuilder {
    public static List<Map<String, Object>> buildOptions(List<String> inputs) {
        return buildOptions(inputs, false);
    }

    public static List<Map<String, Object>> buildOptions(List<String> inputs, Boolean withIndexedValue) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        //for (Integer i = 0; i < inputs.size(); i++) {
        //    options.add(new Map<String, String>{
        //            'label' => inputs[i],
        //            'value' => withIndexedValue ? String.valueOf(i +1) : inputs[i]
        //    });
        //}
        for (String uomValue : inputs){
            String uomLabel = uomValue;
            switch on uomValue {
                when 'PC'{uomLabel = 'Piece';}
                when 'BX'{uomLabel = 'Box';}
                when 'EA'{uomLabel = 'Each';}
                when 'ICV'{uomLabel = 'Inner Case';}
                when 'CV'{uomLabel = 'Case';}
                when 'NP'{uomLabel = 'Pallet';}
                when 'NL'{uomLabel = 'Pallet Layer';}
            }
            options.add(new Map<String, String>{
                    'label' => uomLabel,
                    'value' => uomValue
            });
        }
        return options;
    }
}