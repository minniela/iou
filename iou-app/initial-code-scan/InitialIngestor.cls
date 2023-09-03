public with sharing class InitialIngestor {

    @AuraEnabled
    public static void initiate(String staticResource) {
        if (String.isBlank(staticResource)) { staticResource = 'initialCodeScan.json'; }

        StaticResource pmdScan = [SELECT Body FROM StaticResource WHERE Name = :staticResource LIMIT 1];
        List<ApexClass> filesCache = (List<ApexClass>) JSON.deserialize(pmdScan.Body.toString(), List<ApexClass>.class);

        Map<String, Id> fileToPMDFileId = createPMDFiles(filesCache);
        createPMDViolations(filesCache, fileToPMDFileId);
    }

    public static void cleanResults() {
        List<Apex_Class__c> tphClasses = [SELECT Id FROM Apex_Class__c];
        delete tphClasses;
    }

//todo: change return type or adjust to allow setting starting violation
    private static Map<String, Id> createPMDFiles(List<ApexClass> filesCache) {
        List<Apex_Class__c> tphClasses = new List<Apex_Class__c>();
        for (ApexClass fileCache : filesCache) {
            String fileName = parseFileName(fileCache.fileName);
            Apex_Class__c pmdFile = new Apex_Class__c(
                Name = fileName
            );
            tphClasses.add(pmdFile);
        }
        //todo: defer the insert to allow setting the starting violation
        insert tphClasses;

        Map<String, Id> fileToIdMap = new Map<String, Id>();
        for (Apex_Class__c pmdFile : tphClasses) {
            fileToIdMap.put(pmdFile.Name, pmdFile.Id);
        }
        return fileToIdMap;
    }

    private static void createPMDViolations(List<ApexClass> filesCache, Map<String, Id> pmdFileMap) {
        List<Apex_Violation__c> violations = new List<Apex_Violation__c>();
        for (ApexClass fileCache : filesCache) {
            String fileNameKey = parseFileName(fileCache.fileName);
            Id pmdFileId = pmdFileMap.get(fileNameKey);

            for (ApexViolation violationCache: fileCache.violations) {
                Apex_Violation__c violation = new Apex_Violation__c(
                    Rule__c = violationCache.ruleName,
                    Category__c = violationCache.category,
                    Reference__c = violationCache.url,
                    Message__c = violationCache.message.trim(),
                    Apex_Class__c = pmdFileId
                );
                if (new List<String>{'CognitiveComplexity', 'CyclomaticComplexity'}.contains(violationCache.ruleName)) {
                    violation.Method__c = parseMethodName(violationCache.message);
                    violation.Complexity_Score__c = parseComplexityScore(violationCache.message);
                }
                violations.add(violation);

                //todo: add violation calculation to Apex Class
            }
        }

        //todo: insert apexClasses
        insert violations;
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
