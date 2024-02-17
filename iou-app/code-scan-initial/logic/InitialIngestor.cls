public without sharing class InitialIngestor {

    public static Response response = new Response(true, 'IOU Data Populated', 'all good!');

    @AuraEnabled
    public static Response startOver() {
        response.title = 'IOU Records Deleted';
        List<Apex_Class__c> apexClass = [SELECT Id FROM Apex_Class__c];
        try {
            delete apexClass;
            Database.emptyRecycleBin(apexClass);
        }
        catch (Exception ex) {
            configureFailResponse('IOU Record Deletion failed', ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response initiate(String staticResource) {
        if (String.isBlank(staticResource)) { staticResource = 'initialCodeScan'; }

        StaticResource pmdScan = [SELECT Body FROM StaticResource WHERE Name = :staticResource LIMIT 1];
        List<PMDScanService.ApexClass> apexClassCache =
            (List<PMDScanService.ApexClass>) JSON.deserialize(pmdScan.Body.toString(), List<PMDScanService.ApexClass>.class);

        Map<String, Apex_Class__c> apexClassesByName = createApexClasses(apexClassCache);
        createApexViolations(apexClassCache, apexClassesByName);

        return response;
    }

    private static Map<String, Apex_Class__c> createApexClasses(List<PMDScanService.ApexClass> apexClassCaches) {
        Map<String, Apex_Class__c> apexClassesByName = new Map<String, Apex_Class__c>();
        for (PMDScanService.ApexClass classCache : apexClassCaches) {
            String fileName = PMDScanService.parseFileName(classCache.fileName);
            Apex_Class__c apexClass = new Apex_Class__c(
                Name = fileName
            );
            apexClassesByName.put(apexClass.Name, apexClass);
        }
        try {
            insert apexClassesByName.values();
        }
        catch (Exception ex) {
            configureFailResponse('Failed to Create Apex Classes', ex.getMessage());
        }
        return apexClassesByName;
    }

    private static void createApexViolations(
        List<PMDScanService.ApexClass> apexClassCaches, Map<String, Apex_Class__c> apexClassesByName
    ) {
        List<Apex_Violation__c> apexViolations = new List<Apex_Violation__c>();
        for (PMDScanService.ApexClass classCache : apexClassCaches) {
            String fileNameKey = PMDScanService.parseFileName(classCache.fileName);
            Apex_Class__c apexClass = apexClassesByName.get(fileNameKey);

            for (PMDScanService.ApexViolation violationCache: classCache.violations) {
                Apex_Violation__c apexViolation = configureViolation(violationCache, apexClass);
                apexViolations.add(apexViolation);
            }
        }
        try {
            insert apexViolations;
        }
        catch (Exception ex) {
            configureFailResponse('Failed to Create Apex Violations', ex.getMessage());
        }
    }

    private static Apex_Violation__c configureViolation(PMDScanService.ApexViolation violationCache, Apex_Class__c apexClass) {
        Apex_Violation__c apexViolation = new Apex_Violation__c(
            Rule__c = violationCache.ruleName,
            Category__c = CategoryTranslatorService.translate(violationCache.ruleName),
            Reference__c = violationCache.url,
            Message__c = violationCache.message.trim(),
            Starting_Line__c = Integer.valueOf(violationCache.line),
            Ending_Line__c = Integer.valueOf(violationCache.endLine),
            Apex_Class__c = apexClass.Id
        );
        if (new List<String>{'CognitiveComplexity', 'CyclomaticComplexity'}.contains(violationCache.ruleName)) {
            apexViolation.Method__c = PMDScanService.parseMethodName(violationCache.message);
            apexViolation.Starting_Complexity_Score__c = PMDScanService.parseComplexityScore(violationCache.message);
        }
        return apexViolation;
    }

    @TestVisible
    private static void configureFailResponse(String title, String message) {
        response.success = false;
        response.title = title;
        response.message = message;
    }

    public class Response {
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String message;

        public Response(Boolean success, String title, String message) {
            this.success = success;
            this.title = title;
            this.message = message;
        }
    }
}
