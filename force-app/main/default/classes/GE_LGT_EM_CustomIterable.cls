/*
###########################################################################
# File..................:GE_LGT_EM_CustomIterable
# Version...............: 1.0
# Created by............:Jojan,Murugan,Snehil
# Created Date..........: 
# Description...........: This class is used to create for Custom pagination used to next and previous method .  
#               
*/

global class GE_LGT_EM_CustomIterable implements Iterator<list<GE_LGT_EM_CategoryInner>>{ 
  
  //***** declaration parts Starts here******
  
 List<GE_LGT_EM_InvoiceLineItem__c> category {get; set;} 
    list<GE_LGT_EM_CategoryInner> accInnerList {get; set;} 
    list<GE_LGT_EM_CategoryInner> accInnerListRequested {get; set;} 
   list<GE_LGT_EM_CategoryInner> getrecordList {get; set;}  
  GE_LGT_EM_CategoryInner accInnerObj;
 GE_LGT_EM_CategoryInner getInnerObj; 
   Integer i {get; set;} 
  public Integer setPageSize {get; set;}
   
  //**** declaration parts End here ****
  
  //**** constructor Method ****
  // ****Fething database record and setting the page size**** 
   public GE_LGT_EM_CustomIterable(string sQuery){ 
      
       category = Database.Query(sQuery);
       accInnerList = new list<GE_LGT_EM_CategoryInner>(); 
       accInnerListRequested = new list<GE_LGT_EM_CategoryInner>();     
       for(GE_LGT_EM_InvoiceLineItem__c a :category) {
            accInnerObj = new GE_LGT_EM_CategoryInner(false, a);
            accInnerList.add(accInnerObj);
       } 
       system.debug('accInnerList  %^%^%'+accInnerList.size());
       setPageSize = 10;
       i = 0; 
   }
   
   // ****Getting wrapper Invoice list ****   
global list<GE_LGT_EM_CategoryInner> ListLineItemObj(){

    getrecordList = new list<GE_LGT_EM_CategoryInner>(); 
    
    for(GE_LGT_EM_InvoiceLineItem__c InvItem:category){
    
        getInnerObj= new GE_LGT_EM_CategoryInner(false,InvItem);
        getrecordList.add(getInnerObj);
    
    }     
    system.debug('getrecordList----->'+getrecordList.size());
    return getrecordList;
}

// *******Custom pagination starts here ***********
   global boolean hasNext(){ 
       if(i >= accInnerList.size()) {
           return false; 
       } else {
           return true; 
       }
   } 
   
   global boolean hasPrevious(){ 
       system.debug('I am in hasPrevious' + i);
       if(i <= setPageSize) {
           return false; 
       } else {
           return true; 
       }
   }   

   global list<GE_LGT_EM_CategoryInner> next(){       
       system.debug('i value is ' + i);
       accInnerListRequested = new list<GE_LGT_EM_CategoryInner>(); 
       integer startNumber;
       integer size = accInnerList.size();
       if(hasNext())
       {  
           if(size <= (i + setPageSize))
           {
               startNumber = i;
               i = size;
           }
           else
           {
               i = (i + setPageSize);
               startNumber = (i - setPageSize);
           }
           
           
           
           for(integer start = startNumber; start < i; start++)
           {
               accInnerListRequested.add(accInnerList[start]);
           }
       } 
       return accInnerListRequested;
   } 
   
   global list<GE_LGT_EM_CategoryInner> previous(){      
       accInnerListRequested = new list<GE_LGT_EM_CategoryInner>(); 
       system.debug('i value is previous before =====' + i);
       integer size = accInnerList.size(); 
       if(i == size)
       {
           if(math.mod(size, setPageSize) > 0)
           {    
               i = size - math.mod(size, setPageSize);
           }
           else
           {
               i = (size - setPageSize);
           } 
       }
       else
       {
           i = (i - setPageSize);
       }
       
      
       
       for(integer start = (i - setPageSize); start < i; ++start)
       {
           accInnerListRequested.add(accInnerList[start]);
       } 
       return accInnerListRequested;
   } 
   // *******Custom pagination End here ***********  
}