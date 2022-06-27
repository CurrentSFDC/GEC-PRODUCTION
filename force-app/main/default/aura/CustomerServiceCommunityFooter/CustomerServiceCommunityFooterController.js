({
    doInit : function(component, event, helper) {
        var todayDate = new Date();
        var yearOfToday = todayDate.getFullYear();
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s/"));
        component.set("v.cbaseURLPrivacy", baseURL + '/s/privacy');  
        component.set("v.cbaseURLTerms", baseURL + '/s/terms');  
        component.set("v.thisYear", yearOfToday)
    }
})