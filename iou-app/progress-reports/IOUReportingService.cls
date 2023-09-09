public without sharing class IOUReportingService {

    public static Response getData(String scope) {
        Response response = new Response();

        if (scope == 'startingPoint') {
            //todo: need new fields on Apex Violation to capture progress and retain original state
            //  - Resolved Count

            //todo: ensure Apex Violations have methods name set, as they are the only identity we need to
            //      properly update complexity violations, the others can be resolved without distinction
        }
        else if (scope == 'currentState') {

        }

        return response;
    }



    public class Response {
        @AuraEnabled
        public Boolean success = true;
        @AuraEnabled
        public Map<String, Metrics> metricsByType = new Map<String, IOUReportingService.Metrics>();
    }

    public class Metrics {
        @AuraEnabled
        public Integer classCount = 0;
        @AuraEnabled
        public Integer violations = 0;
        @AuraEnabled
        public Integer min = 0;
        @AuraEnabled
        public Integer max = 0;
        @AuraEnabled
        public Integer average = 0;
        @AuraEnabled
        public Integer mean = 0;
    }
}
