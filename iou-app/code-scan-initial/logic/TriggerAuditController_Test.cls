@IsTest
private class TriggerAuditController_Test {
    @IsTest
    static void should_create_a_new_Apex_Class_flagged_as_a_trigger_impact() {
        String className = 'RandomClass';
        Test.startTest();
        TriggerAuditController.flagApexClass(className);
        Test.stopTest();

        List<Apex_Class__c> apexClasses = [SELECT Name, Has_Trigger_Logic__c FROM Apex_Class__c];
        Assert.areEqual(1, apexClasses.size());
        Assert.areEqual(className, apexClasses[0].Name);
        Assert.isTrue(apexClasses[0].Has_Trigger_Logic__c, 'Apex Class should be flagged as having a trigger impact.');
    }

    @IsTest
    static void should_flag_an_existing_Apex_Class_as_a_trigger_impact() {
        String className = 'ExistingClass';
        Apex_Class__c apexClass = new Apex_Class__c(Name = className);
        insert apexClass;

        Test.startTest();
        TriggerAuditController.flagApexClass(className);
        Test.stopTest();

        List<Apex_Class__c> apexClasses = [SELECT Name, Has_Trigger_Logic__c FROM Apex_Class__c];
        Assert.areEqual(1, apexClasses.size());
        Assert.areEqual(className, apexClasses[0].Name);
        Assert.isTrue(apexClasses[0].Has_Trigger_Logic__c, 'Apex Class should be flagged as having a trigger impact.');
    }
}
