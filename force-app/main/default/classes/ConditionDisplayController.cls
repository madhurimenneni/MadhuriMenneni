public with sharing class ConditionDisplayController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPicklistValues() {
        List<Schema.PicklistEntry> entries = Account.Rating.getDescribe().getPicklistValues();
        List<Map<String, String>> values = new List<Map<String, String>>();
        for (Schema.PicklistEntry entry : entries) {
            Map<String, String> valueMap = new Map<String, String>();
            valueMap.put('label', entry.getLabel());
            valueMap.put('value', entry.getValue());
            values.add(valueMap);
        }
        return values;
    }
    @AuraEnabled
    public static Map<Id,MainConditionsWrapper> getParentCondition( String recId ){
        Map<Id,MainConditionsWrapper> mapParentChildConditionsMDt = new Map<Id,MainConditionsWrapper>();
        List<Main_Conditions__mdt> parentConditionsmdtList = [SELECT Id, MasterLabel FROM Main_Conditions__mdt];
        String applicationId = '';
        if ( recId.startsWith('0cP') ) {
            List<LoanApplicationProperty> appProperties = [SELECT Id, LoanApplicationId FROM LoanApplicationProperty WHERE Id =: recId];
            if ( appProperties.size() > 0 ) {
                applicationId = appProperties[0].LoanApplicationId;
            }
        } else {
            applicationId = recId;
        }
        List<RLA_Standard_Condition__c> rsaStandardConditions = [SELECT Id, Name FROM RLA_Standard_Condition__c WHERE Residential_Loan_Application__c =: applicationId];
        Map<String, Boolean> selectedRsatandardConditionsMap = new Map<String, Boolean>();
        for ( RLA_Standard_Condition__c rsaStandardCondition : rsaStandardConditions ) {
            selectedRsatandardConditionsMap.put(rsaStandardCondition.Name, True);
        }
        
        for(RLA_Standard_Condition__c rlasc: rsaStandardConditions){
            MainConditionsWrapper result = new MainConditionsWrapper();
            result.id = rlasc.Id;
            result.masterLabel = rlasc.name;
            mapParentChildConditionsMDt.put(rlasc.id,result);
        }
        return mapParentChildConditionsMDt;
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id,String> getChildCondition(String recId){
        Map<Id,String> mapChildConditionsMDt =  new Map<Id,String>();
            List<RLA_Sub_Condition__c> childConditionsmdtList = [SELECT id,name,Condition__c, RLA_Standard_Condition__c, RLA_Standard_Condition__r.Name FROM RLA_Sub_Condition__c WHERE RLA_Standard_Condition__c =: recId];
        System.debug('con'+childConditionsmdtList);
        for(RLA_Sub_Condition__c mdtObj: childConditionsmdtList){
            mapChildConditionsMDt.put(mdtObj.id,mdtObj.Condition__c);
        }
        system.debug(mapChildConditionsMDt);
        return mapChildConditionsMDt;
    }
    @AuraEnabled(cacheable=true)
    public static List<RLA_Sub_Condition__c> getChildConditionsList(String recId){
        Map<Id,String> mapChildConditionsMDt =  new Map<Id,String>();
            List<RLA_Sub_Condition__c> childConditionsmdtList = [SELECT id, Name, Received__c, Condition__c, Condition_Assignee__c, RLA_Standard_Condition__c, RLA_Standard_Condition_Name__c FROM RLA_Sub_Condition__c WHERE RLA_Standard_Condition__c =: recId];
        System.debug('con'+childConditionsmdtList);
        for(RLA_Sub_Condition__c mdtObj: childConditionsmdtList){
            mapChildConditionsMDt.put(mdtObj.id,mdtObj.Condition__c);
        }
        system.debug(mapChildConditionsMDt);
        return childConditionsmdtList;
    }
    @AuraEnabled(cacheable=true)
    public static List<RLA_Sub_Condition__c> getAllChildConditions(String recId){
        List<Main_Conditions__mdt> parentConditionsmdtList = [SELECT Id, MasterLabel FROM Main_Conditions__mdt];
        String applicationId = '';
        if (recId.startsWith('0cP')){
            List<LoanApplicationProperty> appProperties = [SELECT Id, LoanApplicationId FROM LoanApplicationProperty WHERE Id =: recId];
            if (appProperties.size() > 0) {
                applicationId = appProperties[0].LoanApplicationId;
            }
        } else {
            applicationId = recId;
        }
        List<RLA_Standard_Condition__c> rsaStandardConditions = [SELECT Id, Name FROM RLA_Standard_Condition__c WHERE Residential_Loan_Application__c =: applicationId];

        Map<Id,String> mapChildConditionsMDt =  new Map<Id,String>();
        List<RLA_Sub_Condition__c> childConditionsmdtList = [SELECT Id, Name, Received__c, Condition__c, Condition_Assignee__c, RLA_Standard_Condition__c, RLA_Standard_Condition_Name__c  FROM RLA_Sub_Condition__c WHERE RLA_Standard_Condition__c =: rsaStandardConditions];
        System.debug('Sub Conditions List: '+childConditionsmdtList);
        return childConditionsmdtList;
    }

    @AuraEnabled(cacheable=true)
    public static Id getCustomConditionId(String recId) {
        List<RLA_Standard_Condition__c> rsaStandardConditions = [SELECT Id, Name FROM RLA_Standard_Condition__c WHERE Residential_Loan_Application__c =: recId AND Name = 'Custom Condition'];

        if ( rsaStandardConditions.Size()>0 ) {
            return rsaStandardConditions[0].Id;
        }

        return null;
    }

    @AuraEnabled
    public static Boolean updateCondition(String recId, List<String> selectedMdtIds, List<String> unSelectedMdtIds){
        System.debug( selectedMdtIds );
        System.debug( unSelectedMdtIds );
        try{
            String conditionStr='';
            List<Main_Conditions__mdt> mainConditionList = [SELECT Id, MasterLabel FROM Main_Conditions__mdt WHERE Id IN: selectedMdtIds OR Id IN: unSelectedMdtIds];
            Map<String, List<String>> selectionMap = new Map<String, List<String>>();
            selectionMap.put( 'selected', new List<String>() );
            selectionMap.put( 'unSelected', new List<String>() );
            for ( Main_Conditions__mdt mainCondition : [SELECT Id, MasterLabel FROM Main_Conditions__mdt WHERE Id IN: selectedMdtIds OR Id IN: unSelectedMdtIds]) {
                if ( selectedMdtIds.contains( mainCondition.Id ) ) {
                    selectionMap.get( 'selected' ).add( mainCondition.MasterLabel );
                }
                if ( unSelectedMdtIds.contains( mainCondition.Id ) ) {
                    selectionMap.get( 'unSelected' ).add( mainCondition.MasterLabel );
                }
            }
            System.debug( selectionMap.get( 'selected' ) );
            System.debug( selectionMap.get( 'unSelected' ) );
            
            List<RLA_Standard_Condition__c> alreadyExistingConditions = [SELECT Id, Name FROM RLA_Standard_Condition__c WHERE Residential_Loan_Application__c =: recId ];
            
            List<String> alreadyExistingConditionsNames = new List<String>();
            for ( RLA_Standard_Condition__c alreadyExistingCondition : alreadyExistingConditions ) {
                alreadyExistingConditionsNames.add( alreadyExistingCondition.Name );
            }
            
            List<Sub_Conditions__mdt> childConditions = [SELECT Id, Description__c, MasterLabel,  Parent_Conditions__r.MasterLabel FROM Sub_Conditions__mdt WHERE Parent_Conditions__c IN: selectedMdtIds];
            List<RLA_Standard_Condition__c> rlaStandardConditionsToInsert = new List<RLA_Standard_Condition__c>();
            for ( Main_Conditions__mdt mainCondition : mainConditionList ) {
                if ( selectionMap.get( 'selected' ).contains( mainCondition.MasterLabel ) && !alreadyExistingConditionsNames.contains( mainCondition.MasterLabel ) ) {
                    RLA_Standard_Condition__c rlasc = new RLA_Standard_Condition__c();
                    rlasc.Name = mainCondition.MasterLabel;
                    rlasc.Residential_Loan_Application__c = recId;
                    rlaStandardConditionsToInsert.add( rlasc );
                }
            }
            if(!rlaStandardConditionsToInsert.isEmpty()){
                insert rlaStandardConditionsToInsert;
            }
            
            List<RLA_Sub_Condition__c> rlaSubConditionsToInsert = new List<RLA_Sub_Condition__c>();
            for ( RLA_Standard_Condition__c rlasc : rlaStandardConditionsToInsert ) {
                for ( Sub_Conditions__mdt childCondition : childConditions ) {
                    if ( childCondition.Parent_Conditions__r.MasterLabel == rlasc.Name ) {
                        RLA_Sub_Condition__c rlaSubCondition = new RLA_Sub_Condition__c();
                        rlaSubCondition.Residential_Loan_Application__c = recId;
                        rlaSubCondition.RLA_Standard_Condition__c = rlasc.Id;
                        rlaSubCondition.Condition__c = childCondition.Description__c;
                        rlaSubConditionsToInsert.add( rlaSubCondition );
                    }
                }
            }
            if(!rlaSubConditionsToInsert.isEmpty()){
                insert rlaSubConditionsToInsert;
            }
            delete [ SELECT Id FROM RLA_Standard_Condition__c WHERE Residential_Loan_Application__c =: recId AND Name IN: selectionMap.get( 'unSelected' ) ];
            return  true;
        } catch( Exception e ) {
            System.debug( e );
            return false;
        } 
    }

    public class MainConditionsWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String masterLabel;
        @AuraEnabled public Boolean isChecked;

    }
    @AuraEnabled
    public static string updatecondis(Object data) {
        List<RLA_Sub_Condition__c> contactsForUpdate = (List<RLA_Sub_Condition__c>) JSON.deserialize(
            JSON.serialize(data),
            List<RLA_Sub_Condition__c>.class
        );
        try {
            update contactsForUpdate;
            return 'Success: contacts updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }
     @AuraEnabled
    public static void deletecondi(RLA_Sub_Condition__c condata){
       
        try {
            delete condata;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}