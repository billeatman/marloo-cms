 <div ng-controller='UserManTabController as userManTab'>
	 <div class='col-md-8'>
		<div id='userman-nav'>
			<ul class='text-center nav nav-justified nav-pills' role='group'>
				<li><a href='' ng-click="setActiveTab(0)" ng-class='{active : isActiveTab(0)}' class='btn btn-default'><i class='typcn typcn-user'></i>Users</a></li>
				<li><a href='' ng-click="setActiveTab(1)" ng-class='{active : isActiveTab(1)}' class='btn btn-default'><i class='typcn typcn-group'></i>Groups</a></li>
				<li><a href='' ng-click="setActiveTab(2)" ng-class='{active : isActiveTab(2)}' class='btn btn-default'><i class='typcn typcn-business-card'></i>Roles</a></li>
			</ul> <!--- /nav --->
		</div> <!--- /userman-nav --->
		<hr />
		<ng-include src="templates[activeTab]"> 
	</div> <!--- /8 --->
</div> <!-- /controller -->