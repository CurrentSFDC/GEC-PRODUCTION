global class GE_LGT_EM_BatchUpdateSAPInvNo_2 implements schedulable
{
    global void execute(SchedulableContext sc)
    {
    GE_LGT_EM_BatchUpdateSAPInvoiceNumber b = new GE_LGT_EM_BatchUpdateSAPInvoiceNumber(); //ur batch class
      database.executebatch(b);
      
      /*
      
      GE_LGT_EM_BatchUpdateSAPInvNo_2 j = new GE_LGT_EM_BatchUpdateSAPInvNo_2();
        String sch = '0 0 0,3,6,9,12,15,18,21 ? * *';
        System.schedule('GE_LGT_EM_BatchUpdateSAPInvoiceNumber', sch, j);
      
      */
    }
}