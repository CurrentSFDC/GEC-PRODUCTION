trigger InsertDisputeRequest on Shipment_Detail__c (after insert) {


    Set<String> currentUids = new Set<String>();

    for(Shipment_Detail__c a : Trigger.New) {
        currentUids.add(a.Unique_ID__c);
    }

    List<Shipment_Detail__c> casepro = [select GE_NAS_Type_of_Problem__c, GE_NAS_Type_of_Problem1__c,Unique_ID__c,Dispute_Request__c from Shipment_Detail__c where Unique_ID__c IN:currentUids];
    List<Shipment_Detail__c> caseProdsToUpdate = new List<Shipment_Detail__c>();
    Boolean isexist;

    Set<String> uids = new  Set<String>();

    for(Shipment_Detail__c a : Trigger.New) {
        isexist=false;
        if(a.Unique_ID__c!=Null && a.GE_NAS_Type_of_Problem__c == 'Return - Return' && a.GE_NAS_Type_of_Problem1__c == 'Return'){
            for(Shipment_Detail__c exist: casepro){
                if(exist.Unique_ID__c==a.Unique_ID__c && exist.Dispute_Request__c !=Null && exist.GE_NAS_Type_of_Problem__c == 'Return - Return' && exist.GE_NAS_Type_of_Problem1__c == 'Return'){
                    Shipment_Detail__c newship = new Shipment_Detail__c(Id=a.Id);
                    newship.Dispute_Request__c=exist.Dispute_Request__c;
                    //caseProdsToUpdate.add(newship);
                    caseProdsToUpdate.add(newship);
                    isexist=true;
                    Break;

                }
            }

            if(!isexist){

                uids.add(a.Unique_ID__c);

            }

        }
        Else If(a.Unique_ID__c!=Null && a.GE_NAS_Type_of_Problem__c == 'Return - Replacement'
                && a.GE_NAS_Type_of_Problem1__c == 'Replacement'){
            for(Shipment_Detail__c exist: casepro){
                if(exist.Unique_ID__c==a.Unique_ID__c && exist.Dispute_Request__c !=Null && exist.GE_NAS_Type_of_Problem__c == 'Return - Replacement' && exist.GE_NAS_Type_of_Problem1__c == 'Replacement'){
                    Shipment_Detail__c newship = new Shipment_Detail__c(Id=a.Id);
                    newship.Dispute_Request__c=exist.Dispute_Request__c;
                    caseProdsToUpdate.add(newship);
                    isexist=true;
                    Break;

                }
            }

            if(!isexist){

                uids.add(a.Unique_ID__c);

            }
        }

        Else If(a.Unique_ID__c!=Null && a.GE_NAS_Type_of_Problem__c == 'Warranty - Return'
                && a.GE_NAS_Type_of_Problem1__c == 'Return'){
            for(Shipment_Detail__c exist: casepro){
                if(exist.Unique_ID__c==a.Unique_ID__c && exist.Dispute_Request__c !=Null && exist.GE_NAS_Type_of_Problem__c == 'Warranty - Return' && exist.GE_NAS_Type_of_Problem1__c == 'Return'){
                    Shipment_Detail__c newship = new Shipment_Detail__c(Id=a.Id);
                    newship.Dispute_Request__c=exist.Dispute_Request__c;
                    caseProdsToUpdate.add(newship);
                    isexist=true;
                    Break;

                }
            }

            if(!isexist){

                uids.add(a.Unique_ID__c);

            }
        }
        Else If(a.Unique_ID__c!=Null && a.GE_NAS_Type_of_Problem__c == 'Warranty - Replace'
                && a.GE_NAS_Type_of_Problem1__c == 'Replace'){
            for(Shipment_Detail__c exist: casepro){
                if(exist.Unique_ID__c==a.Unique_ID__c && exist.Dispute_Request__c !=Null && exist.GE_NAS_Type_of_Problem__c == 'Warranty - Replace' && exist.GE_NAS_Type_of_Problem1__c == 'Replace'){
                    Shipment_Detail__c newship = new Shipment_Detail__c(Id=a.Id);
                    newship.Dispute_Request__c=exist.Dispute_Request__c;
                    caseProdsToUpdate.add(newship);
                    isexist=true;
                    Break;

                }
            }

            if(!isexist){

                uids.add(a.Unique_ID__c);

            }
        }
        Else If(a.Unique_ID__c!=Null && a.GE_NAS_Type_of_Problem__c == 'Warranty - Credit'
                && a.GE_NAS_Type_of_Problem1__c == 'Credit'){
            for(Shipment_Detail__c exist: casepro){
                if(exist.Unique_ID__c==a.Unique_ID__c && exist.Dispute_Request__c !=Null && exist.GE_NAS_Type_of_Problem__c == 'Warranty - Credit' && exist.GE_NAS_Type_of_Problem1__c == 'Credit'){
                    Shipment_Detail__c newship = new Shipment_Detail__c(Id=a.Id);
                    newship.Dispute_Request__c=exist.Dispute_Request__c;
                    caseProdsToUpdate.add(newship);
                    isexist=true;
                    Break;

                }
            }

            if(!isexist){

                uids.add(a.Unique_ID__c);

            }
        }
        Else If(a.Unique_ID__c!=Null && a.GE_NAS_Type_of_Problem__c == 'Warranty - Return for Analysis'
                && a.GE_NAS_Type_of_Problem1__c == 'Return for Analysis'){
            for(Shipment_Detail__c exist: casepro){
                if(exist.Unique_ID__c==a.Unique_ID__c && exist.Dispute_Request__c !=Null && exist.GE_NAS_Type_of_Problem__c == 'Warranty - Return for Analysis' && exist.GE_NAS_Type_of_Problem1__c == 'Return for Analysis'){
                    Shipment_Detail__c newship = new Shipment_Detail__c(Id=a.Id);
                    newship.Dispute_Request__c=exist.Dispute_Request__c;
                    caseProdsToUpdate.add(newship);
                    isexist=true;
                    Break;

                }
            }

            if(!isexist){

                uids.add(a.Unique_ID__c);

            }
        }
        Else If(a.Unique_ID__c!=Null && a.GE_NAS_Type_of_Problem__c == 'Overage - Keep & Bill'
                && a.GE_NAS_Type_of_Problem1__c == 'Keep & Bill'){
            for(Shipment_Detail__c exist: casepro){
                if(exist.Unique_ID__c==a.Unique_ID__c && exist.Dispute_Request__c !=Null && exist.GE_NAS_Type_of_Problem__c == 'Overage - Keep & Bill' && exist.GE_NAS_Type_of_Problem1__c == 'Keep & Bill'){
                    Shipment_Detail__c newship = new Shipment_Detail__c(Id=a.Id);
                    newship.Dispute_Request__c=exist.Dispute_Request__c;
                    caseProdsToUpdate.add(newship);
                    isexist=true;
                    Break;

                }
            }

            if(!isexist){

                uids.add(a.Unique_ID__c);

            }
        }
        Else If(a.Unique_ID__c!=Null && a.GE_NAS_Type_of_Problem__c == 'Overage - Return'
                && a.GE_NAS_Type_of_Problem1__c == 'Return'){
            for(Shipment_Detail__c exist: casepro){
                if(exist.Unique_ID__c==a.Unique_ID__c && exist.Dispute_Request__c !=Null && exist.GE_NAS_Type_of_Problem__c == 'Overage - Return' && exist.GE_NAS_Type_of_Problem1__c == 'Return'){
                    Shipment_Detail__c newship = new Shipment_Detail__c(Id=a.Id);
                    newship.Dispute_Request__c=exist.Dispute_Request__c;
                    caseProdsToUpdate.add(newship);
                    isexist=true;
                    Break;

                }
            }

            if(!isexist){

                uids.add(a.Unique_ID__c);

            }
        }
        Else If(a.Unique_ID__c!=Null && a.GE_NAS_Type_of_Problem__c == 'Shortage - Replacement'
                && a.GE_NAS_Type_of_Problem1__c == 'Replacement'){
            for(Shipment_Detail__c exist: casepro){
                if(exist.Unique_ID__c==a.Unique_ID__c && exist.Dispute_Request__c !=Null && exist.GE_NAS_Type_of_Problem__c == 'Shortage - Replacement' && exist.GE_NAS_Type_of_Problem1__c == 'Replacement'){
                    Shipment_Detail__c newship = new Shipment_Detail__c(Id=a.Id);
                    newship.Dispute_Request__c=exist.Dispute_Request__c;
                    caseProdsToUpdate.add(newship);
                    isexist=true;
                    Break;

                }
            }

            if(!isexist){

                uids.add(a.Unique_ID__c);

            }
        }
        Else If(a.Unique_ID__c!=Null && a.GE_NAS_Type_of_Problem__c == 'Shortage - Credit'
                && a.GE_NAS_Type_of_Problem1__c == 'Credit'){
            for(Shipment_Detail__c exist: casepro){
                if(exist.Unique_ID__c==a.Unique_ID__c && exist.Dispute_Request__c !=Null && exist.GE_NAS_Type_of_Problem__c == 'Shortage - Credit' && exist.GE_NAS_Type_of_Problem1__c == 'Credit'){
                    Shipment_Detail__c newship = new Shipment_Detail__c(Id=a.Id);
                    newship.Dispute_Request__c=exist.Dispute_Request__c;
                    caseProdsToUpdate.add(newship);
                    isexist=true;
                    Break;

                }
            }

            if(!isexist){

                uids.add(a.Unique_ID__c);

            }
        }
        Else If(a.Unique_ID__c!=Null && a.GE_NAS_Type_of_Problem__c == 'Lost/Damaged - Replacement'
                && a.GE_NAS_Type_of_Problem1__c == 'Replacement'){
            for(Shipment_Detail__c exist: casepro){
                if(exist.Unique_ID__c==a.Unique_ID__c && exist.Dispute_Request__c !=Null && exist.GE_NAS_Type_of_Problem__c == 'Lost/Damaged - Replacement' && exist.GE_NAS_Type_of_Problem1__c == 'Replacement'){
                    Shipment_Detail__c newship = new Shipment_Detail__c(Id=a.Id);
                    newship.Dispute_Request__c=exist.Dispute_Request__c;
                    caseProdsToUpdate.add(newship);
                    isexist=true;
                    Break;

                }
            }

            if(!isexist){

                uids.add(a.Unique_ID__c);

            }
        }
        Else If(a.Unique_ID__c!=Null && a.GE_NAS_Type_of_Problem__c == 'Lost/Damaged - Credit'
                && a.GE_NAS_Type_of_Problem1__c == 'Credit'){
            for(Shipment_Detail__c exist: casepro){
                if(exist.Unique_ID__c==a.Unique_ID__c && exist.Dispute_Request__c !=Null && exist.GE_NAS_Type_of_Problem__c == 'Lost/Damaged - Credit' && exist.GE_NAS_Type_of_Problem1__c == 'Credit'){
                    Shipment_Detail__c newship = new Shipment_Detail__c(Id=a.Id);
                    newship.Dispute_Request__c=exist.Dispute_Request__c;
                    caseProdsToUpdate.add(newship);
                    isexist=true;
                    Break;

                }
            }

            if(!isexist){

                uids.add(a.Unique_ID__c);

            }
        }
    }

    if (caseProdsToUpdate.size()>0) update caseProdsToUpdate;
    Map<String,Dispute_Request__c> newdisp = new Map<String,Dispute_Request__c>();

    for(String uid: uids){
        List<Shipment_Detail__c> caseP = [select GE_NAS_Type_of_Problem__c, GE_NAS_Type_of_Problem1__c,Unique_ID__c,Dispute_Request__c from Shipment_Detail__c where Unique_ID__c = :uid];
        String returndocType;
        for(Shipment_Detail__c cp: caseP){
            if(cp.GE_NAS_Type_of_Problem__c == 'Return - Return' && cp.GE_NAS_Type_of_Problem1__c == 'Return'){
                returndocType = 'ZRE';
            }
            else If(cp.GE_NAS_Type_of_Problem__c == 'Return - Replacement'&& cp.GE_NAS_Type_of_Problem1__c == 'Replacement'){
                returndocType = 'ZOR';
            }
            else If(cp.GE_NAS_Type_of_Problem__c == 'Warranty - Return & Credit' && cp.GE_NAS_Type_of_Problem1__c == 'Return & Credit'){
                returndocType = 'ZCRD';
            }
            else If(cp.GE_NAS_Type_of_Problem__c == 'Warranty - Return' && cp.GE_NAS_Type_of_Problem1__c == 'Return'){
                returndocType = null;
            }
            else If(cp.GE_NAS_Type_of_Problem__c == 'Warranty - Return for Analysis' && cp.GE_NAS_Type_of_Problem1__c == 'Return for Analysis'){
                returndocType = null;
            }
            else If(cp.GE_NAS_Type_of_Problem__c == 'Warranty - Replace' && cp.GE_NAS_Type_of_Problem1__c == 'Replace'){
                returndocType = 'ZFDD';
            }
            else If(cp.GE_NAS_Type_of_Problem__c == 'Warranty - Credit' && cp.GE_NAS_Type_of_Problem1__c == 'Credit'){
                returndocType = 'ZCRD';
            }
            else If(cp.GE_NAS_Type_of_Problem__c == 'Overage - Return' && cp.GE_NAS_Type_of_Problem1__c == 'Return'){
                returndocType = 'ZRE';
            }
            else If(cp.GE_NAS_Type_of_Problem__c == 'Overage - Keep & Bill' && cp.GE_NAS_Type_of_Problem1__c == 'Keep & Bill'){
                returndocType = 'ZDR';
            }
            else If(cp.GE_NAS_Type_of_Problem__c == 'Shortage - Replacement' && cp.GE_NAS_Type_of_Problem1__c == 'Replacement'){
                returndocType = 'ZOR';
            }
            else If(cp.GE_NAS_Type_of_Problem__c == 'Shortage - Credit' && cp.GE_NAS_Type_of_Problem1__c == 'Credit'){
                returndocType = 'ZCR';
            }
            else If(cp.GE_NAS_Type_of_Problem__c == 'Lost/Damaged - Credit' && cp.GE_NAS_Type_of_Problem1__c == 'Credit'){
                returndocType = 'ZCR';
            }
            else If(cp.GE_NAS_Type_of_Problem__c == 'Lost/Damaged - Replacement' && cp.GE_NAS_Type_of_Problem1__c == 'Replacement'){
                returndocType = 'ZOR';
            }
        }


        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Dispute_Request__c d1 = new Dispute_Request__c();
        d1.Status__c = 'Pending Action';
        d1.Transaction_ID__c= uid;
        d1.RecordTypeId = devRecordTypeId;
        d1.SAP_Doc_Type__c = returndocType;
        //insert d1;
        newdisp.put(uid,d1);
    }

    if (newdisp.size()>0) {
        insert newdisp.values();
    }

    list<Shipment_Detail__c> sdToUpdate = new list<Shipment_Detail__c>();
    list<Dispute_Request__c> drToUpdate = new list<Dispute_Request__c>();
    for(Shipment_Detail__c sd : Trigger.New){
        if(newdisp.keyset().contains(sd.Unique_ID__c)){
            Shipment_Detail__c updship = new Shipment_Detail__c(Id=sd.Id);
            updship.Dispute_Request__c=newdisp.get(sd.Unique_ID__c).id;
            Dispute_Request__c upddisp = new Dispute_Request__c(Id=newdisp.get(sd.Unique_ID__c).id);

            upddisp.Case__c= sd.GE_NAS_Case_Number__c;
            upddisp.Customer_PO__c= sd.PO__c;
            upddisp.Original_Order__c = sd.order__c;
            upddisp.Invoice__c = sd.Invoice__c;
            upddisp.SFDC_Invoice__c = sd.SFDC_Invoice__c;
            upddisp.Sold_To__c = sd.Distributor_ID__c;
            sdToUpdate.add(updship);
            drToUpdate.add(upddisp);
            //Update updship;
            //Update upddisp;
            //Update upddisp;
        }
    }
    if (sdToUpdate.size()>0) {
        update sdToUpdate;
    }
    if (drToUpdate.size()>0) {
        update drToUpdate;
    }
}