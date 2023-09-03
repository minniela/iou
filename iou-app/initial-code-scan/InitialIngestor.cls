public with sharing class InitialIngestor {

    @AuraEnabled
    public static void startOver() {
        List<Apex_Class__c> apexClass = [SELECT Id FROM Apex_Class__c];
        delete apexClass;
        Database.emptyRecycleBin(apexClass);
    }

    @AuraEnabled
    public static void initiate(String staticResource) {
        if (String.isBlank(staticResource)) { staticResource = 'initialCodeScan'; }

        StaticResource pmdScan = [SELECT Body FROM StaticResource WHERE Name = :staticResource LIMIT 1];
        List<ApexClass> apexClassCache = (List<ApexClass>) JSON.deserialize(pmdScan.Body.toString(), List<ApexClass>.class);

        Map<String, Apex_Class__c> apexClassesByName = createApexClasses(apexClassCache);
        Map<Id, List<Apex_Violation__c>> violationListByApexClassId = createApexViolations(apexClassCache, apexClassesByName);
        calculateViolationsInApexClass(violationListByApexClassId);
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
        insert apexClassesByName.values();
        return apexClassesByName;
    }

    private static Map<Id, List<Apex_Violation__c>> createApexViolations(
        List<ApexClass> apexClassCaches, Map<String, Apex_Class__c> apexClassesByName
    ) {
        List<Apex_Violation__c> apexViolations = new List<Apex_Violation__c>();
        Map<Id, List<Apex_Violation__c>> violationListByApexClassId = new Map<Id, List<Apex_Violation__c>>();
        for (ApexClass classCache : apexClassCaches) {
            String fileNameKey = parseFileName(classCache.fileName);
            Apex_Class__c apexClass = apexClassesByName.get(fileNameKey);

            for (ApexViolation violationCache: classCache.violations) {
                Apex_Violation__c apexViolation = configureViolation(violationCache, apexClass);
                apexViolations.add(apexViolation);

                if (!violationListByApexClassId.containsKey(apexClass.Id)) {
                    violationListByApexClassId.put(apexClass.Id, new List<Apex_Violation__c>());
                }
                violationListByApexClassId.get(apexClass.Id).add(apexViolation);
            }
        }
        insert apexViolations;
        return violationListByApexClassId;
    }

    private static Apex_Violation__c configureViolation(ApexViolation violationCache, Apex_Class__c apexClass) {
        Apex_Violation__c apexViolation = new Apex_Violation__c(
            Rule__c = violationCache.ruleName,
            Category__c = CategoryTranslatorService.translate(violationCache.category),
            Reference__c = violationCache.url,
            Message__c = violationCache.message.trim(),
            Starting_Line__c = Integer.valueOf(violationCache.line),
            End_Line__c = Integer.valueOf(violationCache.endLine),
            Apex_Class__c = apexClass.Id
        );
        if (new List<String>{'CognitiveComplexity', 'CyclomaticComplexity'}.contains(violationCache.ruleName)) {
            apexViolation.Method__c = parseMethodName(violationCache.message);
            apexViolation.Complexity_Score__c = parseComplexityScore(violationCache.message);
        }
        return apexViolation;
    }

    private static void calculateViolationsInApexClass(Map<Id, List<Apex_Violation__c>> violationListByApexClassId) {
        
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
