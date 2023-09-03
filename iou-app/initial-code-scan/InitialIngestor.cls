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
        Map<Apex_Class__c, List<Apex_Violation__c>> violationListByApexClass = createApexViolations(apexClassCache, apexClassesByName);
        calculateViolationsInApexClass(violationListByApexClass);
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
        insert apexViolations;
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
            apexViolation.Complexity_Score__c = parseComplexityScore(violationCache.message);
        }
        return apexViolation;
    }

    private static void calculateViolationsInApexClass(Map<Apex_Class__c, List<Apex_Violation__c>> violationListByApexClassId) {
        List<Apex_Class__c> apexClassesToUpdate = new List<Apex_Class__c>();
        for (Apex_Class__c apexClass : violationListByApexClassId.keySet()) {
            Apex_Class__c apexClassCopy = configureClassViolations(apexClass);
            List<Apex_Violation__c> violations = violationListByApexClassId.get(apexClass);

            countViolationsForClass(apexClassCopy, violations);
            apexClassesToUpdate.add(apexClassCopy);
        }

        update apexClassesToUpdate;
    }

    private static Apex_Class__c configureClassViolations(Apex_Class__c apexClass) {
        return new Apex_Class__c(
            Id = apexClass.Id,
            Name = apexClass.Name,
            Cost_to_Understand_Maintain__c = 0,
            Cost_to_Change_Test__c = 0,
            Code_Smells__c = 0,
            Bad_Practices__c = 0,
            Ineffectual_Tests__c = 0
        );
    }

    private static void countViolationsForClass(Apex_Class__c apexClass, List<Apex_Violation__c> violations) {
        for (Apex_Violation__c violation : violations) {
            switch on violation.Category__c {
                when 'Cost to Understand & Maintain' {
                    apexClass.Cost_to_Understand_Maintain__c += violation.Complexity_Score__c;
                    if (apexClass.Name == violation.Method__c) {
                        apexClass.File_Length__c = violation.Ending_Line__c - violation.Starting_Line__c;
                    }
                }
                when 'Cost to Change & Test' {
                    apexClass.Cost_to_Change_Test__c += violation.Complexity_Score__c;
                }
                when 'Code Smell' {
                    apexClass.Code_Smells__c += 1;
                }
                when 'Bad Practice' {
                    apexClass.Bad_Practices__c += 1;
                }
                when 'Ineffectual Tests' {
                    apexClass.Ineffectual_Tests__c += 1;
                }
            }
        }
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
}
