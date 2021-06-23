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
		// Baseline dates for fiscal year 0
        Date fyStartDate = Date.newInstance(2024, 7, 1);
        Date fyEndDate   = Date.newInstance(2025, 7, 1);
        
        System__c sys = new System__c(Name = 'Salesforce', Ecosystem__c = 'Salesforce Ecosystem', Description__c = 'CRM');
        insert sys;
        
        System__c sys2 = new System__c(Name = 'Active', Ecosystem__c = 'Legacy Systems', Description__c = 'CRM');
        insert sys2;

        Fiscal_Year__c fy = new Fiscal_Year__c(Name = 'FY25', Start_Date__c = fyStartDate, End_Date__c = fyEndDate);
        insert fy;
		// 12 months - annual cost included
        System_Expense__c se = new System_Expense__c();
        se.Annual_Cost__c      = 10000;
        se.Expense_Type__c     = 'Licensing/Service';
        se.Fiscal_Year__c      = fy.Id;
        se.Number_of_Months__c = 12;
        se.Percent_Increase__c = 0;
        se.System__c           = sys2.Id;
        se.Offset__c           = true;
        insert se;
        // null months - null annual cost
        System_Expense__c se2 = new System_Expense__c();
        se2.Expense_Type__c     = 'Licensing/Service';
        se2.Fiscal_Year__c      = fy.Id;
        se2.Number_of_Months__c = null;
        se2.Percent_Increase__c = 0;
        se2.System__c           = sys2.Id;
        insert se2;
        // 10 months
        System_Expense__c se3 = new System_Expense__c();
        se3.Annual_Cost__c      = 10000;
        se3.Expense_Type__c     = 'Licensing/Service';
        se3.Fiscal_Year__c      = fy.Id;
        se3.Number_of_Months__c = 10;
        se3.Percent_Increase__c = 0;
        se3.System__c           = sys2.Id;
        insert se3;

    }
    
    @isTest
    static void testCalculateAmountValidation() {
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
        se.Number_of_Months__c = 13;
        se.Percent_Increase__c = 0;
        se.System__c           = sys.Id;

        try {
            insert se;
        } catch(Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Can not be greater than 12') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
       
    }
    
    @isTest
    static void testCreateAnnualPayments() {
        // Baseline dates for fiscal year 0
        Date fyStartDate = Date.newInstance(2024, 7, 1);
        Date fyEndDate   = Date.newInstance(2025, 7, 1);
        
        System__c sys = new System__c(Name = 'Salesforce', Ecosystem__c = 'Salesforce Ecosystem', Description__c = 'CRM', Create_System_Payments__c = true, Payment_Frequency__c = 'Annually', First_Payment_Date__c = fyStartDate);
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
    
    @isTest
    static void testCreateAnnualPayments2() {
        // Baseline dates for fiscal year 0
        Date fyStartDate = Date.newInstance(2024, 7, 1);
        Date fyEndDate   = Date.newInstance(2025, 6, 30);
        
        System__c sys = new System__c(Name = 'Salesforce', Ecosystem__c = 'Salesforce Ecosystem', Description__c = 'CRM', Create_System_Payments__c = true, Payment_Frequency__c = 'Annually', First_Payment_Date__c = fyEndDate);
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
    
    @isTest
    static void testCreateMonthlyPayments() {
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
    
    @isTest
    static void testCreateMonthlyPayments2() {
        // Baseline dates for fiscal year 0
        Date fyStartDate = Date.newInstance(2024, 7, 1);
        Date fyEndDate   = Date.newInstance(2025, 6, 30);
        
        System__c sys = new System__c(Name = 'Salesforce', Ecosystem__c = 'Salesforce Ecosystem', Description__c = 'CRM', Create_System_Payments__c = true, Payment_Frequency__c = 'Monthly', First_Payment_Date__c = fyEndDate);
        insert sys;

        Fiscal_Year__c fy = new Fiscal_Year__c(Name = 'FY25', Start_Date__c = fyStartDate, End_Date__c = fyEndDate);
        insert fy;
        
        Fiscal_Year__c fy2 = new Fiscal_Year__c(Name = 'FY26', Start_Date__c = fyStartDate.addYears(1), End_Date__c = fyEndDate.addYears(1));
        insert fy2;

        List<System_Expense__c> lstSesToInsert = new List<System_Expense__c>();
        System_Expense__c se = new System_Expense__c();
        se.Annual_Cost__c      = 10000;
        se.Expense_Type__c     = 'Licensing/Service';
        se.Fiscal_Year__c      = fy.Id;
        se.Number_of_Months__c = 12;
        se.Percent_Increase__c = 0;
        se.System__c           = sys.Id;
		lstSesToInsert.add(se);
        
        System_Expense__c se2 = new System_Expense__c();
        se2.Annual_Cost__c      = 10000;
        se2.Expense_Type__c     = 'Licensing/Service';
        se2.Fiscal_Year__c      = fy2.Id;
        se2.Number_of_Months__c = 12;
        se2.Percent_Increase__c = 0;
        se2.System__c           = sys.Id;
		lstSesToInsert.add(se2);
        
        insert lstSesToInsert;
    }
    
    @isTest
    static void testCreateQuarterlyPayments() {
        // Baseline dates for fiscal year 0
        Date fyStartDate = Date.newInstance(2024, 7, 1);
        Date fyEndDate   = Date.newInstance(2025, 6, 30);
        
        System__c sys = new System__c(Name = 'Salesforce', Ecosystem__c = 'Salesforce Ecosystem', Description__c = 'CRM', Create_System_Payments__c = true, Payment_Frequency__c = 'Quarterly', First_Payment_Date__c = fyStartDate);
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
    
    @isTest
    static void testCreateQuarterlyPayments2() {
        // Baseline dates for fiscal year 0
        Date fyStartDate = Date.newInstance(2024, 7, 1);
        Date fyEndDate   = Date.newInstance(2025, 6, 30);
        
        System__c sys = new System__c(Name = 'Salesforce', Ecosystem__c = 'Salesforce Ecosystem', Description__c = 'CRM', Create_System_Payments__c = true, Payment_Frequency__c = 'Quarterly', First_Payment_Date__c = fyEndDate);
        insert sys;

        Fiscal_Year__c fy = new Fiscal_Year__c(Name = 'FY25', Start_Date__c = fyStartDate, End_Date__c = fyEndDate);
        insert fy;
        
        Fiscal_Year__c fy2 = new Fiscal_Year__c(Name = 'FY26', Start_Date__c = fyStartDate.addYears(1), End_Date__c = fyEndDate.addYears(1));
        insert fy2;
		
        List<System_Expense__c> lstSesToInsert = new List<System_Expense__c>();
        System_Expense__c se = new System_Expense__c();
        se.Annual_Cost__c      = 10000;
        se.Expense_Type__c     = 'Licensing/Service';
        se.Fiscal_Year__c      = fy.Id;
        se.Number_of_Months__c = 12;
        se.Percent_Increase__c = 0;
        se.System__c           = sys.Id;
		lstSesToInsert.add(se);
        
        System_Expense__c se2 = new System_Expense__c();
        se2.Annual_Cost__c      = 10000;
        se2.Expense_Type__c     = 'Licensing/Service';
        se2.Fiscal_Year__c      = fy2.Id;
        se2.Number_of_Months__c = 12;
        se2.Percent_Increase__c = 0;
        se2.System__c           = sys.Id;
		lstSesToInsert.add(se2);
        
        insert lstSesToInsert;
    }
    
    @isTest
    static void testUpdateAndDelete() {
        // Baseline dates for fiscal year 0
        Date fyStartDate = Date.newInstance(2024, 7, 1);
        Date fyEndDate   = Date.newInstance(2025, 6, 30);
        
        System__c sys = new System__c(Name = 'Salesforce', Ecosystem__c = 'Salesforce Ecosystem', Description__c = 'CRM', Create_System_Payments__c = true, Payment_Frequency__c = 'Quarterly', First_Payment_Date__c = fyStartDate);
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
        
        se.Annual_Cost__c      = 12000;
        update se;
        
        delete se;
    }

}