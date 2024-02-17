public without sharing class RescanUpdater {

    public static void startUpdate(String pmdJSON) {

        List<PMDScanService.ApexClass> apexClassCache =
            (List<PMDScanService.ApexClass>) JSON.deserialize(pmdJSON, List<PMDScanService.ApexClass>.class);
        Map<String, Apex_Class__c> apexClassesByName = fetchApexClasses(apexClassCache);

        updateApexViolations(apexClassCache, apexClassesByName);
    }

    private static Map<String, Apex_Class__c> fetchApexClasses(List<PMDScanService.ApexClass> apexClassCaches) {
        List<String> fileNames = new List<String>();
        for (PMDScanService.ApexClass classCache : apexClassCaches) {
            String fileName = PMDScanService.parseFileName(classCache.fileName);
            fileNames.add(fileName);
        }

        Map<String, Apex_Class__c> apexClassesByName = new Map<String, Apex_Class__c>();
        for (Apex_Class__c apexClass: [
            SELECT Id, Name,
            (SELECT Id, Rule__c, Method__c, Current_Complexity_Score__c FROM Apex_Violations__r)
            FROM Apex_Class__c
            WHERE Name IN :fileNames
        ]) {
            apexClassesByName.put(apexClass.Name, apexClass);
        }
        return apexClassesByName;
    }

    private static void updateApexViolations(List<PMDScanService.ApexClass> apexClassCaches, Map<String, Apex_Class__c> apexClassesByStrings) {
        for (PMDScanService.ApexClass apexClass : apexClassCaches) {
            String fileName = PMDScanService.parseFileName(apexClass.fileName);
            Apex_Class__c savedApexClass = apexClassesByStrings.get(fileName);
        }
        /** todo:
         *     1. Check for usages of Starting_Complexity_Score__c and Current_Complexity_Score__c
         *     2. Change field name to Complexity Score and delete Starting_Complexity_Score__c
         *     3. Add new Complexity_Score__c to the SOQL above
         *     5. any violation not found in the cache should get Is_Resolved__c = true
        */


    }
}
