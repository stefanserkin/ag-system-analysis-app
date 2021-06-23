/* *
 * Asphalt Green
 * Created by Stefan Serkin on June 22, 2021
 * */ 

public with sharing class SystemPaymentTriggerHandler {
    
    public static void setSystemAndFiscalYear(List<System_Payment__c> spsInTrigger) {

        // Add System Expenses ids to set
        Set<Id> setSeIds = new Set<Id>();
        for (System_Payment__c sp : spsInTrigger) {
            if (sp.System_Expense__c != null) {
                setSeIds.add(sp.System_Expense__c);
            }
        }

        // Query System Expense records for System and Fiscal Year ids
        Map<Id, System_Expense__c> mapSystemExpenses = new Map<Id, System_Expense__c>([SELECT Id,
                                                                                              Fiscal_Year__c,
                                                                                              System__c,
                                                                                              Amount__c
                                                                                         FROM System_Expense__c
                                                                                        WHERE Id IN :setSeIds]);

        for (System_Payment__c sp : spsInTrigger) {
            // Set System Payment values to related System Expense values in map
            sp.System__c      = mapSystemExpenses.get(sp.System_Expense__c).System__c;
            sp.Fiscal_Year__c = mapSystemExpenses.get(sp.System_Expense__c).Fiscal_Year__c;
        }

    }

}