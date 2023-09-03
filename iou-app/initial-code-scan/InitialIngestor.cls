public with sharing class InitialIngestor {

    @AuraEnabled
    public static void initiate(String staticResource) {
        if (String.isBlank(staticResource)) { staticResource = 'initialCodeScan'; }

        StaticResource pmdScan = [SELECT Body FROM StaticResource WHERE Name = :staticResource LIMIT 1];
        List<ApexClass> apexClassCache = (List<ApexClass>) JSON.deserialize(pmdScan.Body.toString(), List<ApexClass>.class);

        Map<String, Id> apexNameByApexClassId = createApexClasses(apexClassCache);
        createApexViolations(apexClassCache, apexNameByApexClassId);
    }

    @AuraEnabled
    public static void startOver() {
        List<Apex_Class__c> apexClass = [SELECT Id FROM Apex_Class__c];
        delete apexClass;
    }

    //todo: change return type or adjust to allow setting starting violation
    private static Map<String, Id> createApexClasses(List<ApexClass> filesCache) {
        List<Apex_Class__c> apexClasses = new List<Apex_Class__c>();
        for (ApexClass fileCache : filesCache) {
            String fileName = parseFileName(fileCache.fileName);
            Apex_Class__c apexClass = new Apex_Class__c(
                Name = fileName
            );
            apexClasses.add(apexClass);
        }
        //todo: defer the insert to allow setting the starting violation
        insert apexClasses;

        Map<String, Id> classNamesById = new Map<String, Id>();
        for (Apex_Class__c apexClass : apexClasses) {
            classNamesById.put(apexClass.Name, apexClass.Id);
        }
        return classNamesById;
    }

    private static void createApexViolations(List<ApexClass> apexClassCache, Map<String, Id> apexClassNamesById) {
        List<Apex_Violation__c> apexViolations = new List<Apex_Violation__c>();
        for (ApexClass classCache : apexClassCache) {
            String fileNameKey = parseFileName(classCache.fileName);
            Id apexClassId = apexClassNamesById.get(fileNameKey);

            for (ApexViolation violationCache: classCache.violations) {
                Apex_Violation__c apexViolation = new Apex_Violation__c(
                    Rule__c = violationCache.ruleName,
                    Category__c = CategoryTranslatorService.translate(violationCache.category),
                    Reference__c = violationCache.url,
                    Message__c = violationCache.message.trim(),
                    Apex_Class__c = apexClassId
                );
                if (new List<String>{'CognitiveComplexity', 'CyclomaticComplexity'}.contains(violationCache.ruleName)) {
                    apexViolation.Method__c = parseMethodName(violationCache.message);
                    apexViolation.Complexity_Score__c = parseComplexityScore(violationCache.message);
                }
                apexViolations.add(apexViolation);

                //todo: add violation calculation to Apex Class
            }
        }

        //todo: insert apexClasses
        insert apexViolations;
    }

    @TestVisible
    private static String parseFileName(String unformattedFileName) {
        Integer indexOfFinalDirectory = unformattedFileName.lastIndexOf('/');
        String trimmedFileName = unformattedFileName.substring(indexOfFinalDirectory + 1);
        return trimmedFileName.remove('.cls"');
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
}
