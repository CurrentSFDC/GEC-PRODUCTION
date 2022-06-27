Trigger SetUserCreateDate on User (before insert) {
    for (User userInLoop : Trigger.new) {
        userInLoop.UserCreateDate__c = datetime.NOW();
    }
}