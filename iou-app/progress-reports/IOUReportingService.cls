public without sharing class IOUReportingService {



    public class Response {
        @AuraEnabled
        public Boolean success;
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
