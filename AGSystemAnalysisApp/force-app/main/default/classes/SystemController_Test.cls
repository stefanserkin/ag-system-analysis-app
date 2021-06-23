@isTest
public class SystemController_Test {
    
    @isTest
    static void testDeleteExpensesForSystem() {
        // Baseline dates for fiscal year 0
        Date fyStartDate = Date.newInstance(2024, 7, 1);
        Date fyEndDate   = Date.newInstance(2025, 7, 1);
        
        System__c sys = new System__c(Name = 'Salesforce', Ecosystem__c = 'Salesforce Ecosystem', Description__c = 'CRM');
        insert sys;

        Fiscal_Year__c fy = new Fiscal_Year__c(Name = 'FY25', Start_Date__c = fyStartDate, End_Date__c = fyEndDate);
        insert fy;

        System_Expense__c se = new System_Expense__c();
        se.Annual_Cost__c      = 10000;
        se.Expense_Type__c     = 'Licensing/Service';
        se.Fiscal_Year__c      = fy.Id;
        se.Number_of_Months__c = 12;
        se.Percent_Increase__c = 0;
        se.System__c           = sys.Id;
        insert se;

        Test.startTest();
        SystemController.deleteExpensesForSystem(sys.Id);
        Test.stopTest();

        List<System__c> lstSystemsToVerify = [SELECT Id, (SELECT Id FROM System_Expenses__r) FROM System__c WHERE Id = :sys.Id LIMIT 1];
        List<System_Expense__c> lstSesToVerify = new List<System_Expense__c>();
        for (System__c sy : lstSystemsToVerify) {
            for (System_Expense__c sysExp : sy.System_Expenses__r) {
                lstSesToVerify.add(sysExp);
            }
        }

        System.assertEquals(0, lstSesToVerify.size(), 'Found incorrect number of system expenses');

    }

}