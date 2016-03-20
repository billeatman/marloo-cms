component entityName="marlooUser" persistent="true" table="mrl_securityUsers" extends="cborm.models.ActiveEntity" {
	// Wirebox
	property name="bcrypt" inject="bcrypt@bcrypt" persistent="false" setter=false getter=false;

	// Primary Key
	property name="login" fieldtype="id" column="login" generator="assigned";

	// Properties
	property name="firstname" ormtype="string";
	property name="lastname" ormtype="string";
	property name="pwHash" ormtype="string" setter="false";
	property name="pwTemp" ormtype="string";
	property name="pwHashDate" ormtype="timestamp" setter="false";
	property name="active" ormtype="string";
	property name="createdDate" ormtype="timestamp" setter="false";

	property name="securityGroups" fieldtype="many-to-many" 
		cfc="marlooSecurityGroup" type="array" singularname="securityGroup" orderby="groupName asc"
		linktable="mrl_securityGroupMember" fkcolumn="login" inversejoincolumn="groupName";

	// constraints
	this.constraints = {
		login = {required = true, type = "email", size = "5..50"},
		pwhash = {required = false},
		active = {required = true},
		createdDate = {required = true, type='date'},
		securityGroups = {required = false},
		firstname = {required = true, size = "1..50"},
		lastname = {required = true, size = "1..50"}
	}

	function init(){
		super.init();
		
		variables.securityGroups = [];
		variables.login = "";
		variables.pwHash = "";
		variables.pwHashDate = "";
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

	boolean function setPassword(required string password) {
		variables.pwHash = bcrypt.hashPassword(arguments.password);
		variables.pwHashDate = now();

		// Set pwTemp to NULL
		structDelete(variables, pwTemp);
		
		return true;
	}

	boolean function checkPassword(required string password) {
		return bcrypt.checkPassword(candidate: arguments.password, bCryptHash: variables.pwHash);
	}
}