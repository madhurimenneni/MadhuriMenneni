global class ScheduleRollup implements Schedulable{
    
    global void execute(SchedulableContext ctx){
        
        List<FinServ__RollupByLookupConfig__c> queriedRollups1= new List<FinServ__RollupByLookupConfig__c>();
        queriedRollups1 =[Select Id From FinServ__RollupByLookupConfig__c Where FinServ__Active__c = true];
        
        system.debug('queriedRollups1'+ queriedRollups1);
        
        List<Id> rollupsToRun1 = new List<Id>();
        for (FinServ__RollupByLookupConfig__c Rollup1 : queriedRollups1) {
            
            
            rollupsToRun1.add(Rollup1.Id);
            
        }
        
        // Create an instance of FSC Class: RollupRecalculationBatchable
        FinServ.RollupRecalculationBatchable Job = new FinServ.RollupRecalculationBatchable(rollupsToRun1);
            
            Database.executeBatch(Job);
        
    }
    
}