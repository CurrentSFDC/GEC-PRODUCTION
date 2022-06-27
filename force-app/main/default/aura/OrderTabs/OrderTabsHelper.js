({
    getOrderDetails : function(component, event, helper) {
        component.set("v.inProgress", true);
        var action = component.get("c.getDetails");
        var recordId = component.get("v.recordId");
        //'FEDEX GROUND','153705794927'      
        action.setParams({"orderId" : recordId });
        action.setCallback(this,function(response){   

            console.log("Response from the SAP" + response.getState());
            console.log("Error from the SAP2" + JSON.stringify(response.getError()));
            
            var state = response.getState();
            if(state === "SUCCESS"){
                
                var records = response.getReturnValue();
                console.log("Response Data from the SAP", response.getReturnValue());
                //this.setShipmentTable(component, records.scheduleData);
                this.processItemData(component, records);
                this.processShipData(component, records);
                component.set("v.ordertData", records);
                console.log("User Account Check" + records.userAccountGroup);
                if(records.userAccountGroup == "ZEAG"){
                    component.set("v.userIsAgent", true);
                }
                //console.log('SAP response: ',records);
                console.log('OrderId:' ,recordId );

                // Get Read Only User Permission To Check View Price Permission Set Or Not By Sameer Mahadik On(8-27-2021)
                var userPermissions = localStorage.getItem("UserPermission");
                if (userPermissions !== null) {
                    userPermissions = JSON.parse(userPermissions);
                    if ((userPermissions['profileName'] == "Agent Read Only B2B Storefront Registered Users" ||
                        userPermissions['profileName'] == "Distributor Read Only B2B Storefront Registered Users")) {
                            if (userPermissions['permissionSet'].includes('View_PLP_and_PDP_Prices') == false) {
                                component.set("v.downloadAgreementPdf", false);
                            }

                            if (userPermissions['permissionSet'].includes('View_Commissions_Set_Price') == false) {
                                component.set("v.viewCommissionAmount", false);
                            }

                    }
                }

            }
            else if (state === "ERROR") 
			{
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						helper.addPageMessage(component, "error","Error message: " + errors[0].message);
                        console.log('OrderId with error:' ,recordId );
					}
				} 
				else {
                    helper.addPageMessage(component, "error", "There was a problem returning the latest Order Information. Please contact your GE Current for help.");
				}
			}            
            component.set("v.inProgress", false);
        });
        $A.enqueueAction(action);
    },

    getOrderSFDCFields : function(component, event, helper) {
        
        component.set("v.inProgress", true);
        var action = component.get("c.getOrder");
        var recordId = component.get("v.recordId");
        
        //'FEDEX GROUND','153705794927'      
        action.setParams({"orderId" : recordId });
        action.setCallback(this,function(response){   
            
            var state = response.getState();
            if(state === "SUCCESS"){
               
                
                var records = response.getReturnValue();
                // if(records.CurrencyIsoCode=='USD'){
                //     records.currency_y='$';                   
                // }
                // else if(records.CurrencyIsoCode=='CAD'){
                //     records.currency_y='CA$';                   
                // }
                // else{
                //     records.currency_y=records.CurrencyIsoCode;                   
                // }
                //records.TotalAmount=records.TotalAmount.toFixed(2);

               
                if(records.TotalAmount !==undefined && records.TotalCommission__c !==undefined && records.TotalAmount !=='0' && records.TotalCommission__c !=='0'){
                    var per = (records.TotalCommission__c/records.TotalAmount)*100;
                    records.TotalCommission_per=per.toFixed(2) +'%';
                }
                else{                    
                    records.TotalCommission_per="0.00%"; 
                }
                // Comment Above Currnecy Code & Format Below Number In Currency Form By Sameer Mahadik On(10-28-2021)
                records.TotalAmount = Intl.NumberFormat('en-US', { style: 'currency', currency: records.CurrencyIsoCode }).format(records.TotalAmount !== undefined ? records.TotalAmount : 0);
                records.TotalCommission__c = Intl.NumberFormat('en-US', {style: "currency", currency: records.CurrencyIsoCode }).format(records.TotalCommission__c !== undefined ? records.TotalCommission__c : 0);
                records.SURCHARGES__c = Intl.NumberFormat('en-US', {style: "currency", currency: records.CurrencyIsoCode }).format(records.SURCHARGES__c !== undefined ? records.SURCHARGES__c : 0);
                component.set("v.orderSFDCFields", records);
                console.log('orderSFDCFields:' ,records );
                /*component.set("v.orderNumber", component.get("v.orderData").GE_Order_NO__c);*/
               
                console.log('State is:' ,state );
            }
            else if (state === "ERROR") 
			{
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						helper.addPageMessage(component, "error","Error message: " + errors[0].message);
					}
				} 
				else {
                    helper.addPageMessage(component, "error", "There was a problem returning the latest Order Information. Please contact your GE Current for help.");
				}
			}            
            component.set("v.inProgress", false);
        });
        
        $A.enqueueAction(action);
    },


    setShipmentTable : function(component, records) {
        component.set('v.shipmentcolumns', [
            {label: $A.get("$Label.c.ShipDate"), fieldName: 'ACT_SHIP_DATE', type: 'date-local',  typeAttributes: {  
                day: 'numeric',  
                month: 'numeric',  
                year: 'numeric',   
                hour12: true}, initialWidth: 110, wrapText: true, hideDefaultActions: true, cellAttributes: { alignment: 'right'}},
            {label: $A.get("$Label.c.EstimatedDelDate"), fieldName: 'ACT_DEL_DATE', type: 'date-local', typeAttributes: {  
                day: 'numeric',  
                month: 'numeric',  
                year: 'numeric',   
                hour12: true}, initialWidth: 125, wrapText: true, hideDefaultActions: true, cellAttributes: { alignment: 'right'}},
      
            {label: $A.get("$Label.c.Carrier"), fieldName: 'CARRIER_NAME', type: 'text', initialWidth: 100, wrapText: true, hideDefaultActions: true,cellAttributes: { alignment: 'left'}},
            {label: $A.get("$Label.c.Tracking"), fieldName: 'trackinglinkName', type: 'button', initialWidth: 180, wrapText: true, hideDefaultActions: true,
            typeAttributes: {label: { fieldName: 'TRACKING_NUMBER' },  target: '_blank', name: 'Tracking'},cellAttributes: { alignment: 'right'}},            
            /*

            {type: "button", typeAttributes: {
                label: 'Tracking',
                name: 'View',
                title: 'View',
                disabled: false,
                //value: TRACKING_NUMBER,
                iconPosition: 'left',
                variant: {fieldName: 'variantValue'}
            }},*/
            
            {label: $A.get("$Label.c.ShippedFrom"), fieldName: 'SHIPPED_FROM', type: 'text', initialWidth: 120, wrapText: true, hideDefaultActions: true,cellAttributes: { alignment: 'left'}},
            {label: $A.get("$Label.c.Invoice"), fieldName: 'invoicelinkName', type: 'button', initialWidth: 120, wrapText: true, hideDefaultActions: true,
            typeAttributes: {label: { fieldName: 'INVOICE_NUMBER' }, target: '_blank', name: 'Invoice'},cellAttributes: { alignment: 'right'}},
            {label: $A.get("$Label.c.InvoiceDate"), fieldName: 'INVOICE_DATE', type: 'date-local',typeAttributes: {  
                day: 'numeric',  
                month: 'numeric',  
                year: 'numeric',   
                hour12: true}, initialWidth: 110, wrapText: true, hideDefaultActions: true,cellAttributes: { alignment: 'right'}},            
            {label: $A.get("$Label.c.DeliveryNote"), fieldName: 'deliverylinkName', type: 'button', initialWidth: 110, wrapText: true, hideDefaultActions: true,
            typeAttributes: {label: { fieldName: 'DEL_NUMBER' }, target: '_blank', name: 'DeliveryNote'},cellAttributes: { alignment: 'right'}}

        ]);

        records.forEach(function(record){
            record.trackinglinkName = record.CARRIER_NAME + ';' + record.TRACKING_NUMBER ; 
            record.invoicelinkName = record.INVOICE_NUMBER ; 
            record.deliverylinkName = record.DEL_NUMBER ; 
        });
        component.set('v.shipmentdata', records);
        //document.getElementById('shipmentTable').style.display='block';
        //console.log('shipmentTable:' ,records );
    },

    addPageMessage: function(component, severity, messages, closable) {
        if ($A.util.isEmpty(messages)) { return; }
        if (!$A.util.isArray(messages)) { messages = [messages]; }
        var pageMessage = {};
        pageMessage.closable = closable;
        pageMessage.severity = (severity) ? severity.toLowerCase() : "error";
        pageMessage.messages = (messages) ? messages : [];
        pageMessage.title = (severity === "confirm") ? "Success" : (severity === "warning") ? "Warning"
                                : (severity === "info") ? "Information" : "Error";

        var pageMessages = component.get("v.pageMessages");
        pageMessages.push(pageMessage);
        component.set("v.pageMessages", pageMessages);
    },

    processItemData: function(component, records){
        var itemData = records.salesItemData;
        console.log("ItemData" + JSON.stringify(itemData));
                for(var i=0 ; i<itemData.length ; i++){
                    itemData[i].salesDelInvData = records.salesDelInvData[i];
                    itemData[i].scheduleData = records.scheduleData[i];
                    itemData[i].QTY_REMAINING = itemData[i].QUANTITY - itemData[i].QTY_SHIPPED;
                    // Formatting Below Currency By Sameer Mahadik On(10-28-2021)
                    itemData[i].UNIT_PRICE = Intl.NumberFormat('en-US', { style: 'currency', currency: itemData[i].CURRENCY_x }).format(itemData[i].UNIT_PRICE);
                    itemData[i].ITEM_NET_VALUE = Intl.NumberFormat('en-US', { style: 'currency', currency: itemData[i].CURRENCY_x }).format(itemData[i].ITEM_NET_VALUE);
                    itemData[i].STANDARD_COMMISSION = Intl.NumberFormat('en-US', { style: 'currency', currency: itemData[i].CURRENCY_x }).format(itemData[i].STANDARD_COMMISSION);
                    itemData[i].OVERAGE_COMMISSION = Intl.NumberFormat('en-US', { style: 'currency', currency: itemData[i].CURRENCY_x }).format(itemData[i].OVERAGE_COMMISSION);
                    itemData[i].ITEM_COMM_VALUE = Intl.NumberFormat('en-US', { style: 'currency', currency: itemData[i].CURRENCY_x }).format(itemData[i].ITEM_COMM_VALUE);


                    itemData[i].accordionTitle = itemData[i].ITEM_NUMBER;
                    itemData[i].accordionTitle += '     |     '+itemData[i].PRODUCT_NUMBER+' ';
                    itemData[i].accordionTitle += '     :     '+itemData[i].PRODUCT_DESCRIPTION+' ';
                    itemData[i].accordionTitle += '     |     '+$A.get("$Label.c.Shipped")+' ';
                    itemData[i].accordionTitle += Math.trunc(itemData[i].QTY_SHIPPED).toString().padStart(5,' ');
                    itemData[i].accordionTitle += '     of     '+' ';
                    itemData[i].accordionTitle += Math.trunc(itemData[i].QUANTITY).toString().padStart(5,' ');
                    if(itemData[i].SPECIAL_INSTRUCTIONS!=''){
                         itemData[i].accordionTitle += '     |     '+itemData[i].SPECIAL_INSTRUCTIONS+' ';
                    }

                    /*itemData[i].accordionTitle += '     |     '+$A.get("$Label.c.Ordered")+' ';
                    itemData[i].accordionTitle += Math.trunc(itemData[i].QUANTITY).toString().padStart(5,' ');
                    itemData[i].accordionTitle += '     |     '+$A.get("$Label.c.Shipped")+' ';
                    itemData[i].accordionTitle += Math.trunc(itemData[i].QTY_SHIPPED).toString().padStart(5,' ');
                    itemData[i].accordionTitle += '     |     ';
                    itemData[i].accordionTitle += itemData[i].PRODUCT_DESCRIPTION.trim();*/
                }
                
                component.set("v.orderItemData", itemData);
    },

    processShipData: function(component, records){
        var ShipData = records.scheduleData;
        var lineItems = records.salesItemData;
        var itemData = {};

        lineItems.forEach(data => {
            itemData[data["ITEM_NUMBER"]] = data;
        });

        console.log("ShipData" + JSON.stringify(ShipData));
                for(var i=0 ; i<ShipData.length ; i++){
                

                    // ShipData[i].accordionTitle = ShipData[i].ITEM_NUMBER;
                    // ShipData[i].accordionTitle += '     |     '+itemData[i].PRODUCT_NUMBER+' ';
                    // ShipData[i].accordionTitle += '     :     '+itemData[i].PRODUCT_DESCRIPTION+' ';
                    // ShipData[i].accordionTitle += '     |     '+$A.get("$Label.c.Shipped")+' ';
                    // ShipData[i].accordionTitle += Math.trunc(itemData[i].QTY_SHIPPED).toString().padStart(5,' ');
                    // console.log('ShipData[i].INVOICE_DATE',ShipData[i].INVOICE_DATE);
                    // if(ShipData[i].INVOICE_DATE !=undefined && ShipData[i].INVOICE_DATE!=''){
                    //     ShipData[i].accordionTitle += '     |     '+ShipData[i].INVOICE_DATE+' ';
                    // }

                    var shipQty = 0;
                    var actShipDate = "";
                    var itemNumber = ShipData[i].ITEM_NUMBER;
                    ShipData[i].accordionTitle = itemNumber;
                    ShipData[i].accordionTitle += '     |     '+itemData[itemNumber].PRODUCT_NUMBER+' ';
                    ShipData[i].accordionTitle += '     :     '+itemData[itemNumber].PRODUCT_DESCRIPTION+' ';
                    ShipData[i].accordionTitle += '     |     '+$A.get("$Label.c.Shipped")+' ';

                    if(ShipData[i].ACT_SHIP_DATE !=undefined && ShipData[i].ACT_SHIP_DATE !== '0000-00-00'){
                        shipQty = Math.trunc(ShipData[i].QUANTITY).toString().padStart(5,' ');
                        actShipDate = '     |     ' + new Date(ShipData[i].ACT_SHIP_DATE.replace(/-/g, '\/')).toLocaleDateString("en-US", { year: 'numeric', month: '2-digit', day: '2-digit' });
                        // ShipData[i].accordionTitle += '     |     '+ShipData[i].ACT_DEL_DATE+' ';
                    } else if(ShipData[i].EST_SHIP_DATE !=undefined && ShipData[i].EST_SHIP_DATE !== '00/00/0000') {
                        actShipDate = '     |     ' + new Date(ShipData[i].EST_SHIP_DATE).toLocaleDateString("en-US", { year: 'numeric', month: '2-digit', day: '2-digit' });
                    }

                    ShipData[i].accordionTitle += shipQty;
                    ShipData[i].accordionTitle += actShipDate;

                    /*itemData[i].accordionTitle += '     |     '+$A.get("$Label.c.Ordered")+' ';
                    itemData[i].accordionTitle += Math.trunc(itemData[i].QUANTITY).toString().padStart(5,' ');
                    itemData[i].accordionTitle += '     |     '+$A.get("$Label.c.Shipped")+' ';
                    itemData[i].accordionTitle += Math.trunc(itemData[i].QTY_SHIPPED).toString().padStart(5,' ');
                    itemData[i].accordionTitle += '     |     ';
                    itemData[i].accordionTitle += itemData[i].PRODUCT_DESCRIPTION.trim();*/
                }
                
                component.set("v.orderShipData", ShipData);
    },

})