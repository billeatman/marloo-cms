/**
* I am a new handler
*/
component{
	property name="userService" inject="entityservice:marlooUser" setter=false getter=false;

	// OPTIONAL HANDLER PROPERTIES
	this.prehandler_only 	= "";
	this.prehandler_except 	= "";
	this.posthandler_only 	= "";
	this.posthandler_except = "";
	this.aroundHandler_only = "";
	this.aroundHandler_except = "";		
	// REST Allowed HTTP Methods Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'}
	this.allowedMethods = {};
	
	/*
	IMPLICIT FUNCTIONS: Uncomment to use
	function preHandler( event, rc, prc, action, eventArguments ){
	}
	function postHandler( event, rc, prc, action, eventArguments ){
	}
	function aroundHandler( event, rc, prc, targetAction, eventArguments ){
		// executed targeted action
		arguments.targetAction( event );
	}
	function onMissingAction( event, rc, prc, missingAction, eventArguments ){
	}*/
/*
	function onError( event, rc, prc, faultAction, exception, eventArguments ){
		cfheader(statuscode="500", statustext="Internal Server Error");
		abort;
	}*/
		
	function list(event,rc,prc){
		var c = userService.newCriteria();

		//c.isEQ('active', javacast('string', 'T'));

		var users = c.list(asQuery: false);
		var r = [];

		for (var user in users) {
			var u = {
				'login' = user.getLogin(),
				'firstName' = user.getFirstName(),
				'lastName' = user.getLastName(),
				'active' = user.getActive(),
				'createdDate' = toISO8601(user.getCreatedDate()),
				'pwHashDate' = toISO8601(user.getPwHashDate())
			};
			ArrayAppend(r, u);
		}

		event.renderData(data: r, type='json');
	}	

	function create(event,rc,prc){
		var requestContent = GetHttpRequestData().content; 
		
		var category = orm.populateFromJSON(target: orm.new(), jsonString: requestContent, include:"name,creator");
		
		category.setCreated_at(now());
		category.setUpdated_at(now());
		category.save();

		event.renderData(data: category, type="json", statusCode=201, statusMessage="Created");
	}	

	function read(event,rc,prc){		
		prc.category = orm.get(rc.categoryId);
		event.renderData(data: prc.category, type="json", statusCode=200, statusMessage="OK");
	}	

	function update(event,rc,prc){
		var requestContent = GetHttpRequestData().content; 
		var category = orm.populateFromJSON(target: orm.get(rc.categoryId), jsonString: requestContent, include:"name,creator");

		category.setUpdated_at(now());
		category.save();
		cfheader(statuscode="204", statustext="No content");
		abort();
	}	

	function delete(event,rc,prc){
		var category = orm.get(rc.categoryId);
		orm.delete(category);
		cfheader(statuscode="200", statustext="OK");
		abort();
	}
}
