public class UnitService {
    public class CustomException extends Exception {}
    public static boolean registerUnitResponse(Id unitId, String jsonAnswer){
        Savepoint sp = Database.setSavePoint();
        try{
            //buscar unidad asociada al Id unitId
            Unit__c unit = [SELECT Module__c, (SELECT Id, Num_of_tries__c FROM Units_progress__r WHERE Module_Progress__r.User__c =: UserInfo.getUserId() ORDER BY Num_of_tries__c DESC LIMIT 1) ,(SELECT Id, Name FROM Questions__r) FROM Unit__c WHERE ID = :unitId];
            
            //verificamos si module_progress existe
            Module_Progress__c moduleResp = [SELECT ID FROM Module_Progress__c 
                                             WHERE Module__c=:unit.Module__c AND User__c=:UserInfo.getUserId() AND Module_Status__c = 'In Progress'];
            // si el Module_Progress__c no existe, lo creo
            if (moduleResp==NUll){
                //crear e insertar module_progress (primera unidad respondida)
                moduleResp = new Module_Progress__c(User__c=UserInfo.getUserId(), Module__c=unit.Module__c, Module_Status__c='In progress'); 
            	insert moduleResp;
            }
            
            //crear e insertar unit_progress
            Unit_progress__c unitResp = new Unit_progress__c(Unit__c=unitId, Module_Progress__c= moduleResp.Id , Unit_Stage__c='Draft');
            //NTH
            unitResp.Num_of_tries__c = !unit.Units_progress__r.isEmpty() ? unit.Units_progress__r[0].Num_of_tries__c + 1 : 1;
            insert unitResp;
            //Creo y cargo question_progress
            Map<Id,Id> answerMap = (Map<Id,Id>)JSON.deserializeStrict(jsonAnswer, Map<Id,Id>.class);
            List<Question_s_Answer__c> questionRespList = new List<Question_s_Answer__c>(); 
            for(Question__c question : unit.Questions__r){
                if(answerMap.containsKey(question.Id)){
                    Question_s_Answer__c questionResp = new Question_s_Answer__c(Question__c=question.Id,Unit_progress__c=unitResp.Id,Option__c=answerMap.get(question.Id));
                	questionRespList.add(questionResp);
                } else {
                    throw new CustomException('La pregunta ' + question.Name + ' no fue respondida y es requerida.');
                }
            }
            /*for(ID questionId : answerMap.keySet()){
                Question_s_Answer__c questionResp = new Question_s_Answer__c(Question__c=questionId,Unit_progress__c=unitResp.Id,Option__c=answerMap.get(questionId));
                questionRespList.add(questionResp);
            }*/
            insert questionRespList;
            
            // actualizamos el Unit_progress con Unit_Stage='Answered' para luego disparar el trigger de evaluacion
            unitResp.Unit_Stage__c = 'Answered';
            update unitResp;
            // consultar si es necesaria la query o se puede retornar directamente unitResp.Unit_completed__c
            return [SELECT Unit_completed__c FROM Unit_progress__c WHERE Id=:unitResp.Id].Unit_completed__c; 
            
        } catch (Exception e){
            Database.rollback(sp);
            throw e;
        }   
    }  
    //////////////////////////////////////////////// cambiar los valores de las variables y revisar
    public class TrailWrapper{
        //Constructor
        public TrailWrapper(Trail__c trail, List<Module__c> modules, Set<Id> passedModuleIds, Set<Id> passedUnitIds){
            this.trail = trail;
            this.modules = modules;
            this.passedModuleIds = passedModuleIds;
            this.passedUnitIds = passedUnitIds;
            this.progressTrail = passedModuleIds.size()*100 / modules.size();
        }
        //Configuracion
        @AuraEnabled
        public Trail__c trail; //Registro de Trail solicitado
        @AuraEnabled
        public List<Module__c> modules; //Módulos con Unidades relacionadas
        
        //Transaccional
        //@AuraEnabled
        public Set<Id> passedModuleIds; //Ids de módulos relacionados al Trail actual en los que el Alumno ya aprobó
        //@AuraEnabled
        public Set<Id> passedUnitIds; //Ids de Unidades relacionadas a módulos del Trail actual que el Alumno ya aprobó
        @AuraEnabled
        public Integer progressTrail; //Porcentaje de progreso del Alumno en el Trail     

    }

    //Metodos
    
    public TrailWrapper getTrailWrapper(Id trailId){

        //Instancio trail wrapper con trail y modulos
        TrailWrapper trailWrap = new TrailWrapper([SELECT Name, Description__c, Trail_Estimated_Time__c, Trail_Max_Score__c FROM Trail__c WHERE Id =: trailId], getModules(trailId), getModuleIdsCompleted(trailId), getUnitIdsCompleted(trailId));

        return trailWrap;
    }
        // esto lo agregue luego (borrar)
    public String getTrailName(Id trailId){

        Trail__c trail1 = [SELECT Name, Description__c FROM Trail__c WHERE Id =: trailId];

        return trail1.Name;
    }
        // borrar hasta aca

    private List<Module__c> getModules(Id trailId){
        //Busco modulos relacionados
        List<Trail_Module__c> trailModules = [SELECT Module__c FROM Trail_Module__c WHERE Trail__c =: trailId];
        Set<Id> moduleIds = new Set<Id>();
        for(Trail_Module__c trailModule : trailModules){
            moduleIds.add(trailModule.Module__c);
        }
        return [SELECT Name, (SELECT Name FROM Units__r) FROM Module__c WHERE Id in : moduleIds];
    }

    private Set<Id> getModuleIdsCompleted(Id trailId){
        List<Module_Progress__c> moduleResponses = [SELECT Module__c FROM Module_Progress__c WHERE Module_Status__c = 'Completed' AND Module__c IN :getModules(trailId) AND User__c =: Userinfo.getUserId()];
        Set<Id> completedModuleIds = new Set<Id>();
        for(Module_Progress__c moduleResp : moduleResponses){
            completedModuleIds.add(moduleResp.Module__c);
        }

        return completedModuleIds;
    }
    private Set<Id> getUnitIdsCompleted(Id trailId){
        List<Unit_progress__c> unitResponses = [SELECT Unit__c FROM Unit_progress__c WHERE Unit_completed__c = true AND UserId__c =: Userinfo.getUserId() AND Unit__r.Module__c IN :getModules (trailId)];
        Set<Id> completedUnitIds = new Set<Id>();
        for(Unit_progress__c unitResp : unitResponses){
            completedUnitIds.add(unitResp.Unit__c);
        }

        return completedUnitIds;
    }

    /**********Class UnitWrapper************/
    public class UnitWrapper{
        //varibles
        public Unit__c unit;
        public List<Question__c> questions;
        
        //Constructor
        public UnitWrapper(Unit__c unit, List<Question__c> questions){
            this.unit = unit;
            this.questions = questions;
        }
    }
    
    //UnitWrapper's Methods
    public UnitWrapper getUnitWrapper(Id unitId){

        //Query to Unit
        unit__c unit = [SELECT Id, Name, Content__c, Estimated_time__c, Max_Score__c, Test_Type__c 
                        FROM Unit__c 
                        WHERE Id = :unitId];
        
        List<Question__c> questionsList = [
            SELECT Id, Name, Query__c, (SELECT Id, Name, Description__c, isRight__c FROM Options__r) 
            FROM Question__c 
            WHERE Unit__c = :unitId];
                
        return new UnitWrapper(unit, questionsList);
    }
}