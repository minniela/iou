@IsTest
private class InitialIngestor_Test {
    @IsTest
    static void should_create_Apex_Classes_and_violations() {
        //GIVEN - default static resource provided

        Test.startTest();
        InitialIngestor.initiate('defaultCodeScan');
        Test.stopTest();

        List<Apex_Class__c> apexClasses = [SELECT Id FROM Apex_Class__c];
        Assert.areEqual(1, apexClasses.size());

        List<Apex_Violation__c> apexViolations = [SELECT Id FROM Apex_Violation__c];
        Assert.areEqual(11, apexViolations.size());
    }

    @IsTest
    static void should_delete_all_created_data() {
        InitialIngestor.initiate('defaultCodeScan');

        List<Apex_Class__c> apexClasses = [SELECT Id FROM Apex_Class__c];
        Assert.areEqual(1, apexClasses.size());

        List<Apex_Violation__c> apexViolations = [SELECT Id FROM Apex_Violation__c];
        Assert.areEqual(11, apexViolations.size());

        Test.startTest();
        InitialIngestor.startOver();
        Test.stopTest();

        apexClasses = [SELECT Id FROM Apex_Class__c];
        Assert.areEqual(0, apexClasses.size());

        apexViolations = [SELECT Id FROM Apex_Violation__c];
        Assert.areEqual(0, apexViolations.size());
    }
}
