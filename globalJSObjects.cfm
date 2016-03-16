<script language="javascript" type="application/javascript">
var getCookie = function(cName) {
	if(document.cookie){
		//console.log(document.cookie);
		index = document.cookie.indexOf(cName);
		if (index != -1){
		var namestart = (document.cookie.indexOf("=", index) + 1);
		var nameend = document.cookie.indexOf(";", index);
		if (nameend == -1) {nameend = document.cookie.length;}
		return document.cookie.substring(namestart, nameend);
	}
	else{
		return null;}
	}
}

