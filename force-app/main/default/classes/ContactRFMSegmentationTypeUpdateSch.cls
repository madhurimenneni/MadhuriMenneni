public class ContactRFMSegmentationTypeUpdateSch implements Schedulable {
    public void execute(System.SchedulableContext context) {
        Database.executeBatch(new ContactRFMSegmentationTypeUpdateBatch(),50);
    }
}