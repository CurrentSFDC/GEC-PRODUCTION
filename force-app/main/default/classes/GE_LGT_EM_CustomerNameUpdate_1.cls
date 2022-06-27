global class GE_LGT_EM_CustomerNameUpdate_1 implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
    GE_LGT_EM_BatchUpdateCustomerNameHeader b = new GE_LGT_EM_BatchUpdateCustomerNameHeader(); //ur batch class
          database.executebatch(b);
          
          /*
          
            GE_LGT_EM_CustomerNameUpdate_1 j = new GE_LGT_EM_CustomerNameUpdate_1();
            String sch = '0 0 0,3,6,9,12,15,18,21 ? * *';
            System.schedule('GE_LGT_EM_BatchUpdateCustomerNameHeader', sch, j);
          
          */
          
          
    }
}