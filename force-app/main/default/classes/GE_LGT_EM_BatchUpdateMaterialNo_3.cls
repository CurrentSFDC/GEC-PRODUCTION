global class GE_LGT_EM_BatchUpdateMaterialNo_3 implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
    GE_LGT_EM_BatchUpdateMaterialNumber b = new GE_LGT_EM_BatchUpdateMaterialNumber(); //ur batch class
      database.executebatch(b);
      
      /*
        GE_LGT_EM_BatchUpdateMaterialNo_3 j = new GE_LGT_EM_BatchUpdateMaterialNo_3();
        String sch = '0 0 0,3,6,9,12,15,18,21 ? * *';
        System.schedule('GE_LGT_EM_BatchUpdateMaterialNo', sch, j);
      
      */
      
    }
}