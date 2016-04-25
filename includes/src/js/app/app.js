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

	app.factory('userServ', function($http, $rootScope, $q, $resource) {
		var service = {};
		var baseUrl = $rootScope.baseUrl;

		service.listUsers = function() {
			return $resource('/index.cfm/marlooauth/marlooUser/list').query().$promise;
		};

		service.getUser = function(username) {
			return $resource('/index.cfm/marlooauth/marlooUser/list').query().$promise;
		};

		return service;
	});

	app.controller('UserCtrl', UserCtrl);
	function UserCtrl($scope, $rootScope, element){
	};


	app.directive('user', function($rootScope) {
		return {
			controllerAs: 'user',
			templateUrl: $rootScope.baseUrl + 'templates/userman/user.html'
		};
	});

	app.controller('UsersCtrl',UsersCtrl);
	function UsersCtrl($scope, $rootScope, DTOptionsBuilder, DTColumnBuilder, $filter, $resource, userServ) {
		var userman = this;
		userman.message = ''; 
		$scope.baseUrl = $rootScope.baseUrl;
		userman.someClickHandler = someClickHandler;

		$scope.showUser = false;

		userman.dtOptions = DTOptionsBuilder.fromFnPromise(function() {
       		return userServ.listUsers();
    	}).withOption('info',false).withOption('lengthChange',false).withDisplayLength(50).withOption('rowCallback', rowCallback);

    	userman.dtColumns = [
	        DTColumnBuilder.newColumn('firstName').withTitle('User').renderWith(function(data, type, full) {
	            return full.firstName + ' ' + full.lastName;
	        }),
	        DTColumnBuilder.newColumn('createdDate').withTitle('Added On').renderWith(function(data, type) {
	        		return $filter('date')(data, 'MMM dd, yyyy');
	        }),
	        DTColumnBuilder.newColumn('active').withTitle('Active?')
	    ];

	    function someClickHandler(info){
	    	userServ.getUser('billeatman@hotmail.com').then(function(){
	  			$scope.showUser = true;
  			});
	    	userman.message = info.firstName;
	    };

	    function rowCallback(nRow, aData, iDisplayIndex, iDisplayIndexFull){
	    	$('td', nRow).unbind('click');
	    	$('td', nRow).bind('click', function(){
	    		$scope.$apply(function() {
	    			userman.someClickHandler(aData);
	    		});
	    	});
    	};
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

	app.controller('UserCtrl', ['$scope', '$rootScope', function($scope, $rootScope) {
		$scope.username = '';
	}]);
})();