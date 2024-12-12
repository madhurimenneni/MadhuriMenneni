/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-23-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class RlaDealScoring {
    List<ResidentialLoanApplication> newResedentialLoanApps;
    Map<Id, ResidentialLoanApplication> oldResedentialLoanApps;

    public RlaDealScoring(List<ResidentialLoanApplication> newRecords, Map<Id, ResidentialLoanApplication> oldRecordsMap) {
        newResedentialLoanApps = newRecords;
        oldResedentialLoanApps = oldRecordsMap;
    }

    public RlaDealScoring calculateDealScore() {
        List<ResidentialLoanApplication> qualifiedRlas = new List<ResidentialLoanApplication>();

        for (ResidentialLoanApplication newResedentialLoanApp : newResedentialLoanApps) {
            if (oldResedentialLoanApps != null) {
                ResidentialLoanApplication oldResedentialLoanApp = oldResedentialLoanApps.get(newResedentialLoanApp.Id);

                boolean statusChangeCriteriaMet = (oldResedentialLoanApp.Import_Complete__c != newResedentialLoanApp.Import_Complete__c &&
                                                   newResedentialLoanApp.Import_Complete__c) &&
                                                  (newResedentialLoanApp.Status == 'New' || newResedentialLoanApp.Status == 'Unprocessed');
                
                // Check if any of the relevant fields (LTV, Population, TDS, Credit Score, Loan Amount) have changed
                boolean fieldChangeCriteriaMet = oldResedentialLoanApp != null && (
                        oldResedentialLoanApp.LTV__c != newResedentialLoanApp.LTV__c ||
                        oldResedentialLoanApp.Considered_Location_Population__c != newResedentialLoanApp.Considered_Location_Population__c ||
                        oldResedentialLoanApp.TDS__c != newResedentialLoanApp.TDS__c ||
                        oldResedentialLoanApp.Considered_Credit_Score__c != newResedentialLoanApp.Considered_Credit_Score__c ||
                        oldResedentialLoanApp.Loan_Amount__c != newResedentialLoanApp.Loan_Amount__c);

                // Recalculate if either the status change criteria or the field change criteria is met
                if (statusChangeCriteriaMet || fieldChangeCriteriaMet) {
                    qualifiedRlas.add(newResedentialLoanApp);
                }
            }
        }

        // Recalculate deal score for qualified applications
        for (ResidentialLoanApplication qualifiedRla : qualifiedRlas) {
            Integer baseScore = calculateBaseScore(qualifiedRla);
            Integer populationPenalty = calculatePopulationPenalty(qualifiedRla);
            Integer tdsPenalty = calculateTDSPenalty(qualifiedRla);
            Integer loanAmountPenalty = calculateLoanAmountPenalty(qualifiedRla);

            // Calculate the final deal score
            qualifiedRla.ML_Deal_Score__c = baseScore + populationPenalty + tdsPenalty + loanAmountPenalty;

            // Generate the explanation for the deal score
            qualifiedRla.Deal_Score_Explanation__c =
                '<li>Base Score for ' + qualifiedRla.LTV__c + '% LTV and ' + Integer.valueOf(qualifiedRla.Considered_Credit_Score__c) + ' Credit Score = ' + baseScore + ' </li>' +
                '<li>' + qualifiedRla.Considered_Location_Population__c + ' Population = ' + populationPenalty + ' </li>' +
                '<li>' + qualifiedRla.TDS__c + '% TDS = ' + tdsPenalty + ' </li>' +
                '<li>' + '$' + qualifiedRla.Loan_Amount__c + ' Loan Amount = ' + loanAmountPenalty + ' </li>';
        }

        return this;
    }

    // Helper methods: calculateBaseScore, calculatePopulationPenalty, calculateTDSPenalty, calculateLoanAmountPenalty

    private Integer calculateBaseScore(ResidentialLoanApplication rla) {
        Integer baseScore = 0;
        if (rla.Considered_Credit_Score__c < 500) {
            if (rla.LTV__c >= 60) {
                baseScore = 40;
            } else if (rla.LTV__c >= 55 && rla.LTV__c < 60) {
                baseScore = 45;
            } else {
                baseScore = 50;
            }
        } else if (rla.Considered_Credit_Score__c >= 500 && rla.Considered_Credit_Score__c < 575) {
            if (rla.LTV__c >= 60) {
                baseScore = 50;
            } else if (rla.LTV__c >= 55 && rla.LTV__c < 60) {
                baseScore = 55;
            } else {
                baseScore = 60;
            }
        } else if (rla.Considered_Credit_Score__c >= 575 && rla.Considered_Credit_Score__c < 600) {
            if (rla.LTV__c >= 60) {
                baseScore = 60;
            } else if (rla.LTV__c >= 55 && rla.LTV__c < 60) {
                baseScore = 65;
            } else {
                baseScore = 70;
            }
        } else if (rla.Considered_Credit_Score__c >= 600 && rla.Considered_Credit_Score__c < 640) {
            if (rla.LTV__c >= 60) {
                baseScore = 70;
            } else if (rla.LTV__c >= 55 && rla.LTV__c < 60) {
                baseScore = 75;
            } else {
                baseScore = 80;
            }
        } else if (rla.Considered_Credit_Score__c >= 640 && rla.Considered_Credit_Score__c < 680) {
            if (rla.LTV__c >= 60) {
                baseScore = 80;
            } else if (rla.LTV__c >= 55 && rla.LTV__c < 60) {
                baseScore = 85;
            } else {
                baseScore = 90;
            }
        } else if (rla.Considered_Credit_Score__c >= 680) {
            if (rla.LTV__c >= 60) {
                baseScore = 90;
            } else if (rla.LTV__c >= 55 && rla.LTV__c < 60) {
                baseScore = 95;
            } else {
                baseScore = 100;
            }
        }
        return baseScore;
    }

    private Integer calculatePopulationPenalty(ResidentialLoanApplication rla) {
        Integer populationPenalty = 0;
        if (rla.Considered_Location_Population__c == null || rla.Considered_Location_Population__c == 0) {
            populationPenalty = -10;
        } else if (rla.Considered_Location_Population__c < 10000) {
            populationPenalty = -30;
        } else if (rla.Considered_Location_Population__c < 50000) {
            populationPenalty = -20;
        } else if (rla.Considered_Location_Population__c < 100000) {
            populationPenalty = -15;
        } else if (rla.Considered_Location_Population__c < 500000) {
            populationPenalty = -10;
        } else if (rla.Considered_Location_Population__c < 1000000) {
            populationPenalty = -5;
        } else {
            populationPenalty = 0;
        }
        return populationPenalty;
    }

    private Integer calculateTDSPenalty(ResidentialLoanApplication rla) {
        Integer tdsPenalty = 0;
        if (rla.TDS__c >= 80) {
            tdsPenalty = -20;
        } else if (rla.TDS__c >= 50) {
            tdsPenalty = -10;
        }
        return tdsPenalty;
    }

    private Integer calculateLoanAmountPenalty(ResidentialLoanApplication rla) {
        Integer loanAmountPenalty = 0;
        if (rla.Loan_Amount__c < 100000) {
            loanAmountPenalty = -20;
        } else if (rla.Loan_Amount__c >= 1000000) {
            loanAmountPenalty = -10;
        }
        return loanAmountPenalty;
    }
}