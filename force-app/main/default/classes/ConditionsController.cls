public with sharing class ConditionsController {
    @AuraEnabled
    public static String getConditions(String MyString) {
        string res ='';
        List<ResidentialLoanApplication> loanApplst = [SELECT ID,Selected_Conditions__c FROM ResidentialLoanApplication WHERE ID=:MyString];
        if(loanApplst.size()>0){
          res=loanApplst[0].Selected_Conditions__c;
        }
        system.debug('res'+res);
        return res;
        

    }
}