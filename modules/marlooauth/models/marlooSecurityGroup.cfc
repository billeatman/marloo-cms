component entityName="marlooSecurityGroup" persistent="true" table="mrl_securityGroups" extends="cborm.models.ActiveEntity" {

	// Primary Key
	property name="groupName" fieldtype="id" column="GroupName" generator="assigned" setter="true";

	// Properties
	property name="description" column="groupDesc" ormtype="string";
	property name="active" column="active" ormtype="string";
	property name="ownerMail" ormtype="string";
	property name="securityLevel" ormtype="numeric";
	property name="type" ormtype="string";

	property name="users" fieldtype="many-to-many"
	cfc="marlooUser" type="array" singularname="user" orderby="login asc"
	linktable="securityGroupMember" fkcolumn="groupName" inversejoincolumn="login" inverse="true";
}