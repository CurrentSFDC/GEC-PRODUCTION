global class FundRequestApprovalRequest {

WebService static void SendApprovalRequest(string id) {

// create the new approval request to submit
Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
req.setObjectId(id);
req.setComments('Submitted for approval. Please approve.');
// submit the approval request for processing
Approval.ProcessResult result = Approval.Process(req);
// display if the reqeust was successful
System.debug('Submitted for approval successfully: '+result.isSuccess());

}
}