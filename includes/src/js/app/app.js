(function() {
	'use strict';
	
	var app = angular.module('marloo-cms', ['datatables','ngResource','ui.bootstrap']);

	app.run(function ($rootScope) {
		$rootScope.baseUrl = "includes/src/js/app/";
	});

	/*app.controller('UsersController', [ '$scope', '$http', function($scope, $http, $route) {
		var userman = this;
		userman.users = [];

		$http({ method: 'GET', url: '/index.cfm/marlooauth:marlooUser/list'}).success(function(data){
			userman.users = data;
		});
	} ]);*/

	app.controller('UsersCtrl',UsersCtrl);
	function UsersCtrl($resource, DTOptionsBuilder) {
		var userman = this;
		userman.users = [];
		userman.dtOptions = DTOptionsBuilder.newOptions().withDisplayLength(50).withOption('lengthChange',false).withOption('info',false);
		$resource('/index.cfm/marlooauth/marlooUser/list').query().$promise.then(function(data) {
			userman.users = data;
		});
	};

	app.controller('UserManTabCtrl', ['$scope', '$rootScope', function($scope, $rootScope) {
		$scope.activeTab = 0;
		$scope.templates = [
			$rootScope.baseUrl + 'templates/userman/users.html', 
			$rootScope.baseUrl + 'templates/userman/groups.html', 
			$rootScope.baseUrl + 'templates/userman/roles.html'
		]

		$scope.setActiveTab = function(tabIndex){
			$scope.activeTab = tabIndex;
		}

		$scope.isActiveTab = function(tabIndex){
			return $scope.activeTab == tabIndex;
		}
	}]);
})();