/**
 * @description
 * Class ErrorHandlingLogException
 * Class to be called in all Apex Classes/Triggers to log handled exceptions occuring in Error Handling Log object
 * 
 */
public without sharing class ErrorHandlingLogException extends Exception {

    // List to store Exceptions that have occured
    public static List<Error_Handling_Log__c> errorLogList = new List<Error_Handling_Log__c>();

    /**
     * @description      a method to Overload LogException
     * 
     * @param e          the exception type logged 
     */ 
    public static void LogException(Exception e) {
        LogException(e,'');
    }

     /** 
     * @description          a method to log handled exceptions in Error Handling Log object
     * 
     * @param e              the exception type logged
     * @param relatedId      the ID of input record
     */ 
    public static void LogException(Exception e, String relatedId) { 
        LogException(e, relatedId, '', '');
    }

    /** 
     * @description          a method to log handled exceptions occured during Integration in Error Handling Log object
     * 
     * @param relatedId      the ID of input record
     * @param integrationBody      the body sent/received from integration
     */ 
    public static void LogException(Exception e, String relatedId, String requestBody, String responseBody) {
        LogException(e, relatedId, 0, requestBody, responseBody);
    }

    /** 
     * @description          a method to log handled exceptions occured during Integration in Error Handling Log object
     * 
     * @param relatedId      the ID of input record
     * @param integrationBody      the body sent/received from integration
     */ 
    public static void LogException(Exception e, String relatedId, Integer statusCode, String requestBody, String responseBody) {
        String stackTrace = e.getStackTraceString().substringBefore('\n');
        String className = stackTrace.substringAfter('.').substringBefore('.');
        String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
        String Integrationpayload;
        if (String.isNotEmpty(requestBody) || String.isNotEmpty(responseBody)) {
            Integrationpayload = 'Status Code = ' + statusCode + '\n\nRequest =\n' + requestBody + '\n\nResponse =\n' + responseBody;
        }

        // Map fields of Error Handling Log object
        Error_Handling_Log__c errorLog = new Error_Handling_Log__c(
            Record_Id__c = relatedId,
            Exception_Message__c = e.getMessage(),
            Exception_Type__c = e.getTypeName(),
            Line_Number__c = e.getLineNumber(),
            Stack_Trace__c = e.getStackTraceString(),
            Method_Name__c = methodName,
            Class_Name__c = className,
            Integration_Payload__c = Integrationpayload
            );
        errorLogList.add(errorLog); 
    }

    /** 
     * @description          a method to save handled exceptions in Error Handling Log object
     * 
     */
    public static void saveExceptionLog() {
        if(!errorLogList.isEmpty()) {

            if (!System.isBatch() && !System.isFuture()) {
                saveExceptionLogFuture(JSON.serialize(errorLogList));
            } else {
                saveExceptionLogs(errorLogList);
            }
            //clear error log list
            errorLogList.clear();
        }
    }

    /** 
     * @description          a future method that handles the save of the error logs
     * 
     */
    @future
    public static void saveExceptionLogFuture(String serializedErrors) {
        List<Error_Handling_Log__c> deserializedErrorLogList = (List<Error_Handling_Log__c>) 
                                                                JSON.deserialize(serializedErrors, List<Error_Handling_Log__c>.class);
        saveExceptionLogs(deserializedErrorLogList);
    }

    private static void saveExceptionLogs(List<Error_Handling_Log__c> logs) {
        Database.SaveResult[] errorList = Database.insert(logs, false);

        //Iterate through each returned record
        for(Database.SaveResult sr : errorList) {
            if(!sr.isSuccess()) {
                //Insert operation failed, get details of all errors
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error details are as follows:');
                    System.debug(err.getStatusCode()+': '+err.getMessage());
                    System.debug('The error occured on these fields: '+err.getFields());
                }
            }
        }
    }
}