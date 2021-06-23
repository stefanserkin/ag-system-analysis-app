/* *
 * Asphalt Green
 * Created by Stefan Serkin on June 18, 2021
 * */ 

trigger SystemExpenseTrigger on System_Expense__c (before insert, after insert, 
                                                    before update, after update,
                                                    after delete, after undelete) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        SystemExpenseTriggerHandler.calculateAmount(Trigger.new);
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            SystemExpenseTriggerHandler.recalcFiscalYear(Trigger.new, false);
            SystemExpenseTriggerHandler.createPayments(Trigger.new);
        } else if (Trigger.isUpdate || Trigger.isUndelete) {
            SystemExpenseTriggerHandler.recalcFiscalYear(Trigger.new, false);
        } else if (Trigger.isDelete) {
            // Second parameter isDelete
            SystemExpenseTriggerHandler.recalcFiscalYear(Trigger.old, true);
        }
        
    }

}