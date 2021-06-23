/* *
 * Asphalt Green
 * Created by Stefan Serkin on June 21, 2021
 * */ 
trigger LicenseOrderTrigger on License_Order__c (before insert, before update) {
	
    if (Trigger.isInsert || Trigger.isUpdate) {
        LicenseOrderTriggerHandler.testForTests();
    }
    
}