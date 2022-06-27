/**
 * Created by Misi on 2021-07-19.
 */

global class VimeoConnector implements Database.Batchable<SObject>, Database.AllowsCallouts {

    private List<Id> mediaElementIds;

    public VimeoConnector(List<Id> mediaElementIds) {
        this.mediaElementIds = mediaElementIds;
    }

    public void setThumnailImageURL(Community_Content_Media__c media) {
        String vimdeoId = media.Content_URL__c.substringAfterLast('/');
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://vimeo.com/api/v2/video/' + vimdeoId + '.json');
        HttpResponse response = h.send(request);
        System.debug('response.getBody ' + response.getBody());
        if(response.getStatusCode() == 200) {
            List<VimeoDetails> vimeoDetails = (List<VimeoDetails>) JSON.deserialize(response.getBody(), List<VimeoDetails>.class);
            if (vimeoDetails.size() > 0) {
                media.Thumbnail__c = '';
                if (String.isNotBlank(vimeoDetails[0].thumbnail_medium)) {
                    media.Thumbnail__c = vimeoDetails[0].thumbnail_medium;
                } else if(!String.isNotBlank(vimeoDetails[0].thumbnail_medium)){
                    media.Thumbnail__c = 'https://gecurrent--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Png&versionId=0683j00000C8o8NAAR&operationContext=DELIVERY&contentId=0693j00000BaTotAAF&page0&d=/a/3j000000HTvI/5irOv.AfM6tk9Mw3cb51h90h.ynDhpTnHWzHIQbbuzs&oid=00D3j000000hC5C';
                }
            }
        }

        update media;
    }

    global Iterable<SObject> start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id,Content_URL__c,Thumbnail__c FROM Community_Content_Media__c WHERE Id IN:mediaElementIds]);
    }

    global void execute(Database.BatchableContext context, List<Community_Content_Media__c> mediaElements) {
        if (mediaElements.size() > 1) {
            throw new ListException('mediaElements cannot have more than 1 element');
        }
        setThumnailImageURL(mediaElements[0]);
    }

    global void finish(Database.BatchableContext bc) {

    }

    public class VimeoDetails {
        public String thumbnail_large;
        public String thumbnail_medium;
        public String thumbnail_small;
        public Long id;
    }
}