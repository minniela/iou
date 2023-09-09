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
        List<ApexClass> apexClassCache = (List<ApexClass>) JSON.deserialize(pmdScan.Body.toString(), List<ApexClass>.class);

        Map<String, Apex_Class__c> apexClassesByName = createApexClasses(apexClassCache);
        Map<Apex_Class__c, List<Apex_Violation__c>> violationListByApexClass = createApexViolations(apexClassCache, apexClassesByName);

        return response;
    }

    private static Map<String, Apex_Class__c> createApexClasses(List<ApexClass> apexClassCaches) {
        Map<String, Apex_Class__c> apexClassesByName = new Map<String, Apex_Class__c>();
        for (ApexClass classCache : apexClassCaches) {
            String fileName = parseFileName(classCache.fileName);
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

    private static Map<Apex_Class__c, List<Apex_Violation__c>> createApexViolations(
        List<ApexClass> apexClassCaches, Map<String, Apex_Class__c> apexClassesByName
    ) {
        List<Apex_Violation__c> apexViolations = new List<Apex_Violation__c>();
        Map<Apex_Class__c, List<Apex_Violation__c>> violationListByApexClass = new Map<Apex_Class__c, List<Apex_Violation__c>>();
        for (ApexClass classCache : apexClassCaches) {
            String fileNameKey = parseFileName(classCache.fileName);
            Apex_Class__c apexClass = apexClassesByName.get(fileNameKey);

            for (ApexViolation violationCache: classCache.violations) {
                Apex_Violation__c apexViolation = configureViolation(violationCache, apexClass);
                apexViolations.add(apexViolation);

                if (!violationListByApexClass.containsKey(apexClass)) {
                    violationListByApexClass.put(apexClass, new List<Apex_Violation__c>());
                }
                violationListByApexClass.get(apexClass).add(apexViolation);
            }
        }
        try {
            insert apexViolations;
        }
        catch (Exception ex) {
            configureFailResponse('Failed to Create Apex Violations', ex.getMessage());
        }
        return violationListByApexClass;
    }

    private static Apex_Violation__c configureViolation(ApexViolation violationCache, Apex_Class__c apexClass) {
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
            apexViolation.Method__c = parseMethodName(violationCache.message);
            apexViolation.Starting_Complexity_Score__c = parseComplexityScore(violationCache.message);
        }
        return apexViolation;
    }

    private static void configureFailResponse(String title, String message) {
        response.success = false;
        response.title = title;
        response.message = message;
    }

    @TestVisible
    private static String parseFileName(String unformattedFileName) {
        Integer indexOfFinalDirectory = unformattedFileName.lastIndexOf('/');
        String trimmedFileName = unformattedFileName.substring(indexOfFinalDirectory + 1);
        return trimmedFileName.remove('.cls').remove('"');
    }

    @TestVisible
    private static String parseMethodName(String message) {
        Integer iFirstQuote = message.indexOf('\'') + 1; //increment 1 to move index past the single quote
        Integer iLastQuote = message.lastIndexOf('\'');
        String couldBeClassOrMethod = message.substring(iFirstQuote, iLastQuote);
        //for Cognitive Complexity score the method should be the class name without '()'
        String name = couldBeClassOrMethod.contains('(') ?
            couldBeClassOrMethod.substringBefore('(') + '()' : couldBeClassOrMethod;
        return name;
    }

    @TestVisible
    private static Integer parseComplexityScore(String message) {
        Integer score = 0;
        if (message.contains('cognitive')) {
            String mayRequireMoreParsing = message.substringBetween('cognitive complexity of ', ',');
            String finalString = mayRequireMoreParsing.contains('(') ?
                mayRequireMoreParsing.substringBefore(' (') : mayRequireMoreParsing;
            score = Integer.valueOf(finalString);
        }
        else {
            score = Integer.valueOf(message.substringBetween('cyclomatic complexity of ', '.'));
        }

        return score;
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
