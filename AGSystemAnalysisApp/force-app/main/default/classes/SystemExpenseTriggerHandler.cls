/* *
 * Asphalt Green
 * Created by Stefan Serkin on June 18, 2021
 * */ 

public with sharing class SystemExpenseTriggerHandler {
    
    public static void calculateAmount(List<System_Expense__c> sesInTrigger) {

        for (System_Expense__c se : sesInTrigger) {
            Double percentOfYear;

            if (se.Number_of_Months__c > 12) {
                se.addError('Please enter the number of months' +
                    ' within the Fiscal Year.' +
                    ' Can not be greater than 12.');
            }
            
            if (se.Number_of_Months__c != null) {
                percentOfYear = se.Number_of_Months__c / 12;
            } else {
                percentOfYear = 1;
            }

            if (se.Annual_Cost__c != null) {
                se.Amount__c = se.Annual_Cost__c * percentOfYear;
            } else {
                se.Amount__c = 0;
            }

        }
    }

    public static void recalcFiscalYear(List<System_Expense__c> sesInTrigger, Boolean isDelete) {

        List<Fiscal_Year__c> lstFysToUpdate = new List<Fiscal_Year__c>();

        // Add ids to set for query
        Set<Id> setFyIds = new Set<Id>();
        for (System_Expense__c se : sesInTrigger) {
            setFyIds.add(se.Fiscal_Year__c);
        }

        // Get all system expenses for fiscal year
        List<Fiscal_Year__c> lstFys = [SELECT Id,
                                              Total_Salesforce_Expenses__c,
                                              Total_Legacy_Expenses__c,
                                              Total_Legacy_Offset__c,
                                              (SELECT Id,
                                                      System__r.Ecosystem__c,
                                                      Amount__c,
                                                      Offset__c
                                                 FROM System_Costs__r
                                                WHERE IsDeleted = false)
                                         FROM Fiscal_Year__c
                                        WHERE Id IN :setFyIds
                                        LIMIT 1000];

        for (Fiscal_Year__c fy : lstFys) {
            Double totalSalesforceAmount = 0;
            Double totalLegacyAmount     = 0;
            Double totalOffsetAmount     = 0;

            for (System_Expense__c se : fy.System_Costs__r) {
                String ecosystem = se.System__r.Ecosystem__c;
                
                // Add em up
                if (ecosystem == 'Salesforce Ecosystem') {
                    totalSalesforceAmount += se.Amount__c;
                } else if (ecosystem == 'Legacy Systems') {
                    totalLegacyAmount += se.Amount__c;
                    if (se.Offset__c == true) {
                        totalOffsetAmount += se.Amount__c;
                    }
                }
            }

            fy.Total_Salesforce_Expenses__c = totalSalesforceAmount;
            fy.Total_Legacy_Expenses__c     = totalLegacyAmount;
            fy.Total_Legacy_Offset__c       = totalOffsetAmount;

            lstFysToUpdate.add(fy);

        }

        if (!lstFysToUpdate.isEmpty()) {
            update lstFysToUpdate;
        }

    }

    public static void createPayments(List<System_Expense__c> lstSesInTrigger) {

        List<System_Payment__c> lstSpsToInsert = new List<System_Payment__c>();

        // Query records in trigger for payment data from parent system
        List<System_Expense__c> lstSesWithSystem = [SELECT Id,
                                                           Amount__c,
                                                           System__c,
                                                           System__r.Create_System_Payments__c,
                                                           System__r.Payment_Frequency__c,
                                                           System__r.First_Payment_Date__c,
                                                           Fiscal_Year__c,
                                                           Fiscal_Year__r.Start_Date__c,
                                                           Fiscal_Year__r.End_Date__c
                                                      FROM System_Expense__c
                                                     WHERE Id IN :lstSesInTrigger
                                                     ORDER BY Fiscal_Year__r.Start_Date__c ASC
                                                     LIMIT 10000];

        for (System_Expense__c se : lstSesWithSystem) {
            Boolean createPayments     = se.System__r.Create_System_Payments__c;
            String strPaymentFrequency = se.System__r.Payment_Frequency__c;
            Date dateFirstPayment      = se.System__r.First_Payment_Date__c;
            Date fyStartDate           = se.Fiscal_Year__r.Start_Date__c;
            Date fyEndDate             = se.Fiscal_Year__r.End_Date__c;
            // Set value to identify if this is the first year of payments
            Boolean isFirstYear        = dateFirstPayment >= fyStartDate && dateFirstPayment <= fyEndDate;

            if (createPayments == false || strPaymentFrequency == null || dateFirstPayment == null) {
                continue;
            }

            // Create payment records based on frequency
            if (strPaymentFrequency == 'Annually') {
                // Create date relative to system expense in loop
                Integer yearOfPayment;
                if (dateFirstPayment.month() >= 7) {
                    yearOfPayment = fyStartDate.year();
                } else {
                    yearOfPayment = fyEndDate.year();
                }
                Date paymentDate = Date.newInstance(yearOfPayment, dateFirstPayment.month(), dateFirstPayment.day());

                // Set system payment
                System_Payment__c sp = new System_Payment__c();
                sp.System_Expense__c = se.Id;
                sp.Fiscal_Year__c    = se.Fiscal_Year__c;
                sp.System__c         = se.System__c;
                sp.Payment_Date__c   = paymentDate;
                sp.Payment_Amount__c = se.Amount__c;

                lstSpsToInsert.add(sp);

            } else if (strPaymentFrequency == 'Quarterly') {
                // generate payments every 3 months, starting with month of first payment
                // Create date relative to system expense in loop
                Integer yearOfPayment;
                Date paymentDate;
                Double paymentAmount = se.Amount__c / 4;

                if (dateFirstPayment.month() >= 7) {
                    yearOfPayment = fyStartDate.year();
                } else {
                    yearOfPayment = fyEndDate.year();
                }
                if (isFirstYear) {
                    paymentDate = Date.newInstance(yearOfPayment, dateFirstPayment.month(), dateFirstPayment.day());
                } else {
                    // If not the first year, start in July of the related fiscal year
                    paymentDate = Date.newInstance(fyStartDate.year(), 7, dateFirstPayment.day());
                }

                // Create a system payment for each month remaining in fiscal year
                do {
                    System_Payment__c sp = new System_Payment__c();
                    sp.System_Expense__c = se.Id;
                    sp.Fiscal_Year__c    = se.Fiscal_Year__c;
                    sp.System__c         = se.System__c;
                    sp.Payment_Date__c   = paymentDate;
                    sp.Payment_Amount__c = paymentAmount;

                    lstSpsToInsert.add(sp);

                    paymentDate = paymentDate.addMonths(3);

                } while (paymentDate <= fyEndDate);
                
            } else if (strPaymentFrequency == 'Monthly') {
                // Create date relative to system expense in loop
                Integer yearOfPayment;
                Date paymentDate;
                Double paymentAmount = se.Amount__c / 12;

                if (dateFirstPayment.month() >= 7) {
                    yearOfPayment = fyStartDate.year();
                } else {
                    yearOfPayment = fyEndDate.year();
                }
                if (isFirstYear) {
                    paymentDate = Date.newInstance(yearOfPayment, dateFirstPayment.month(), dateFirstPayment.day());
                } else {
                    // If not the first year, start in July of the related fiscal year
                    paymentDate = Date.newInstance(fyStartDate.year(), 7, dateFirstPayment.day());
                }

                // Create a system payment for each month remaining in fiscal year
                do {
                    System_Payment__c sp = new System_Payment__c();
                    sp.System_Expense__c = se.Id;
                    sp.Fiscal_Year__c    = se.Fiscal_Year__c;
                    sp.System__c         = se.System__c;
                    sp.Payment_Date__c   = paymentDate;
                    sp.Payment_Amount__c = paymentAmount;

                    lstSpsToInsert.add(sp);

                    paymentDate = paymentDate.addMonths(1);

                } while (paymentDate <= fyEndDate);
                
            }
            
        }

        if (!lstSpsToInsert.isEmpty()) {
            insert lstSpsToInsert;
        }

    }

}