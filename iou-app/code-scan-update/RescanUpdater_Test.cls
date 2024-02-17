@IsTest
private class RescanUpdater_Test {

    @IsTest
    static void testBehavior() {
    }

    @TestSetup
    static void testSetup() {
        Apex_Class__c class1 = new Apex_Class__c(Name = 'Test One');
        Apex_Class__c class2 = new Apex_Class__c(Name = 'Test Two');
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
            Method__c = flip ? '' : 'method' + index
        );
    }
}
