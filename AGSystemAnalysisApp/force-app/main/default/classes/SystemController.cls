public with sharing class SystemController {
    
    @AuraEnabled
    public static void deleteExpensesForSystem(String recordId) {
        
        List<System_Expense__c> lstSystemExpensesToDelete = [SELECT Id 
                                                               FROM System_Expense__c
                                                              WHERE System__c = :recordId
                                                              LIMIT 10000];
        if (!lstSystemExpensesToDelete.isEmpty()) {
            try {
                delete lstSystemExpensesToDelete;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

    }

}