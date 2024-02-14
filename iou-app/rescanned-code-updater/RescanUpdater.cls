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
        for (Apex_Class__c apexClass: [
            SELECT Id, Name,
            (SELECT Id, Rule__c FROM Apex_Violations__r)
            FROM Apex_Class__c
            WHERE Name IN :fileNames
        ]) {
            apexClassesByName.put(apexClass.Name, apexClass);
        }
        return apexClassesByName;
    }

    private static void updateApexViolations(List<ApexClass> apexClassCaches, Map<String, Apex_Class__c> apexClassesByStrings) {
        /** todo:
         *     1. Check for usages of Starting_Complexity_Score__c and Current_Complexity_Score__c
         *     2. Change field name to Complexity Score and delete Starting_Complexity_Score__c
         *     3. Add new Complexity_Score__c to the SOQL above
         *     3. Add Has_Improved__c checkbox on Apex_Violation__c
         *     4. On Upsert, all violations that are touched are marked as Has_Improved__c, as surrounding context is better
         *     5. any violation not found in the cache should get Is_Resolved__c = true
        */


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
