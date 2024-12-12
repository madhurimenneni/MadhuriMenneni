/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-02-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ApprovalProcessRecordLockingHelper {
    public static Map<String, String> sObjectsToFieldMap = new Map<String, String>{
        'LoanApplicant' =>'LoanApplicationId',
        'LoanApplicantAddress' =>'LoanApplicationId',
        'LoanApplicantEmployment' => 'LoanApplicationId',
        'LoanApplicantIncome' =>'LoanApplicationId',
        'LoanApplicationProperty' =>'LoanApplicationId',
        'Valuation__c' =>'Residential_Loan_Application__c',
        'LoanApplicationAsset' =>'LoanApplicationId',
        'LoanApplicationLiability' =>'LoanApplicationId',
        'Fee__c' =>'Residential_Loan_Application__c',
        'AML_Flag__c' =>'Residential_Loan_Application__c',
        'RLA_Sub_Condition__c' =>'Residential_Loan_Application__c',
        'Rental_Income__c' =>'LoanApplicationId__c',
        'Property_Owner__c' =>'Residential_Loan_Application__c',
        'Downpayment__c' =>'Residential_Loan_Application__c'
    };

    public static void lockRecord( List<SObject> newRecords ) {
        
        Set<Id> rlaIds = new Set<Id>();
        for ( SObject record : newRecords ) {
            rlaIds.add( ( Id ) record.get( sObjectsToFieldMap.get( String.valueOf( record.getSObjectType() ) ) ) );
        }

        List<ProcessInstanceWorkitem> processInstances = [
            SELECT ProcessInstance.Status, ProcessInstance.TargetObjectId, ActorId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId IN :rlaIds
            AND ProcessInstance.Status = 'Pending'
            ORDER BY CreatedDate DESC
        ];

        Map<Id, List<ProcessInstanceWorkitem>> rlaIdToProcessInstancesListMap = new Map<Id, List<ProcessInstanceWorkitem>>();
        for (ProcessInstanceWorkitem pi : processInstances) {
            if (!rlaIdToProcessInstancesListMap.containsKey( pi.ProcessInstance.TargetObjectId ) ) {
                rlaIdToProcessInstancesListMap.put( pi.ProcessInstance.TargetObjectId, new List<ProcessInstanceWorkitem>() );
            }
            rlaIdToProcessInstancesListMap.get( pi.ProcessInstance.TargetObjectId ).add( pi );
        }

        for ( SObject record : newRecords) {
             Id rlaId = (Id) record.get(sObjectsToFieldMap.get(String.valueOf(record.getSObjectType())));

        List<ProcessInstanceWorkitem> workItems = rlaIdToProcessInstancesListMap.get(rlaId);
        if (workItems != null && !workItems.isEmpty()) {
            Id actorId = workItems[0].ActorId;
            if (UserInfo.getUserId() != actorId) {
                record.addError('This record is locked due to Escalation. If you need to edit it, contact your CO/Manager.');
            }
        }
    }
}
}