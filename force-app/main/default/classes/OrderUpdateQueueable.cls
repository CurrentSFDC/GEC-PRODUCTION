public class OrderUpdateQueueable implements Queueable{

	private List<ccrz__E_Order__c> ordersToUpdate;

	public OrderUpdateQueueable(List<ccrz__E_Order__c> orders) {
		this.ordersToUpdate = orders;
	}

	public void execute(QueueableContext context) {
		update ordersToUpdate;
	}
}