@IsTest
private class RescanUpdater_Test {

    @IsTest
    static void testBehavior() {
    }

    @TestSetup
    static void testSetup() {
        Apex_Class__c class1 = new Apex_Class__c(Name = 'TestOne');
        Apex_Class__c class2 = new Apex_Class__c(Name = 'TestTwo');
        insert new List<Apex_Class__c>{class1, class2};

        List<Apex_Violation__c> violations = new List<Apex_Violation__c>();
        for (Integer i = 0; i < 10; i++) {
            violations.add(createBaseViolation(class1.Id, i));
        }

        for (Integer i = 0; i < 5; i++) {
            violations.add(createBaseViolation(class2.Id, i));
        }
        insert violations;
    }

    private static Apex_Violation__c createBaseViolation(Id apexClassId, Integer index) {
        Boolean flip = Math.mod(index, 2) == 0;
        return new Apex_Violation__c(
            Apex_Class__c = apexClassId,
            Rule__c = flip ? 'AvoidDeeplyNestedIfStmts' : 'CognitiveComplexity',
            Method__c = flip ? '' : 'testMethod' + index
        );
    }

    private static String getSamplePayload() {
        return '{' +
            '    "engine": "pmd-custom",' +
            '    "fileName": "/IdeaProjects/iou-app/force-app/main/default/classes/TestOne.cls",' +
            '    "violations": [' +
            '      {' +
            '        "line": "10",' +
            '        "column": "14",' +
            '        "endLine": "231",' +
            '        "endColumn": "1",' +
            '        "severity": 3,' +
            '        "ruleName": "CognitiveComplexity",' +
            '        "category": "Design",' +
            '        "url": "https://pmd.github.io/pmd-6.48.0/pmd_rules_apex_design.html#cognitivecomplexity",' +
            '        "message": "The method \'testMethod1(Database.BatchableContext, List<Lead>)\' has a cognitive complexity of 124, current threshold is 15"' +
            '      },' +
            '      {' +
            '        "line": "87",\n' +
            '        "column": "7",\n' +
            '        "endLine": "87",\n' +
            '        "endColumn": "8",\n' +
            '        "severity": 3,\n' +
            '        "ruleName": "AvoidDeeplyNestedIfStmts",\n' +
            '        "category": "Design",\n' +
            '        "url": "https://pmd.github.io/pmd-6.48.0/pmd_rules_apex_design.html#avoiddeeplynestedifstmts",\n' +
            '        "message": "\\nDeeply nested if..then statements are hard to read\\n"\n' +
            '      }' +
            '     ]' +
            '   }';
    }
}
