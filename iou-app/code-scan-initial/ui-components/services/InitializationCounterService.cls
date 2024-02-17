public without sharing class InitializationCounterService {

    @AuraEnabled
    public static Response getViolationCountDetails() {
        Response response = new Response();

        for (Apex_Class__c apexClass: [
            SELECT Starting_Violation_Count__c, Has_Trigger_Logic__c
            FROM Apex_Class__c
        ]) {
            response.classCount += 1;
            response.violationCount += Integer.valueOf(apexClass.Starting_Violation_Count__c);
            if (!response.triggerAuditHasStarted) {
                response.triggerAuditHasStarted = apexClass.Has_Trigger_Logic__c;
            }
        }

        return response;
    }

    public class Response {
        @AuraEnabled
        public Integer classCount = 0;
        @AuraEnabled
        public Integer violationCount = 0;
        @AuraEnabled
        public Boolean triggerAuditHasStarted = false;
    }
}
