/**
* Redirects Model
*/

component persistent="true" table="mrl_redirect"{
	property name="url" ormtype="text";
	property name="id" fieldtype="id" column="r_id" generator="native";
}
