public with sharing class BatchApexErrorEventHandler {
    public static void handle(BatchApexErrorEvent[] errorEvents){
        for(BatchApexErrorEvent errorEvent : errorEvents){
            System.debug(errorEvent);
        }
    }
}