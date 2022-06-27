global class GE_LGT_EM_BatchUpdateCMRDMRComp_4 implements schedulable
{
    global void execute(SchedulableContext sc)
    {
    GE_LGT_EM_BatchUpdateCMRDMRComplaint b = new GE_LGT_EM_BatchUpdateCMRDMRComplaint(); //your batch class name
      database.executebatch(b);
            
       /*
        GE_LGT_EM_BatchUpdateCMRDMRComp_4 j = new GE_LGT_EM_BatchUpdateCMRDMRComp_4();
        String sch = '0 0 0,3,6,9,12,15,18,21 ? * *';
        System.schedule('GE_LGT_EM_BatchUpdateCMRDMRComplaint', sch, j);
      
      */
    }
}