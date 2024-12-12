/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-18-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ContactRFMSegmentationTypeUpdateBatch implements Database.Batchable<Contact>, Database.Stateful {
    
    public Map<String, String> rfmScoreToSegmentationTypeMap;

    public ContactRFMSegmentationTypeUpdateBatch() {
        rfmScoreToSegmentationTypeMap = new Map<String, String>();
        for ( RFM_Score__mdt rfmScore : [ SELECT
                                                Id,
                                                MasterLabel,
                                                Segmentation_Type__c
                                         FROM
                                                RFM_Score__mdt] ) {
                                                    rfmScoreToSegmentationTypeMap.put( rfmScore.MasterLabel, rfmScore.Segmentation_Type__c );
                                                }
    }

    public List<Contact> start(Database.BatchableContext BC) {
        List<Contact> records = [ SELECT
                                        Id,
                                        RFM_Customer_Segmentation_Type__c,
                                        RFM_Score__c,
                                        RFM_R_Score__c,
                                        RFM_F_Score__c,
                                        RFM_M_Score__c,
                                        RFM_Months_Known__c
                                FROM 
                                        Contact
                                WHERE 
                                        ( RFM_Score__c != null AND RFM_Score__c != '' ) ];

        return records;
    }

    public void execute( Database.BatchableContext BC, List<Contact> records ) {
        
        for ( Contact con : records ) {
            if ( rfmScoreToSegmentationTypeMap.containsKey( con.RFM_Score__c ) ) {
                if ( con.RFM_Customer_Segmentation_Type__c != rfmScoreToSegmentationTypeMap.get( con.RFM_Score__c ) ) {
                    con.RFM_Customer_Segmentation_Type__c = rfmScoreToSegmentationTypeMap.get( con.RFM_Score__c );

                    if ( con.RFM_Customer_Segmentation_Type__c == '7. New Customers' &&  con.RFM_Months_Known__c > 5 ) {
                        con.RFM_Customer_Segmentation_Type__c = '8. Reactivated';
                    }

                    if ( con.RFM_Months_Known__c <= 3 ) {
                        con.RFM_Customer_Segmentation_Type__c = '7. New Customers';
                    }
                }
            }
        }

        database.update( records, false );

    }

    public void finish( Database.BatchableContext BC ) {

    }
}