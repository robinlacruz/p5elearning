public with sharing class TrailController {

    @AuraEnabled(cacheable=true)
    public static Trail__c getTrail(id trailId) {
        UnitService us = new UnitService();

        return us.getTrailWrapper(trailId).trail;
    }

    @AuraEnabled(cacheable=true)
    public static List<Module__c> getModules(id trailId) {
        UnitService us = new UnitService();

        return us.getTrailWrapper(trailId).modules;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Id> getPassedModuleIds(id trailId) {
        UnitService us = new UnitService();

        return new List<Id>(us.getTrailWrapper(trailId).passedModuleIds);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Id> getPassedUnitIds(id trailId) {
        UnitService us = new UnitService();

        return new List<Id>(us.getTrailWrapper(trailId).passedUnitIds);
    }

    @AuraEnabled(cacheable=true)
    public static Double getProgressTrail(id trailId) {
        UnitService us = new UnitService();

        return us.getTrailWrapper(trailId).progressTrail;
    }

}