@IsTest
private class InitializationCounterService_Test {
    @IsTest
    static void should_return_Response_with_values() {
        Apex_Class__c apexClass1 = new Apex_Class__c();
        apexClass1.Starting_Violation_Count__c = 100;
        apexClass1.Has_Trigger_Logic__c = true;
        Apex_Class__c apexClass2 = new Apex_Class__c();
        apexClass2.Starting_Violation_Count__c = 99;
        insert new List<Apex_Class__c>{apexClass1, apexClass2};

        Test.startTest();
        InitializationCounterService.Response response = InitializationCounterService.getViolationCountDetails();
        Test.stopTest();

        Assert.areEqual(2, response.classCount);
        Assert.areEqual(199, response.violationCount);
        Assert.isTrue(response.triggerAuditHasStarted, 'triggerAuditHasStarted should be true');
    }

    @IsTest
    static void should_return_empty_Response() {
        //GIVEN - no Apex Classes have been created.

        Test.startTest();
        InitializationCounterService.Response response = InitializationCounterService.getViolationCountDetails();
        Test.stopTest();

        Assert.areEqual(0, response.classCount);
        Assert.areEqual(0, response.violationCount);
        Assert.isFalse(response.triggerAuditHasStarted, 'triggerAuditHasStarted should be false');
    }
}
