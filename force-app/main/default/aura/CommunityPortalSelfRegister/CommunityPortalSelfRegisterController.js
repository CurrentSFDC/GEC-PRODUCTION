({
    doInit: function(component, event, helper) {
        helper.fetchPrefferedLanguagePicklistVal(component); 

        helper.getCountries(component);
        helper.getStates(component);
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s/"));        
        component.set("v.cbaseURLTerms", baseURL + '/s/terms');  
    },

    updateProvinces: function(component, event, helper) {

        component.set("v.previousCountry", component.get("v.userData.country"));
        helper.getStates(component);
    },

    createUser: function(component, event, helper) {
        
        //if (helper.validateForm(component, helper, true)) {
            component.set(("v.userData.userType"), component.get("v.selectedUserTypeValue"));  
        	component.set(("v.userData.principle"), component.get("v.Principle1"));  //added to check sub type
        	component.set(("v.userData.designer"), component.get("v.Designer1"));  //added to check sub type
        	component.set(("v.userData.outSales"), component.get("v.OutSales1"));  //added to check sub type
        	component.set(("v.userData.techService"), component.get("v.TechService1"));  //added to check sub type
        	component.set(("v.userData.quotation"), component.get("v.Quotation1"));  //added to check sub type
        	component.set(("v.userData.custService"), component.get("v.CustService1"));  //added to check sub type
        	component.set(("v.userData.admin"), component.get("v.Admin1"));  //added to check sub type
        component.set(("v.userData.own"), component.get("v.Own1"));  //added to check sub type
        	component.set(("v.userData.pm"), component.get("v.Pm1"));  //added to check sub type
        	component.set(("v.userData.spec"), component.get("v.Spec1"));  //added to check sub type
        	component.set(("v.userData.proc"), component.get("v.Proc1"));  //added to check sub type
        
        	//console.log("v.selectedUserSubTypeValue",selectedUserSubTypeValue);
       // console.log("v.userData.principle",v.userData.principle);
            component.set(("v.userData.preferredLanguage"), component.get("v.selectedLanguage")); 
            component.set(("v.userData.comments"), component.find("registrationComments").get("v.value"));
            component.set(("v.userData.tnc"), component.get("v.chkTerms"));
            
            var lNameCmp = component.find("lName");
            helper.handleCreateUser(component, helper);
        //}
    },

    handleSelected : function(component, event, helper) {
        let currentValue = event.target.value; 
        console.log("currentValue",currentValue);
        if(currentValue == 'Other'){
            component.set('v.mandatory', true);
            component.set('v.userData.registrationRepCodes','');
            component.set('v.userData.registrationAccounts','');
        } 
        if(currentValue != 'Other'){
            component.set('v.mandatory', false);
        }
        if(currentValue == 'Distributor'){            
            component.set('v.userData.registrationRepCodes','');            
        } 
        if(currentValue == 'Agent'){ 
           // console.log("v.selectedUserSubTypeValue 2",v.selectedUserSubTypeValue);
            component.set('v.userData.registrationAccounts','');//Agent
			console.log("inside agent"); 
           // console.log("v.selectedUserSubTypeValue",v.selectedUserSubTypeValue);
            
            
            
        } 
        component.set('v.selectedUserTypeValue', currentValue);//Agent
        console.log("v.selectedUserTypeValue",currentValue);
       // component.set('v.selectedUserTypeValue', currentValue);//Principle
       // console.log("v.selectedUserSubTypeValue",currentValue);
        
       // console.log("v.selectedUserSubTypeValue",v.selectedUserSubTypeValue);
    },
    onCheck1: function(component,event) {
      
        let currentRoleName = event.target.name;
        let currentRoleValuePri;
        if (currentRoleName == "principle"){
            console.log("inside principle");
             currentRoleValuePri = event.target.checked;//true           
        } 
        component.set('v.Principle1', currentRoleValuePri);  	
        if (currentRoleName == "principle" && currentRoleValuePri == true) {
        	component.set(("v.userData.principle"), component.get("v.Principle1"));
			console.log("v.Principle1",currentRoleValuePri);            
            console.log("inside loop");            
        }
    },
    
      onCheck2: function(component,event) {
      
        let currentRoleName = event.target.name;
        let currentRoleValueDes;
       
        if (currentRoleName == "designer"){
            console.log("inside designer");
            currentRoleValueDes = event.target.checked;
        }
        component.set('v.Designer1', currentRoleValueDes);
        
        if (currentRoleName == "designer" && currentRoleValueDes == true) {
            console.log("inside loop");
        	component.set(("v.userData.designer"), component.get("v.Designer1"));
			console.log("v.Designer1",currentRoleValueDes);            
            console.log("inside loop");
            
        }
       
    },
    onCheck3: function(component,event) {
      
        let currentRoleName = event.target.name;
        let currentRoleValueOs;
       
        if (currentRoleName == "outSales"){
            console.log("inside OS");
            currentRoleValueOs = event.target.checked;
        }
        component.set('v.OutSales1', currentRoleValueOs);
        
        if (currentRoleName == "outSales" && currentRoleValueOs == true) {
            console.log("inside loop");
        	component.set(("v.userData.outSales"), component.get("v.OutSales1"));
			console.log("v.OutSales1",currentRoleValueOs);            
            console.log("inside loop");
            
        }
       
    },
    
    onCheck4: function(component,event) {
      
        let currentRoleName = event.target.name;
        let currentRoleValueTs;
       
        if (currentRoleName == "techService"){
            console.log("inside TS");
            currentRoleValueTs = event.target.checked;
        }
        component.set('v.TechService1', currentRoleValueTs);
        
        if (currentRoleName == "techService" && currentRoleValueTs == true) {
            console.log("inside loop");
        	component.set(("v.userData.techService"), component.get("v.TechService1"));
			console.log("v.TechService1",currentRoleValueTs);            
            console.log("inside loop");
            
        }
       
    },
    
     onCheck5: function(component,event) {
      
        let currentRoleName = event.target.name;
        let currentRoleValueQ;
       
        if (currentRoleName == "quotation"){
            console.log("inside q");
            currentRoleValueQ = event.target.checked;
        }
        component.set('v.Quotation1', currentRoleValueQ);
        
        if (currentRoleName == "quotation" && currentRoleValueQ == true) {
            console.log("inside loop");
        	component.set(("v.userData.quotation"), component.get("v.Quotation1"));
			console.log("v.Quotation1",currentRoleValueQ);            
            console.log("inside loop");
            
        }
       
    },

    onCheck6: function(component,event) {
      
        let currentRoleName = event.target.name;
        let currentRoleValueCS;
       
        if (currentRoleName == "custService"){
            console.log("inside cs");
            currentRoleValueCS = event.target.checked;
        }
        component.set('v.CustService1', currentRoleValueCS);
        
        if (currentRoleName == "custService" && currentRoleValueCS == true) {
            console.log("inside loop");
        	component.set(("v.userData.custService"), component.get("v.custService"));
			console.log("v.custService",currentRoleValueCS);            
            console.log("inside loop");
            
        }
       
    },
    
    onCheck7: function(component,event) {
      
        let currentRoleName = event.target.name;
        let currentRoleValueAdmin;
       
        if (currentRoleName == "admin"){
            console.log("inside ad");
            currentRoleValueAdmin = event.target.checked;
        }
        component.set('v.Admin1', currentRoleValueAdmin);
        
        if (currentRoleName == "admin" && currentRoleValueAdmin == true) {
            console.log("inside loop");
        	component.set(("v.userData.admin"), component.get("v.admin"));
			console.log("v.admin",currentRoleValueAdmin);            
            console.log("inside loop");
            
        }
       
    },
    
    onCheck8: function(component,event) {
      
        let currentRoleName = event.target.name;
        let currentRoleValueOwn;
       
        if (currentRoleName == "own"){
            console.log("inside own");
            currentRoleValueOwn = event.target.checked;
        }
        component.set('v.Own1', currentRoleValueOwn);
        
        if (currentRoleName == "own" && currentRoleValueOwn == true) {
            console.log("inside loop");
        	component.set(("v.userData.own"), component.get("v.own"));
			console.log("v.own",currentRoleValueOwn);            
            console.log("inside loop");           
        }       
    },
    
    onCheck9: function(component,event) {
      
        let currentRoleName = event.target.name;
        let currentRoleValuePm;
       
        if (currentRoleName == "pm"){
            console.log("inside pm");
            currentRoleValuePm = event.target.checked;
        }
        component.set('v.Pm1', currentRoleValuePm);
        
        if (currentRoleName == "pm" && currentRoleValuePm == true) {
            console.log("inside loop");
        	component.set(("v.userData.pm"), component.get("v.pm"));
			console.log("v.pm",currentRoleValuePm);            
            console.log("inside loop");           
        }       
    },
    onCheck10: function(component,event) {
      
        let currentRoleName = event.target.name;
        let currentRoleValueSpec;
       
        if (currentRoleName == "spec"){
            console.log("inside spec");
            currentRoleValueSpec = event.target.checked;
        }
        component.set('v.Spec1', currentRoleValueSpec);
        
        if (currentRoleName == "spec" && currentRoleValueSpec == true) {
            console.log("inside loop");
        	component.set(("v.userData.spec"), component.get("v.spec"));
			console.log("v.spec",currentRoleValueSpec);            
            console.log("inside loop");           
        }       
    },
    onCheck11: function(component,event) {
      
        let currentRoleName = event.target.name;
        let currentRoleValueProc;
       
        if (currentRoleName == "proc"){
            console.log("inside proc");
            currentRoleValueProc = event.target.checked;
        }
        component.set('v.Proc1', currentRoleValueProc);
        
        if (currentRoleName == "proc" && currentRoleValueProc == true) {
            console.log("inside loop");
        	component.set(("v.userData.proc"), component.get("v.proc"));
			console.log("v.proc",currentRoleValueProc);            
            console.log("inside loop");           
        }       
    },
    
    
    handleSelectedLanguage : function(component, event, helper) {        
        let currentValue = event.getSource().get('v.value');        
        component.set('v.selectedLanguage', currentValue);
    },

    termsChanged : function(cmp, event, helper){
        cmp.set("v.chkTerms", document.getElementById("terms").checked );
        //console.log(event.getSource().get("v.checked"));
        // the above didn't work except for `ui:input` or `lightning:input`
    }
})