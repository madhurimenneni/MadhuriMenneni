public class ResidentialLoanApplicationQueueable implements Queueable, Database.AllowsCallouts{
    private Set<Id> appIds;
    private String typeOfApp;
    public ResidentialLoanApplicationQueueable( Set<Id> appIds, String typeOfApp ) {
        this.appIds = appIds;
        this.typeOfApp = typeOfApp;
    }

    public void execute( QueueableCOntext context ) {
        if ( typeOfApp == 'failedApps') {
            ResidentialLoanApplicationsHelper.DeleteFailedApplicationsNonFuture( appIds );
        }
    }
   
}