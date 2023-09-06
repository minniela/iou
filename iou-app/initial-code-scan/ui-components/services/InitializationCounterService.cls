public without sharing class InitializationCounterService {

    @AuraEnabled
    public static Response getViolationCountDetails() {
        Response response = new Response();
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
