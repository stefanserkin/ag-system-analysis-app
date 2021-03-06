@isTest
public class SystemPaymentTriggerHandler_Test {
    
    @isTest
    static void testSystemPayments() {
        // Baseline dates for fiscal year 0
        Date fyStartDate = Date.newInstance(2024, 7, 1);
        Date fyEndDate   = Date.newInstance(2025, 6, 30);
        
        System__c sys = new System__c(Name = 'Salesforce', Ecosystem__c = 'Salesforce Ecosystem', Description__c = 'CRM', Create_System_Payments__c = true, Payment_Frequency__c = 'Monthly', First_Payment_Date__c = fyStartDate);
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
    }
    
}