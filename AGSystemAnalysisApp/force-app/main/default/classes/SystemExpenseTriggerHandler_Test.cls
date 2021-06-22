/* *
 * Asphalt Green
 * Created by Stefan Serkin on June 18, 2021
 * */ 

@isTest
public class SystemExpenseTriggerHandler_Test {

    @TestSetup
    static void setUpData() {
        // Baseline dates for fiscal year 0
        Date fyStartDate = Date.newInstance(2021, 7, 1);
        Date fyEndDate   = Date.newInstance(2022, 7, 1);
        
        System__c sys = new System__c(Name = 'Salesforce', Ecosystem__c = 'Salesforce Ecosystem', Description__c = 'CRM');
        insert sys;

        // Set up 5 fiscal years, starting in 2022
        List<Fiscal_Year__c> lstFysToInsert = new List<Fiscal_Year__c>();
        for (Integer i = 2; i < 7; i++) {

            Fiscal_Year__c fy = new Fiscal_Year__c();
            fy.Name          = 'FY2' + i;
            fy.Start_Date__c = fyStartDate.addYears(i - 2);
            fy.End_Date__c   = fyEndDate.addYears(i - 2);

            lstFysToInsert.add(fy);

        }
        insert lstFysToInsert;

        // One system expense for each fiscal year
        List<System_Expense__c> lstSesToInsert = new List<System_Expense__c>();
        for (Fiscal_Year__c fy : lstFysToInsert) {

            System_Expense__c se = new System_Expense__c();
            se.Annual_Cost__c      = 10000;
            se.Expense_Type__c     = 'Licensing/Service';
            se.Fiscal_Year__c      = fy.Id;
            se.Number_of_Months__c = 12;
            se.Percent_Increase__c = 0;
            se.System__c           = sys.Id;

            lstSesToInsert.add(se);
        }
        insert lstSesToInsert;
    }
    
    @isTest
    static void testCalculateAmount() {


    }
}