public with sharing class BatchThatErrors implements Database.Batchable<SObject>,
        Database.RaisesPlatformEvents{
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id from User');
    }

    public void execute(Database.BatchableContext BC, List<User> users){
        users[0].Id = 'invalid id';
    }

    public void finish(Database.BatchableContext BC){}
}