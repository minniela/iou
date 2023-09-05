@IsTest
private class InitialIngestor_Test {
    @IsTest
    static void should_create_Apex_Classes_and_violations() {
        //GIVEN - default static resource provided

        Test.startTest();
        InitialIngestor.initiate('defaultCodeScan');
        Test.stopTest();

        List<Apex_Class__c> apexClasses = [
            SELECT File_Length__c, Cost_to_Understand_Maintain__c, Cost_to_Change_Test__c, Code_Smells__c,
                Bad_Practices__c, Ineffectual_Tests__c, Starting_Violation_Count__c
            FROM Apex_Class__c
        ];
        Assert.areEqual(1, apexClasses.size());

        Apex_Class__c apexClass = apexClasses.get(0);
        Assert.areEqual(221, apexClass.File_Length__c);
        Assert.areEqual(248, apexClass.Cost_to_Understand_Maintain__c);
        Assert.areEqual(40, apexClass.Cost_to_Change_Test__c);
        Assert.areEqual(8, apexClass.Code_Smells__c);
        Assert.areEqual(1, apexClass.Bad_Practices__c);
        Assert.areEqual(1, apexClass.Ineffectual_Tests__c);
        Assert.areEqual(298, apexClass.Starting_Violation_Count__c);

        List<Apex_Violation__c> apexViolations = [SELECT Id FROM Apex_Violation__c];
        Assert.areEqual(13, apexViolations.size());
    }

    @IsTest
    static void should_delete_all_created_data() {
        InitialIngestor.initiate('defaultCodeScan');

        List<Apex_Class__c> apexClasses = [SELECT Id FROM Apex_Class__c];
        Assert.areEqual(1, apexClasses.size());

        List<Apex_Violation__c> apexViolations = [SELECT Id FROM Apex_Violation__c];
        Assert.areEqual(13, apexViolations.size());

        Test.startTest();
        InitialIngestor.startOver();
        Test.stopTest();

        apexClasses = [SELECT Id FROM Apex_Class__c];
        Assert.areEqual(0, apexClasses.size());

        apexViolations = [SELECT Id FROM Apex_Violation__c];
        Assert.areEqual(0, apexViolations.size());
    }
}
