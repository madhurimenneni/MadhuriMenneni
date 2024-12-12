trigger LoanApplicationAsset on LoanApplicationAsset (before insert,before update,after insert, after update, before delete, after delete, after undelete) {
    SObjectDomain.triggerHandler( LoanApplicationAssets.class );
}