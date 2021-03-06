@RestResource (urlMapping = '/deleteCustomField/*')
global class DeleteCustomField
{
    @HttpDelete
    global static void deleteField()
    {
        String customObjectName = RestContext.request.params.get('customObjectName');
        String customFieldName = RestContext.request.params.get('customFieldName');
        MetadataService.MetadataPort service = createService();
        List<MetadataService.DeleteResult> results = service.deleteMetadata('CustomField', new String[] { customObjectName+'__c.'+customFieldName+'__c' });
        handleDeleteResults(results[0]);
    }

    public class CreateCustomObjectException extends Exception { }

    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    public static void handleDeleteResults(MetadataService.DeleteResult deleteResult)
    {
        if(deleteResult==null || deleteResult.success)
            return;
        if(deleteResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + deleteResult.fullName + '.');
            for(MetadataService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new CreateCustomObjectException(String.join(messages, ' '));
        }
        if(!deleteResult.success)
            throw new CreateCustomObjectException('Request failed with no specified error.');
    }
}