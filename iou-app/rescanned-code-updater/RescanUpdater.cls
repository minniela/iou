public without sharing class RescanUpdater {

    public static void startUpdate(String pmdJSON) {

        List<ApexClass> apexClassCache = (List<ApexClass>) JSON.deserialize(pmdJSON, List<ApexClass>.class);

        Map<String, Apex_Class__c> apexClassesByName = updateApexClasses(apexClassCache);
        updateApexViolations(apexClassCache, apexClassesByName);
    }

    private static Map<String, Apex_Class__c> updateApexClasses(List<ApexClass> apexClasses) {
        return null;
    }

    private static void updateApexViolations(List<ApexClass> apexClasses, Map<String, Apex_Class__c> apexClassesByStrings) {

    }
}
