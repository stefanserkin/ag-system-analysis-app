/* *
 * Asphalt Green
 * Created by Stefan Serkin on June 22, 2021
 * */ 

trigger SystemPaymentTrigger on System_Payment__c (before insert, before update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        SystemPaymentTriggerHandler.setSystemAndFiscalYear(Trigger.new);
    }

}