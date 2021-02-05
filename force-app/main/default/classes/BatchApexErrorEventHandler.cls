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
        if(settings.Send_Errors_To__c != null){
            System.debug('Sending email');
            emailErrors(errorEvents, settings.Send_Errors_To__c);
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

    private void emailErrors(BatchApexErrorEvent[] errorEvents, String recipients){
        Messaging.reserveSingleEmailCapacity(1);
        String[] toAddresses = new String[]{};
        if(recipients.contains(',')){
            toAddresses = recipients.split(',');
        }else{
            toAddresses.add(recipients);
        }
        String subject = 'Batch Apex Error Notification';
        String body = 'The following batch failed during execution and did not recover: \n\n';
        for(BatchApexErrorEvent errorEvent: errorEvents){
            String className = classMap.get(jobMap.get(errorEvent.AsyncApexJobId).ApexClassId).Name;
            body += 'Job Id: '+errorEvent.AsyncApexJobId+'\n'+className + ' failed during ' + errorEvent.Phase + '.\nException: '+errorEvent.Message+'\nStack trace: '+errorEvent.StackTrace + '\nAffected records: '+errorEvent.JobScope;
        }
        sendEmail(toAddresses,subject,body);
    }

    private static List<Messaging.SendEmailResult> sendEmail(List<String> toAddresses,String subject, String body){
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setUseSignature(false);
        List<Messaging.SendEmailResult> res = Test.isRunningTest() ? new List<Messaging.SendEmailResult>{(Messaging.SendEmailResult)JSON.deserialize('{}',Messaging.SendEmailResult.class)} : Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        return res;
    }
}