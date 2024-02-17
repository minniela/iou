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

            List<PMDScanService.ApexViolation> foundViolations = apexClass.violations;
            Map<String, List<Apex_Violation__c>> savedViolationsByRule = sortViolationsIntoRuleNameLists(savedApexClass.Apex_Violations__r);
        }
        /** todo:
         *     5. any violation not found in the cache should get Is_Resolved__c = true
        */


    }

    private static Map<String, List<Apex_Violation__c>> sortViolationsIntoRuleNameLists(List<Apex_Violation__c> violations) {
        Map<String, List<Apex_Violation__c>> violationsByRule = new Map<String, List<Apex_Violation__c>>();
        for (Apex_Violation__c apexViolation : violations) {

        }
        return violationsByRule;
    }

    private static Apex_Violation__c configureViolation(PMDScanService.ApexViolation violationCache, Apex_Class__c apexClass) {
        Apex_Violation__c apexViolation = new Apex_Violation__c(
            Message__c = violationCache.message.trim(),
            Starting_Line__c = Integer.valueOf(violationCache.line),
            Ending_Line__c = Integer.valueOf(violationCache.endLine)
        );
        if (new List<String>{'CognitiveComplexity', 'CyclomaticComplexity'}.contains(violationCache.ruleName)) {
            apexViolation.Method__c = PMDScanService.parseMethodName(violationCache.message);
            apexViolation.Starting_Complexity_Score__c = PMDScanService.parseComplexityScore(violationCache.message);
        }
        return apexViolation;
    }
}
