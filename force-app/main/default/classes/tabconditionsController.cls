public class tabconditionsController {
    @AuraEnabled
    public static Map<id,Main_Conditions__mdt> getMdata(){
        
        Map<Id,Main_Conditions__mdt> mapParentChildConditionsMDt = new Map<Id,Main_Conditions__mdt>();
        List<Main_Conditions__mdt> parentConditionsmdtList = [SELECT Id, MasterLabel, (SELECT Id, Description__c FROM Parent_Conditions__r ) FROM Main_Conditions__mdt];
        System.debug('con'+parentConditionsmdtList);
        for(Main_Conditions__mdt mdtObj: parentConditionsmdtList){
            mapParentChildConditionsMDt.put(mdtObj.id,mdtObj);
        }
        system.debug('test'+mapParentChildConditionsMDt);
        return mapParentChildConditionsMDt;
    }
     @AuraEnabled
    public static Map<id,String> getCdata(String Names){
        
         Map<Id,String> mapChildConditionsMDt =  new Map<Id,String>();
            List<Sub_Conditions__mdt> childConditionsmdtList = [SELECT id,Description__c FROM Sub_Conditions__mdt WHERE Parent_Conditions__c =: Names];
        System.debug('con'+childConditionsmdtList);
        for(Sub_Conditions__mdt mdtObj: childConditionsmdtList){
            mapChildConditionsMDt.put(mdtObj.id,mdtObj.Description__c);
        }
        system.debug(mapChildConditionsMDt);
        return mapChildConditionsMDt;
    }
    @AuraEnabled
    public static String updateCondition(String recId,List<String> mdtIds){
        System.debug(recId);
        System.debug(mdtIds); 
        String mdtId;
        try{
            String conditionStr='';
            List<Sub_Conditions__mdt> childConditionsmdtList = [SELECT id,Description__c,Parent_Conditions__r.MasterLabel FROM Sub_Conditions__mdt WHERE Parent_Conditions__c =: mdtIds];
            conditionStr = childConditionsmdtList[0].Parent_Conditions__r.MasterLabel+'\n\n';
            for(Sub_Conditions__mdt mdtObj: childConditionsmdtList){
                conditionStr += mdtObj.Description__c+' \n\n ';
            }
            system.debug('conditionStr: '+conditionStr);
            ResidentialLoanApplication loanObj = new ResidentialLoanApplication();
            loanObj.Id = recId;
            loanObj.Selected_Conditions__c = conditionStr;
            update loanObj; 
           // return 'success';
           return  conditionStr;
        }catch( Exception e ) {
            System.debug( e );
            return 'failed';
        } 
    }
    

}