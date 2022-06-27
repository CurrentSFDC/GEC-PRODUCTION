public class eMailMessageMethods {
	public static void afterInsert(List<EmailMessage> newList, Map<Id, EmailMessage> newMap)
    {
        eMailMessageTriggerHelper.updateCaseDescription(newList, newMap);
    }
}