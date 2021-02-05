trigger BatchApexErrorEvent on BatchApexErrorEvent (after insert) {
    new BatchApexErrorEventHandler().handle(Trigger.new);
}