public without sharing class IOUImprovementService {

    public class Response {
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public Improvements improvements = new Improvements();
    }

    public class Improvements {
        @AuraEnabled
        public Integer resolvedViolations = 0;
        @AuraEnabled
        public Integer improvedClasses = 0;
        @AuraEnabled
        public Integer codeCoverageIncrease = 0;
    }
}
