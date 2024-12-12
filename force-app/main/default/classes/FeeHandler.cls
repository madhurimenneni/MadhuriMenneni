public class FeeHandler {
    List<Fee__c> newFees = new List<Fee__c>();
    Map<Id, Fee__c> oldFees = new Map<Id, Fee__c>();
    
    public FeeHandler( List<Fee__c> newRecords, Map<Id, Fee__c> oldRecords ) {
        newFees = newRecords;
        oldFees = oldRecords;
    }
    
    public FeeHandler validateFeeRecords() {
        system.debug('yes');
        Set<Id> residentialLoanAppIdSet = new Set<Id>();
        Set<Id> feeIds = new Set<Id>();
        for(Fee__c newFee : newFees){
            residentialLoanAppIdSet.add(newFee.Residential_Loan_Application__c);
            if(newFee.id!=null){
               feeIds.add(newFee.id); 
            }
        }
        List<Fee__c> feeList = new List<Fee__c>();
        Map<Id,Set<String>> feeNameWithLoanAppIdMap = new Map<Id,Set<String>>();
        if(!residentialLoanAppIdSet.isEmpty()){
            feeList = [SELECT Id, Name, Fee_Type__c, Residential_Loan_Application__c FROM Fee__c WHERE Residential_Loan_Application__c IN: residentialLoanAppIdSet and ID NOT IN:feeIds];
            system.debug('feeList: '+feeList);
            for(Fee__c fee : feeList ){
                system.debug('Fee Type' + fee.Fee_Type__c);
                if(!feeNameWithLoanAppIdMap.containsKey(fee.Residential_Loan_Application__c)){
                    feeNameWithLoanAppIdMap.put(fee.Residential_Loan_Application__c, new Set<string>{fee.Fee_Type__c});
                }
                feeNameWithLoanAppIdMap.get(fee.Residential_Loan_Application__c).add(fee.Fee_Type__c);
            }
        }
        system.debug(feeNameWithLoanAppIdMap.KeySet().size() );
        if( feeNameWithLoanAppIdMap.KeySet().size() > 0 ){
            for(Fee__c fee : newFees){
                system.debug('Fee Type' + fee.Fee_Type__c);
                system.debug('Fee Type0==' + feeNameWithLoanAppIdMap.containsKey(fee.Residential_Loan_Application__c));
                //system.debug('Fee Type01 ==' + feeNameWithLoanAppIdMap.values().contains(fee.Fee_Type__c));
                if(feeNameWithLoanAppIdMap.containsKey(fee.Residential_Loan_Application__c)
                   && feeNameWithLoanAppIdMap.get(fee.Residential_Loan_Application__c).contains(fee.Fee_Type__c)){
                      // system.debug('Fee Type1 ==' + feeNameWithLoanAppIdMap.values().contains(fee.Fee_Type__c));
                       fee.addError('Fee already exist, please check the existing fee records.');
                   }
            }
        }
        return this;
    }
    public FeeHandler updateAmtORPercent() {
        set<Id> rlaIds=new set<Id>();
        for(Fee__c newFee : newFees){
            if(newfee.Residential_Loan_Application__c!=null){
                rlaIds.add(newfee.Residential_Loan_Application__c);
            }
        }
        Map<id,ResidentialLoanApplication> rlaMap=new Map<id,ResidentialLoanApplication>([select id,Loan_Amount__c from ResidentialLoanApplication where id IN:rlaIds]);
        
        for(Fee__c newFee : newFees){
            Fee__c oldFee=oldFees!=null?oldFees.get(newFee.id):null;
            
            if(newfee.Residential_Loan_Application__c!=null && (oldFee==null||(oldFee!=null && (oldFee.Amount__c!=newFee.Amount__c || oldFee.Fee_Percent__c!=newFee.Fee_Percent__c)))){
                decimal rlaAMT =rlaMap.get(newfee.Residential_Loan_Application__c).Loan_Amount__c;
                if(oldFee==null && rlaAMT!=null && rlaAMT!=0 ){
                    if( newFee.Fee_Percent__c!=null && newFee.Amount__c==null){
                        newFee.Amount__c=(rlaAMT * newFee.Fee_Percent__c)/100;      
                    }
                    if( newFee.Amount__c!=null && newFee.Fee_Percent__c==null){
                        newFee.Fee_Percent__c= (newFee.Amount__c / rlaAMT) *100  ;
                    }
                  
                }
                if(oldFee!=null ){
                    decimal amt=0;
                    decimal per=0;
                    if(oldFee.Fee_Percent__c!=newFee.Fee_Percent__c){
                        amt=(rlaAMT * newFee.Fee_Percent__c)/100; 
                    }else if(oldFee.Amount__c!=newFee.Amount__c){
                        per=(newFee.Amount__c / rlaAMT) *100  ; 
                    }
                    if(amt!=0){
                        newFee.Amount__c=amt;
                    }else if(per!=0){
                        newFee.Fee_Percent__c=per;
                    }
                    
                }
            }
        }
        return this;
    }
}