
//............................................................................................................
ACE_INLINE unsigned int Base_ObjMgr:: PeerID () { return this->peer_id_; }

//............................................................................................................
ACE_INLINE unsigned int Base_ObjMgr::ModelID () { return this->peer_id_; }

//............................................................................................................
ACE_INLINE unsigned int Base_ObjMgr::NodeID () { return this->node_id_; }

//............................................................................................................
ACE_INLINE int Base_ObjMgr::PID() { return this->pid_; }

//............................................................................................................
// TODO  evaluate removing this!!!!
ACE_INLINE const DBMgr *Base_ObjMgr::db() const { return this->db_.get(); }

//..................................................................................................
ACE_INLINE
const char *
Base_ObjMgr::hostname ()
{
	//return ((this->hostrec_ != NULL)? hostrec_->h_aliases[0] : "ERROR" );
	return this->un_.nodename;
}

//..................................................................................................
ACE_INLINE
const char *
Base_ObjMgr::FQDN ()
{
	//return ((this->hostrec_ != NULL)? hostrec_->h_name : "ERROR" );
	return this->un_.nodename;  // TODO  revisit this, VM broke it;
}

//..................................................................................................
ACE_INLINE
const char *
Base_ObjMgr::ipaddress ()
{
	return this->ip_address_.c_str();
}
