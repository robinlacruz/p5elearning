public with sharing class TrailController {

    @AuraEnabled(cacheable=true)
    public static UnitService.TrailWrapper getTrailWrap(id trailId) {
        UnitService us = new UnitService();
        return us.getTrailWrapper(trailId);
    }

}