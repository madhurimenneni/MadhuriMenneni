@isTest
private class OpportunityHandlerTest {
     @testSetup static void setupData() { 
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Account acc = new Account(OwnerId = UserInfo.getUserId(), 
                                  Name = 'Test Business Account'); 
        insert acc;
        List<Contact> contactsToInsert = new List<Contact>();
        Contact con1 = new Contact(LastName = 'Test Contact1', AccountID = acc.id, Email = 'test_1@gmail.com' );
        contactsToInsert.add(con1);
        Contact con2 = new Contact(LastName = 'Test Contact2', AccountID = acc.id, Email = 'test_2@gmail.com' );
        contactsToInsert.add(con2);
        Contact con3 = new Contact(LastName = 'Test Contact3', AccountID = acc.id, Email = 'test_3@gmail.com' );
        contactsToInsert.add(con3);
        insert contactsToInsert;
        Campaign campaign = new Campaign(Name = 'Test Campaign',
                                        OwnerId = UserInfo.getUserId(),
                                        Status = ApexConstants.PLANNED_CAMPAIGN_STATUS,
                                        Type = ApexConstants.EVENT_CAMPAIGN_TYPE);
        insert campaign;
        CampaignMember campaignMember1 = new CampaignMember(CampaignId = campaign.Id,
                                                            ContactId = con1.id,
                                                            Status = ApexConstants.SENT_CAMPAIGN_MEMBER_STATUS);
        insert campaignMember1;
        CampaignMember campaignMember2 = new CampaignMember(CampaignId = campaign.Id,
                                                            ContactId = con2.id,
                                                            Status = ApexConstants.SENT_CAMPAIGN_MEMBER_STATUS);
        insert campaignMember2;
     }
    
     @isTest static void populatePrimaryCampaignSourceTest() {
        List<Contact> contactList = [SELECT Id, LastName FROM Contact];
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> updatedOppList = new List<Opportunity>();
        List<Opportunity> blankContactOppList = new List<Opportunity>();
         for( Contact con : contactList ){
             if( con.LastName == 'Test Contact1' ){
                 Opportunity opp = new Opportunity(Name = 'Test Opportunity',
                                                CloseDate = Date.today(),
                                                FinServ__ReferredByContact__c = con.Id,
                                                StageName = ApexConstants.QUALIFICATION_OPPORTUNITY_STAGE);
                 oppList.add(opp);
             }
         }
         insert oppList;
         Campaign campaign = [SELECT Id FROM Campaign];
        Opportunity opp = [ SELECT Id,CampaignId FROM Opportunity ];
        //on Opp insert
        //System.assertEquals(campaign.Id, opp.CampaignId, 'Campaign is not matching');
         for( Contact con : contactList ){
             if( con.LastName == 'Test Contact2' ){
                 opp.FinServ__ReferredByContact__c = con.Id;
                 updatedOppList.add(opp);
             }
         }
         update updatedOppList;
        opp = [ SELECT Id,CampaignId FROM Opportunity ];
         //on Opp update
        //System.assertEquals(campaign.Id, opp.CampaignId, 'Campaign is not matching');
        for( Contact con : contactList ){
             if( con.LastName == 'Test Contact3' ){
                 opp.FinServ__ReferredByContact__c = con.Id;
                 blankContactOppList.add(opp);
             }
         }
         update blankContactOppList;
         opp = [ SELECT Id,CampaignId FROM Opportunity ];
         //blank campaign to contact
        //System.assertEquals(null, opp.CampaignId, 'Campaign is not matching');
    } 
}