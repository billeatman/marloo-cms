component entityName="marlooUser" persistent="true" table="mrl_securityUsers" extends="cborm.models.ActiveEntity" {
	// Wirebox
	// property name="bcrypt" inject="bcrypt@bcrypt" setter=false getter=true;

	// Primary Key
	property name="login" fieldtype="id" column="login" generator="assigned";

	// Properties
	property name="firstname" ormtype="string";
	property name="lastname" ormtype="string";
	property name="pwHash" ormtype="string";
	property name="pwHashDate" ormtype="timestamp" setter="false";
	property name="active" ormtype="string";
	property name="createdDate" ormtype="timestamp" setter="false";

	property name="securityGroups" fieldtype="many-to-many" 
		cfc="marlooSecurityGroup" type="array" singularname="securityGroup" orderby="groupName asc"
		linktable="securityGroupMember" fkcolumn="login" inversejoincolumn="groupName";

	// constraints
	this.constraints = {
		"login" = {required = true, type = "email", size = "5..50"},
		pwhash = {required = false},
		active = {required = true},
		createdDate = {required = true, type='date'},
		securityGroups = {required = false},
		firstname = {required = true, size = "1..50"},
		lastname = {required = true, size = "1..50"}
	}

	function init(){
		variables.securityGroups = [];
		variables.login = "";
		variables.pwhash = "";
		variables.active = false;

		return this;
	}

	void function setActive(required boolean active) {
		if (arguments.active) {
			variables.active = 'T';
		} else {
			variables.active = 'F';
		}
	}

	boolean function getActive() {
		if (variables.active EQ 'T'){
			return true;
		}		
		return false;
	}

	void function setPassword(required string password) {

	}



}