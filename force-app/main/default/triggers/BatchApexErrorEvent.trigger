trigger BatchApexErrorEvent on BatchApexErrorEvent (after insert) {
    BatchApexErrorEventHandler.handle(Trigger.new);
}