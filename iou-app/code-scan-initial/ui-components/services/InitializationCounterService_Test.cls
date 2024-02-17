@IsTest
private class InitializationCounterService_Test {
    @IsTest
    static void should_return_Response_with_values() {
        Apex_Class__c triggerClass = new Apex_Class__c();
        triggerClass.Has_Trigger_Logic__c = true;
        Apex_Class__c regularClass = new Apex_Class__c();
        insert new List<Apex_Class__c>{triggerClass, regularClass};

        Apex_Violation__c triggerViolation = new Apex_Violation__c(
            Apex_Class__c = triggerClass.Id,
            Starting_Complexity_Score__c = 100,
            Category__c = 'Cost to Change & Test'
        );
        Apex_Violation__c regularViolation = new Apex_Violation__c(
            Apex_Class__c = regularClass.Id,
            Starting_Complexity_Score__c = 99,
            Category__c = 'Cost to Change & Test'
        );
        insert new List<Apex_Violation__c>{triggerViolation, regularViolation};

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
