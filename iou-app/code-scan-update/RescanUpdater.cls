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
            SELECT Id, Name, (
                SELECT Is_Resolved__c, Rule__c, Method__c, Current_Complexity_Score__c, Starting_Line__c, Ending_Line__c
                FROM Apex_Violations__r
            )
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
            Map<String, List<Apex_Violation__c>> savedViolationsByRule = sortViolationsIntoRuleNameLists(savedApexClass.Apex_Violations__r);

            List<Apex_Violation__c> unresolvedViolations = new List<Apex_Violation__c>();
            for (PMDScanService.ApexViolation apexViolation : apexClass.violations) {
                if (savedViolationsByRule.containsKey(apexViolation.ruleName) && savedViolationsByRule.get(apexViolation.ruleName).size() > 0) {
                    Apex_Violation__c unresolvedViolation = savedViolationsByRule.get(apexViolation.ruleName).remove(0);
                    unresolvedViolation = updateViolation(apexViolation, unresolvedViolation);

                    unresolvedViolations.add(unresolvedViolation);
                }
            }

            List<Apex_Violation__c> resolvedViolations = new List<Apex_Violation__c>();
            for (String className : savedViolationsByRule.keySet()) {
                for (Apex_Violation__c resolvedViolation: savedViolationsByRule.get(className)) {
                    resolvedViolation.Is_Resolved__c = true;
                    resolvedViolation.Current_Complexity_Score__c = 0;
                }
            }
        }
    }

    private static Map<String, List<Apex_Violation__c>> sortViolationsIntoRuleNameLists(List<Apex_Violation__c> violations) {
        Map<String, List<Apex_Violation__c>> violationsByRule = new Map<String, List<Apex_Violation__c>>();
        for (Apex_Violation__c apexViolation : violations) {
            if (!violationsByRule.containsKey(apexViolation.Rule__c)) {
                violationsByRule.put(apexViolation.Rule__c, new List<Apex_Violation__c>());
            }
            violationsByRule.get(apexViolation.Rule__c).add(apexViolation);
        }
        return violationsByRule;
    }

    private static Apex_Violation__c updateViolation(PMDScanService.ApexViolation inMemoryViolation, Apex_Violation__c apexViolation) {
        apexViolation.Message__c = inMemoryViolation.message.trim();
        apexViolation.Starting_Line__c = Integer.valueOf(inMemoryViolation.line);
        apexViolation.Ending_Line__c = Integer.valueOf(inMemoryViolation.endLine);

        if (new List<String>{'CognitiveComplexity', 'CyclomaticComplexity'}.contains(inMemoryViolation.ruleName) &&
            apexViolation.Method__c == PMDScanService.parseMethodName(inMemoryViolation.message)
        ) {
            apexViolation.Current_Complexity_Score__c = PMDScanService.parseComplexityScore(inMemoryViolation.message);
        }
        return apexViolation;
    }
}
