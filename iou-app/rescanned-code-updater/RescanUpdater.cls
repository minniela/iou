public without sharing class RescanUpdater {

    public static void startUpdate(String pmdJSON) {

        List<ApexClass> apexClassCache = (List<ApexClass>) JSON.deserialize(pmdJSON, List<ApexClass>.class);
        Map<String, Apex_Class__c> apexClassesByName = fetchApexClasses(apexClassCache);
        
        updateApexViolations(apexClassCache, apexClassesByName);
    }

    private static Map<String, Apex_Class__c> fetchApexClasses(List<ApexClass> apexClassCaches) {
        List<String> fileNames = new List<String>();
        for (ApexClass classCache : apexClassCaches) {
            String fileName = InitialIngestor.parseFileName(classCache.fileName);
            fileNames.add(fileName);
        }

        Map<String, Apex_Class__c> apexClassesByName = new Map<String, Apex_Class__c>();
        for (Apex_Class__c apexClass: [SELECT Id, Name FROM Apex_Class__c WHERE Name IN :fileNames]) {
            apexClassesByName.put(apexClass.Name, apexClass);
        }
        return apexClassesByName;
    }

    private static void updateApexViolations(List<ApexClass> apexClassCaches, Map<String, Apex_Class__c> apexClassesByStrings) {

    }

    public class ApexClass {
        public String fileName;
        public List<ApexViolation> violations;
    }

    public class ApexViolation {
        public String ruleName;
        public String message;
        public String category;
        public String url;
        public String line;
        public String endLine;
    }
}
