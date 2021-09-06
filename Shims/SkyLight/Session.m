// logout

void SLSSessionSwitchToAuditSessionIDWithOptions(unsigned int edi_sessionID,NSDictionary* rsi_options)
{
	// TODO: cube?
	
	// trace(@"SLSSessionSwitchToAuditSessionIDWithOptions %d %@",edi_sessionID,rsi_options);
	
	SLSSessionSwitchToAuditSessionID(edi_sessionID);
}