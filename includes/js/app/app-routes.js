(function() {
	'use strict';

	var baseURL = "includes/js/app/";
	var app = angular.module('marloo-cms', ['ngRoute']);

	app.controller('UsersController', [ '$scope', '$http', function($scope, $http, $route) {
		var userman = this;
		userman.users = [];

		$http({ method: 'GET', url: '/index.cfm/marlooauth:marlooUser/list'}).success(function(data){
			userman.users = data;
			console.log(userman.users);
		});
	} ]);

	app.controller('UsermanController', ['$scope', '$route', function($scope, $route) {
		$scope.currentURL = 'index.cfm/marlooauth:userman/listUsers';
		$scope.current = $route.current ? $route.current.$$route.originalPath : '';
	}]);

	app.config(['$routeProvider', 
		function($routeProvider){
			$routeProvider.
			when('/Users', {
				templateUrl: baseURL + 'templates/users.html'
			}).
			when('/Groups', {
				templateUrl: baseURL + 'templates/groups.html'
			}).
			when('/Roles', {
				templateUrl: baseURL + 'templates/roles.html'
			}).
			otherwise({
				redirectTo: '/Users'
			});
	}]);
})();