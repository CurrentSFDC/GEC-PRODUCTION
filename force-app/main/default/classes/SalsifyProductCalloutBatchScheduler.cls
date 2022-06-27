global class SalsifyProductCalloutBatchScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        
        SalsifyProductCalloutBatch myBatchObject = new SalsifyProductCalloutBatch();
        Database.executeBatch(myBatchObject,50);
        
        
    }
}