trigger UnitResponses on Unit_progress__c(before update){
    if (Trigger.isBefore){
        UnitResponseTrigger.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    } else {
        UnitResponseTrigger.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}