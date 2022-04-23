public with sharing class ModuleController {

    @AuraEnabled(cacheable=true)
    public static List<Unitservice.UnitWrapper> getUnitWrapsByMod(id moduleId) {
        UnitService us = new UnitService();
        system.debug('Estoy dentro del metodo getUnitWrapsByMod');
        return us.getUnitWrapsByModule(moduleId);
    }
}
