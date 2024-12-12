/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-05-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class DownpaymentController {
    public class downpaymentWrapper {
        public List<Downpayment__c> downpayment;
        public Boolean hasData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Downpayment__c> getRlaDownpayments( String loanApplicationId ) {
        List<Downpayment__c> downpayments = [SELECT Id,Name,Loan_Application_Property__c, Amount__c, Source__c, Date__c
                                         FROM Downpayment__c
                                         WHERE Residential_Loan_Application__c =: loanApplicationId];
        return downpayments;
    }

    @AuraEnabled(cacheable=true)
    public static List<Downpayment__c> getDownpayments( String loanApplicationPropertyId ) {
        List<Downpayment__c> downpayments = [SELECT Id,Name, Loan_Application_Property__c, Amount__c, Source__c, Date__c
                                         FROM Downpayment__c
                                         WHERE Loan_Application_Property__c =: loanApplicationPropertyId];
        return downpayments;
    }

    @AuraEnabled
    public static String getDownpayment( String loanApplicationPropertyId ) {
        return JSON.serialize(DownpaymentController.getDownpaymentWrapper(loanApplicationPropertyId));
    } 
    
    public static DownpaymentController.DownpaymentWrapper getDownpaymentWrapper( String loanApplicationPropertyId ) {
        system.debug('loanApplicationPropertyId: '+loanApplicationPropertyId);
        DownpaymentController.downpaymentWrapper result = new DownpaymentController.downpaymentWrapper();
        List<Downpayment__c> downpayments = [SELECT Id, Loan_Application_Property__c, Amount__c, Source__c, Date__c FROM Downpayment__c
                                             WHERE Loan_Application_Property__c =: loanApplicationPropertyId ];
        system.debug('downpayments: '+downpayments.size());
        if( downpayments.size() > 0 ){
            result.hasData = true;
            result.downpayment = downpayments;
        }
        return result;
    }
      @AuraEnabled
    public static  Map<String,String> saveDownPayment(Map<String, Object> payInfo) {
        Map<String,String> resultMap = new Map<String,String>();
        try {
            Downpayment__c payment =new Downpayment__c(id=(id)payInfo.get('Id'));
            string  valAmt=string.valueOf(payInfo.get('Amount__c'));
            system.debug('valAmt+:'+valAmt);
            if(valAmt!=null){
                payment.Amount__c=decimal.valueof(valAmt);
            }else{
                payment.Amount__c=null;
            }
            
            payment.Source__c=(string)payInfo.get('Source__c');
            string valdate=(string)payInfo.get('Date__c');
            if(valdate!='' && valdate!=null){
                payment.Date__c=Date.valueOf(valdate);
            }else{
                payment.Date__c=null;
            }
            
            system.debug('payment:'+payment);
            update payment;
            resultMap.put('status', 'success');
            resultMap.put('message', 'Downpayment is updated Successfully');
        }
        catch(Exception e) {
            resultMap.put('status', 'error');
            resultMap.put('message',e.getMessage());
        }
        return resultMap; 
    }
    
    @AuraEnabled
    public static Map<String,String> deleteDownpaymentList(List<Id> downpaymentIds) {
        List<Downpayment__c> downpaymentsToDelete = [ SELECT Id,Loan_Application_Property__c FROM Downpayment__c WHERE Id IN: downpaymentIds ];
        Map<String,String> resultMap = new Map<String,String>();
        try {
            update new LoanApplicationProperty( Id = downpaymentsToDelete[0].Loan_Application_Property__c );
            delete downpaymentsToDelete;
            resultMap.put('status', 'success');
            resultMap.put('message', 'Downpayment is Deleted Successfully');        
        }
        catch(Exception e) {
            resultMap.put('status', 'error');
            resultMap.put('message',e.getMessage());
        }
        return resultMap;                
    }
    
    @AuraEnabled
    public static Map<String,String> calculatePropetyValueAction( String selectedVal ) {
        Map<String,String> resultMap = new Map<String,String>();
        system.debug('selectedVal: '+selectedVal);
        Downpayment__c downpaymentsToDelete = [SELECT Id, Amount__c, Loan_Application_Property__c, Source__c, Date__c
                                               FROM Downpayment__c 
                                               WHERE Id =: selectedVal ];
        Update new Downpayment__c( Id = downpaymentsToDelete.Id );
        
        List<Downpayment__c> downpaymentList = [SELECT Id, Source__c, Date__c, Amount__c, Loan_Application_Property__c FROM Downpayment__c
                                                WHERE Loan_Application_Property__c =: downpaymentsToDelete.Loan_Application_Property__c
                                                ORDER BY Date__c 
                                                DESC LIMIT 1 ];
        system.debug('downpaymentList: '+downpaymentList);
        List< LoanApplicationProperty> updatedPropList = new List<LoanApplicationProperty>();  
        if ( downpaymentList.size() > 0 ) {
            for ( Downpayment__c dow : downpaymentList ) {
                LoanApplicationProperty prop = new LoanApplicationProperty();
                prop.Id = dow.Loan_Application_Property__c;
                updatedPropList.add( prop );
            }
        } 
        return resultMap;
    }
    
    @AuraEnabled
    public static void updateDefaultAction( String selectedVal, Boolean isChecked, String propertyRecordId ) {
        system.debug('updateDefaultAction');
        List<Downpayment__c> updateDownpaymentList = new List<downpayment__c>();
        List<Downpayment__c> downpaymentsToDelete = [SELECT Id, Amount__c, Loan_Application_Property__c, Source__c, Date__c
                                                     FROM Downpayment__c 
                                                     WHERE Loan_Application_Property__c =: propertyRecordId];
        for( Downpayment__c downpaymentDelete : downpaymentsToDelete ) {
            if( downpaymentDelete.Id == selectedVal ) {
                updateDownpaymentList.add(downpaymentDelete);
            } else {
                updateDownpaymentList.add(downpaymentDelete);
            }
        }
        if( updateDownpaymentList.size() > 0 ) {
            update updateDownpaymentList;
        }
    }
    
    @AuraEnabled
    public static void updateDefaultActionOnDeletion( String selectedVal, Boolean isChecked, String propertyRecordId ) {
        system.debug('updateDefaultAction');
        List<Downpayment__c> updateDownpaymentList = new List<Downpayment__c>();
        List<Downpayment__c> downpaymentsToDelete = [SELECT Id, Amount__c, Loan_Application_Property__c, Source__c, Date__c
                                                     FROM Downpayment__c 
                                                     WHERE Loan_Application_Property__c =: propertyRecordId ];
        for( Downpayment__c downpaymentDelete : downpaymentsToDelete ) {
            if( downpaymentDelete.Id == selectedVal ) {
                updateDownpaymentList.add(downpaymentDelete);
            } 
        }
        if( updateDownpaymentList.size() > 0 ) {
            update updateDownpaymentList;
        }
    }
}