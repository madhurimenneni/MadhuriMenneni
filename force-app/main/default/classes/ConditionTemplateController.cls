public class ConditionTemplateController {

    @AuraEnabled
    public static Map<Id,MainConditionsWrapper> getParentCondition( String recId ){
        Map<Id,MainConditionsWrapper> mapParentChildConditionsMDt = new Map<Id,MainConditionsWrapper>();
        List<Main_Conditions__mdt> parentConditionsmdtList = [SELECT Id, MasterLabel, Default_Logic__c, Order_By__c FROM Main_Conditions__mdt WHERE Default_Logic__c =: false ORDER BY Order_By__c ASC];
        List<RLA_Standard_Condition__c> rsaStandardConditions = [SELECT Id, Name FROM RLA_Standard_Condition__c WHERE Residential_Loan_Application__c =: recId ];
        Map<String, Boolean> selectedRsatandardConditionsMap = new Map<String, Boolean>();
        for ( RLA_Standard_Condition__c rsaStandardCondition : rsaStandardConditions ) {
            selectedRsatandardConditionsMap.put(rsaStandardCondition.Name, True);
        }
        
        for(Main_Conditions__mdt mdtObj: parentConditionsmdtList){
            MainConditionsWrapper result = new MainConditionsWrapper();
            result.id = mdtObj.Id;
            result.masterLabel = mdtObj.MasterLabel;
            if ( !selectedRsatandardConditionsMap.isEmpty() && selectedRsatandardConditionsMap.containsKey( mdtObj.MasterLabel )) {
                result.isChecked = selectedRsatandardConditionsMap.get( mdtObj.MasterLabel );
            } else {
                result.isChecked = false;
            }
             mapParentChildConditionsMDt.put(mdtObj.id,result);
        }
        return mapParentChildConditionsMDt;
    }

    @AuraEnabled
    public static Map<Id,String> getChildCondition(String recId){
        Map<Id,String> mapChildConditionsMDt =  new Map<Id,String>();
        List<Id> childConditionsmdt = new List<Id>();
        List<Main_Sub_Condition__mdt> mainSubConditionsList = [SELECT Id, MasterLabel, Main_Conditions__c, Sub_Conditions__c FROM Main_Sub_Condition__mdt WHERE Main_Conditions__c =: recId];
        if(!mainSubConditionsList.isEmpty()){
            for(Main_Sub_Condition__mdt ms : mainSubConditionsList){
                if(ms.Sub_Conditions__c != null){
                    childConditionsmdt.add(ms.Sub_Conditions__c);
                }
            }
        }
        List<Sub_Conditions__mdt> childConditionsmdtList = [SELECT Id, Description__c FROM Sub_Conditions__mdt WHERE Id =: childConditionsmdt];
        for(Sub_Conditions__mdt mdtObj: childConditionsmdtList){
            mapChildConditionsMDt.put(mdtObj.id, mdtObj.Description__c);
        }
        return mapChildConditionsMDt;
    }

    @AuraEnabled
    public static Boolean updateCondition(String recId, List<String> selectedMdtIds, List<String> unSelectedMdtIds){
        try{
            String conditionStr='';
            List<Main_Conditions__mdt> mainConditionList = [SELECT Id, MasterLabel FROM Main_Conditions__mdt WHERE Id IN: selectedMdtIds OR Id IN: unSelectedMdtIds];
            Map<String, List<String>> selectionMap = new Map<String, List<String>>();
            selectionMap.put( 'selected', new List<String>() );
            selectionMap.put( 'unSelected', new List<String>() );
            for ( Main_Conditions__mdt mainCondition : [SELECT Id, MasterLabel FROM Main_Conditions__mdt WHERE Id IN: selectedMdtIds OR Id IN: unSelectedMdtIds]) {
                if (selectedMdtIds.contains( mainCondition.Id )) {
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
            
            List<Main_Sub_Condition__mdt> mainSubConditions = [SELECT Id, Main_Conditions__c, Main_Conditions__r.MasterLabel, Sub_Conditions__c, MasterLabel, Sub_Conditions__r.MasterLabel, Sub_Conditions__r.Description__c, Sub_Conditions__r.Condition_Assignee__c FROM Main_Sub_Condition__mdt WHERE Main_Conditions__c =: mainConditionList];
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
            for(Main_Sub_Condition__mdt mscon : mainSubConditions){
                for ( RLA_Standard_Condition__c rlasc : rlaStandardConditionsToInsert ) {
                    if ( mscon.Main_Conditions__r.MasterLabel == rlasc.Name ) {
                        RLA_Sub_Condition__c rlaSubCondition = new RLA_Sub_Condition__c();
                        rlaSubCondition.Residential_Loan_Application__c = recId;
                        rlaSubCondition.RLA_Standard_Condition__c = rlasc.Id;
                        rlaSubCondition.Condition__c = mscon.Sub_Conditions__r.Description__c;
                        rlaSubCondition.Condition_Assignee__c = mscon.Sub_Conditions__r.Condition_Assignee__c;
                        rlaSubConditionsToInsert.add( rlaSubCondition );
                    }
                }
            }
            if(!rlaSubConditionsToInsert.isEmpty()){
                insert rlaSubConditionsToInsert;
            }
            delete [SELECT Id FROM RLA_Standard_Condition__c WHERE Residential_Loan_Application__c =: recId AND Name IN: selectionMap.get('unSelected')];
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
}