global class GE_LGT_EM_BatchUpdateMaterialNo_5 implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
    GE_LGT_EM_BatchUpdateMaterialNumber1 b = new GE_LGT_EM_BatchUpdateMaterialNumber1(); //ur batch class
      database.executebatch(b);
      
      /*
        GE_LGT_EM_BatchUpdateMaterialNo_5 j = new GE_LGT_EM_BatchUpdateMaterialNo_5();
        //String sch = '0 0 0,3,6,9,12,15,18,21 ? * *';
        String sch = '0 0 1,3,5,7,9,13,15,17,19,21,23 * * ?';
        System.schedule('GE_LGT_EM_BatchUpdateMaterialstring', sch, j);
      
      */
      
    }
}