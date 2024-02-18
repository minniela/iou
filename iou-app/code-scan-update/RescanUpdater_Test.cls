@IsTest
private class RescanUpdater_Test {

    @IsTest
    static void testBehavior() {

        Test.startTest();
        RescanUpdater.startUpdate(getSamplePayload());
        Test.stopTest();

        Apex_Class__c updatedClass = [
            SELECT Id, (SELECT Current_Complexity_Score__c, Method__c, Is_Resolved__c FROM Apex_Violations__r)
            FROM Apex_Class__c
            WHERE Name = 'TestOne'
            LIMIT 1
        ];

        Integer countOfResolved = 0;
        for (Apex_Violation__c apexViolation : updatedClass.Apex_Violations__r) {
            if (apexViolation.Method__c == 'testMethod1()') {
                Assert.areEqual(124, apexViolation.Current_Complexity_Score__c,
                    'The payload indicates the complexity score should be 124.');
            }
            countOfResolved += apexViolation.Is_Resolved__c ? 1 : 0;
        }
        Assert.areEqual(8, countOfResolved, 'As the payload only has 2 violations, the other 8 should be resolved.');
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
            Method__c = flip ? '' : 'testMethod' + index + '()'
        );
    }

    private static String getSamplePayload() {
        return '[{' +
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
            '        "line": "87",' +
            '        "column": "7",' +
            '        "endLine": "87",' +
            '        "endColumn": "8",' +
            '        "severity": 3,' +
            '        "ruleName": "AvoidDeeplyNestedIfStmts",' +
            '        "category": "Design",' +
            '        "url": "https://pmd.github.io/pmd-6.48.0/pmd_rules_apex_design.html#avoiddeeplynestedifstmts",' +
            '        "message": "Deeply nested if..then statements are hard to read"' +
            '      }' +
            '     ]' +
            '   }]';
    }
}
