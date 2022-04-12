public class UnitResponseTrigger{

    public static void onBeforeUpdate(List<Unit_progress__c> unitRespList, Map<Id,Unit_progress__c> oldUnitRespMap){
        List<Unit_progress__c> answeredUnitRespList = new List<Unit_progress__c>();
        for(Unit_progress__c unitResp : unitRespList){
            if(unitResp.Unit_Stage__c == 'Answered' && oldUnitRespMap.get(unitResp.Id).Unit_Stage__c == 'Draft'){
                answeredUnitRespList.add(unitResp);
            }
        }

        validateAnswers(answeredUnitRespList);

    }

    public static void onAfterUpdate(List<Unit_progress__c> unitRespList, Map<Id,Unit_progress__c> oldUnitRespMap){
        List<Unit_progress__c> correctUnitRespList = new List<Unit_progress__c>();
        for (Unit_progress__c unitResp : unitRespList){
            if(unitResp.Unit_completed__c && !oldUnitRespMap.get(unitResp.Id).Unit_completed__c){
                correctUnitRespList.add(unitResp);
            }
        }
        updateUserPoints(correctUnitRespList);

    }

    private static void updateUserPoints(List<Unit_progress__c> correctUnitRespList){
        Set<Id> userIds = new Set<Id>();
        for(Unit_progress__c unitResp : correctUnitRespList){
            userIds.add(unitResp.UserId__c);
        }

        Map<Id,User> usersMap = new Map<Id,User>([SELECT ID, CumulativePoints__c FROM USER WHERE Id in :userIds]);

        for (Unit_progress__c unitResp : correctUnitRespList){
            User us = usersMap.get(unitResp.UserId__c);
            us.CumulativePoints__c += unitResp.Student_Unit_Score__c;
        }

        update usersMap.values();
    }
    

    private static void validateAnswers(List<Unit_progress__c> unitRespList){
        
        Map<Id,Unit_progress__c> unitRespFromDbMap = new Map<Id,Unit_progress__c>([SELECT Id, Student_Unit_Score__c, Unit__r.Max_Score__c,(SELECT Id, Option__r.IsRight__c FROM Question_s_Answers__r) FROM Unit_progress__c WHERE Id in 
        : unitRespList]);

        //200
        for(Unit_progress__c unitResp : unitRespList){

            Unit_progress__c unitRespFromDb = unitRespFromDbMap.get(unitResp.Id);

            unitResp.Unit_completed__c = true;
            unitResp.Unit_Stage__c = 'Success';
            //10
            for(Question_s_Answer__c questionResp : unitRespFromDb.Question_s_Answers__r){
                //10 * 200 = 2000
                if(!questionResp.Option__r.IsRight__c){
                    unitResp.Unit_completed__c = false;
                    unitResp.Unit_Stage__c = 'Fail';
                    break;
                }
            }
            if (unitResp.Unit_completed__c){
                Double maxScore = unitResp.Unit__r.Max_Score__c;
                if (unitResp.Num_of_tries__c==1) {
                    unitResp.Student_Unit_Score__c = maxScore;
                } else if (unitResp.Num_of_tries__c == 2){
                    unitResp.Student_Unit_Score__c = maxScore/2;
                } else {
                    unitResp.Student_Unit_Score__c = maxScore/4;
                }
            }
        }
    }



}