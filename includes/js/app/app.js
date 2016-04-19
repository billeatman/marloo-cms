(function() {
	'use strict';

	var app = angular.module('marloo-cms', []);

	app.controller('UsermanController', [ '$http', function($http) {
		var userman = this;
		userman.users = [];

		$http({ method: 'GET', url: '/index.cfm/marlooauth:marlooUser/list'}).success(function(data){
			userman.users = data;
			console.log(userman.users);
		});
	} ]);
})();