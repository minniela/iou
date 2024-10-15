public without sharing class TriggerAuditController {

    @AuraEnabled
    public static Boolean flagApexClass(String className) {
        List<Apex_Class__c> apexClasses = [SELECT Has_Trigger_Logic__c FROM Apex_Class__c WHERE Name = :className LIMIT 1];
        Apex_Class__c apexClass = apexClasses.isEmpty() ? null : apexClasses.get(0);
        if (apexClass == null) {
            apexClass = new Apex_Class__c(
                Name = className,
                Has_Trigger_Logic__c = true
            );
        }
        else {
            apexClass.Has_Trigger_Logic__c = true;
        }

        Database.UpsertResult result = Database.upsert(apexClass);
        return result.success;
    }
}
