public class OpportunityHandler {
    List<Opportunity> newOpportunities = new List<Opportunity>();
    Map<Id, Opportunity> oldOpportunities = new Map<Id, Opportunity>();
    
    public OpportunityHandler( List<Opportunity> newRecords, Map<Id, Opportunity> oldRecordsMap ) {
        newOpportunities = newRecords;
        oldOpportunities = oldRecordsMap;
    }
    
    public OpportunityHandler populatePrimaryCampaignSource(){
        List<Opportunity> oppIdList = new List<Opportunity>();
        Set<Id> brokerIds = new Set<Id>();
        
        for (Opportunity newOpp : newOpportunities) {
            if (meetsRequirementForPopulatePrimaryCampaignSource(newOpp)) {
                oppIdList.add(newOpp);
                brokerIds.add(newOpp.FinServ__ReferredByContact__c);
            }
        }
        
        // Query for the most recent campaigns for each broker within the last 21 days
        Map<Id,List<CampaignMember>> brokerVsCampaign = new Map<Id,List<CampaignMember>>();
        for (CampaignMember member : [
            SELECT CampaignId, ContactId, Campaign.CreatedDate
            FROM CampaignMember
            WHERE ContactId IN :brokerIds
            ORDER BY Campaign.CreatedDate DESC
        ]) {
            
            if(member.Campaign.CreatedDate >= date.today().adddays(-21) &&
               member.Campaign.CreatedDate < date.today()){
                   if(!brokerVsCampaign.containsKey(member.ContactId)){
                       brokerVsCampaign.put(member.ContactId,new List<CampaignMember>{member});
                   }
                   else{
                       brokerVsCampaign.get(member.ContactId).add(member);
                   }
               }
        } 
        
        // Populate Primary Campaign Source field on opportunities
        for (Opportunity opp : oppIdList) {
            if(brokerVsCampaign.size()>0 && brokerVsCampaign.containsKey(opp.FinServ__ReferredByContact__c) &&
               brokerVsCampaign.get(opp.FinServ__ReferredByContact__c)!= null)
            {
                
                opp.CampaignId = brokerVsCampaign.get(opp.FinServ__ReferredByContact__c)[0].CampaignId;
            }
            else {
                opp.CampaignId = null;
            }
        }
        return this;
    }
    
    public Boolean meetsRequirementForPopulatePrimaryCampaignSource( Opportunity newOpp ) {
        Boolean meetsRequirementForPopulatePrimaryCampaignSource = false;
        if (oldOpportunities != null) {
            Opportunity oldOpp = oldOpportunities.get(newOpp.Id); 
            if (newOpp.FinServ__ReferredByContact__c != oldOpp.FinServ__ReferredByContact__c &&
                newOpp.FinServ__ReferredByContact__c != null) {
                    meetsRequirementForPopulatePrimaryCampaignSource = true; 
                }
        } else{
            if( newOpp.FinServ__ReferredByContact__c != null ){
                meetsRequirementForPopulatePrimaryCampaignSource = true;
            }
        }
        return meetsRequirementForPopulatePrimaryCampaignSource;
    }
}