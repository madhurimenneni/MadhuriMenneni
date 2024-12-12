global class PopulateCampaignSourceOnOpportunityBatch implements Database.Batchable<sObject>{
    Set<Id> oppIds;
     global PopulateCampaignSourceOnOpportunityBatch(){
    }
    global PopulateCampaignSourceOnOpportunityBatch( Set<Id> oppIds ) {
        this.oppIds = oppIds;
        system.debug('oppIds: '+oppIds);
        for ( Opportunity opp : [ SELECT Id FROM Opportunity WHERE Id IN: oppIds ]) {
            oppIds.add( opp.Id );
        }
    }

    global List<Opportunity> start(Database.BatchableContext BC){ 
        system.debug('oppIds: '+oppIds);
        List<Opportunity> opps = [ SELECT 
                                                Id,
                                                Name,
                                                CreatedDate,
                                                FinServ__ReferredByContact__c 
                                        FROM
                                                Opportunity 
                                        WHERE
                                                Id IN: oppIds ];
        return opps;                              
    }  

    global void execute(Database.BatchableContext BC, List<Opportunity> oppList){ 
        system.debug(oppList);
        Set<Id> brokerIdList = new Set<Id>();
        for( Opportunity opp : oppList ){
            brokerIdList.add( opp.FinServ__ReferredByContact__c );
        }
        system.debug('brokerIdList: '+brokerIdList);
        Set<Id> campaignIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        
        List<CampaignMember> campaignMembers = [SELECT
                                                        CampaignId,
                                                		ContactId
                                                FROM
                                                        CampaignMember 
                                                WHERE
                                                        ContactId IN: brokerIdList];
        for( CampaignMember cm : campaignMembers ){
            campaignIdSet.add( cm.CampaignId );
            contactIdSet.add( cm.ContactId );
        }
        List<Campaign> campaigns = [SELECT
                                   			Id,
                                   			IsActive,
                                    		CreatedDate
                                    FROM
                                   			Campaign
                                    WHERE
                                   			Id IN: campaignIdSet
                                   ORDER BY 
                                    		CreatedDate
                                    ASC];
        
        Map<Id,Id> opportunityWithCampignIdMap = new Map<Id,Id>();
        for( Opportunity opp : oppList ){
            for( Campaign campaign : campaigns ){
                system.debug('campaign createddate '+campaign.CreatedDate);
                system.debug('campaign createddate '+campaign.CreatedDate + ' opp createddate ' + opp.CreatedDate.adddays(-21));
                system.debug(contactIdSet.contains(opp.FinServ__ReferredByContact__c)
                    && campaign.CreatedDate >= opp.CreatedDate.adddays(-21)
                    && campaign.CreatedDate < opp.CreatedDate);
                if( contactIdSet.contains(opp.FinServ__ReferredByContact__c)
                    && campaign.CreatedDate >= opp.CreatedDate.adddays(-21)
                    && campaign.CreatedDate < opp.CreatedDate ){
                        system.debug('yes');
                        opportunityWithCampignIdMap.put( opp.Id, campaign.Id );
                        //break;
                    }
            }
        }
        system.debug('opportunityWithCampignIdMap: '+opportunityWithCampignIdMap);
        for( Opportunity opp : oppList ){
            system.debug(opportunityWithCampignIdMap.containsKey( opp.Id ));
            if( opportunityWithCampignIdMap.containsKey( opp.Id ) ){
                system.debug(opportunityWithCampignIdMap.get( opp.Id ));
                opp.CampaignId = opportunityWithCampignIdMap.get( opp.Id );
            } else{
                opp.CampaignId = null;
            }
        
        }
    } 
    global void finish(Database.BatchableContext BC){ 
    }
}