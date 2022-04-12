trigger Users on User (before update) {
    List<User> users = Trigger.New;
    for (User user : users){
        if (user.CumulativePoints__c < 200){
            user.Rank__c = 'SCOUT';
        } else if (user.CumulativePoints__c < 3000){
            user.Rank__c = 'HIKER';
        } else if (user.CumulativePoints__c < 9000){
            user.Rank__c = 'EXPLORER';
        } else if (user.CumulativePoints__c < 18000){
            user.Rank__c = 'ADVENTURER';
        } else if (user.CumulativePoints__c < 35000){
            user.Rank__c = 'MOUNTAINEER';
        } else if (user.CumulativePoints__c < 50000){
            user.Rank__c = 'EXPEDITIONER';
        } else {
            user.Rank__c = 'RANGER';
        }
    }
}