({

    getPDFData : function(component, event, helper) {        

       var params = event.getParam('arguments');
       if (params) {
           component.set("v.bShowModal", false);
           var param1 = params.agrNumber;
           // console.log('param1' + param1);                    
       
           return new Promise($A.getCallback(function (resolve, reject) {
               var action = component.get("c.getPDF");
               //action.setParams({"agrNumber" : "80157579" });
               action.setParams({"agrNumber" : param1 });
               // console.log('Action: ' +  action);
               // console.log('Begin setCallback');
               action.setCallback(this,function(response){ 
                   
                   var state = response.getState();                
                   // console.log('response status***' + response.getState());                
                   if(state === "SUCCESS"){
                       // console.log('response status' + response.getState());
                       var records = response.getReturnValue();
                       //console.log('data=' + records.base64Data);

                       var pdfData = records.base64Data;
                       var agreementPdfDownload  = component.find('AgreementPdfdownloader');
agreementPdfDownload.downloadPDFFromBase64String(pdfData, 'Price-Agreement-' + param1 + '.pdf');

                      /* component.set("v.pdfContainer", []);
                       $A.createComponent(
                           "c:pdfViewer",
                               {
                                   "pdfData": pdfData
                               },
                               function(pdfViewer, status, errorMessage){
                                   if (status === "SUCCESS") {
                                       var pdfContainer = component.get("v.pdfContainer");
                                       pdfContainer.push(pdfViewer);
                                       component.set("v.pdfContainer", pdfContainer);
                                       // console.log("open pdf");
                                   }
                                   else if (status === "INCOMPLETE") {
                                       console.log("No response from server or client is offline.")
                                   }
                                   else if (status === "ERROR") {
                                       console.log("Error: " + errorMessage);
                                   }
                               }
                       );  
                       component.set("v.bShowModal", true);*/
                   }  else if (state === "ERROR")  {
                       console.log('Error (agreementpdfhelper)');
                       var errors = response.getError();
                       if (errors) {
                           if (errors[0] && errors[0].message) {
                               console.log(errors[0].message);
                               helper.addPageMessage(component, "error","Error message: " + errors[0].message);
                           }
                       } 
                       else {
                           helper.addPageMessage(component, "error", "There was a problem returning the Agreement Pdf data. Please contact your GE Current for help.");
                       }
                   }
               });            
               // console.log('Before enqueue');
               $A.enqueueAction(action);
               // console.log('After enqueue');
           }));
       } 
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

   closeModal: function(component, event, helper){
       component.set("v.bShowModal", false);
       // console.log('closeModal');
   },

   showModal: function(component, event, helper){
       component.set("v.bShowModal", true);
       // console.log('showModal');
   },
   
   hideSpinner : function (component, event, helper) {
           var spinner = component.find('spinner');
           var evt = spinner.get("e.toggle");
           evt.setParams({ isVisible : false });
           evt.fire();    
   }   
})