public with sharing class BatchApexErrorEventHandler {
    private Map<Id,AsyncApexJob> jobMap;
    private Map<Id,ApexClass> classMap;

    public BatchApexErrorEventHandler(){}

    public void handle(BatchApexErrorEvent[] errorEvents){
        Batch_Apex_Error_Settings__c settings = getSettings();
        getClassInfo(errorEvents);
        if(settings.Store_Errors_in_Custom_Object__c == TRUE){
            copyErrorsToSObject(errorEvents);
        }
    }

    private Batch_Apex_Error_Settings__c getSettings(){
        return Batch_Apex_Error_Settings__c.getInstance();
    }

    private void getClassInfo(BatchApexErrorEvent[] errorEvents){
        Set<Id> jobIds = new Set<Id>();
        for(BatchApexErrorEvent errorEvent: errorEvents){
            jobIds.add(errorEvent.AsyncApexJobId);
        }
        jobMap = new Map<Id,AsyncApexJob>([SELECT Id, ApexClassID FROM AsyncApexJob WHERE Id IN :jobIds]);
        Set<Id> classIds = new Set<Id>();
        for(AsyncApexJob job : jobMap.values()){
            classIds.add(job.ApexClassId);
        }
        classMap = new Map<Id,ApexClass>([SELECT Id, Name FROM ApexClass WHERE Id IN :classIds]);
    }

    private void copyErrorsToSObject(BatchApexErrorEvent[] errorEvents){
        Batch_Apex_Error__c[] errors = new Batch_Apex_Error__c[]{};
        for(BatchApexErrorEvent errorEvent: errorEvents){
            errors.add(new Batch_Apex_Error__c(
                    Apex_Class__c = classMap.get(jobMap.get(errorEvent.AsyncApexJobId).ApexClassId).Name,
                    Job_Id__c = errorEvent.AsyncApexJobId,
                    Batch_Phase__c = errorEvent.Phase,
                    Exception__c = errorEvent.Message,
                    Exception_Type__c = errorEvent.ExceptionType,
                    Job_Scope__c = errorEvent.JobScope,
                    Replay_ID__c = errorEvent.ReplayId,
                    Stack_Trace__c = errorEvent.StackTrace
            ));
        }
        insert errors;
    }
}