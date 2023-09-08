public without sharing class IOUCleanClassService {

    public class Response {
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public CleanClasses cleanClasses = new CleanClasses();
    }

    public class CleanClasses {
        @AuraEnabled
        public Integer classCount = 0;
        @AuraEnabled
        public Integer goodPercentage = 0;
    }
}
