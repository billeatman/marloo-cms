(function() {
	'use strict';
	
	var app = angular.module('marloo-cms', ['ui.bootstrap']);

	app.run(function ($rootScope) {
		$rootScope.baseUrl = "includes/js/app/";
	});

	app.controller('UsersController', [ '$scope', '$http', function($scope, $http, $route) {
		var userman = this;
		userman.users = [];

		$http({ method: 'GET', url: '/index.cfm/marlooauth:marlooUser/list'}).success(function(data){
			userman.users = data;
		});
	} ]);

	app.controller('UserManTabController', ['$scope', '$rootScope', function($scope, $rootScope) {
		$scope.activeTab = 0;
		$scope.templates = [
			$rootScope.baseUrl + 'templates/users.html', 
			$rootScope.baseUrl + 'templates/groups.html', 
			$rootScope.baseUrl + 'templates/roles.html'
		]

		$scope.setActiveTab = function(tabIndex){
			$scope.activeTab = tabIndex;
		}

		$scope.isActiveTab = function(tabIndex){
			return $scope.activeTab == tabIndex;
		}
	}]);
})();