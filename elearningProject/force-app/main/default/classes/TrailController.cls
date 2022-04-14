public with sharing class TrailController {
    @AuraEnabled(cacheable=true)
    public static Trail__c getTrail(id trailId) {
        UnitService us = new UnitService();
        return us.getTrailWrapper(trailId).trail;
    }
}