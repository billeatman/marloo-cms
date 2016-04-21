 <div ng-controller='UserManTabController as userManTab'>
	 <div class='col-md-3'>
		<div id='userman-nav' class='panel panel-mrl-menu'>
			<div class='panel-heading'>
				<h2 class='panel-title'>User Manager</h2>
			</div>
			<div class='panel-body'>
				<ul class='nav nav-stacked nav-pills' role='nav'>
					<li><a href='' ng-click="setActiveTab(0)" ng-class='{active : isActiveTab(0)}'><i class='typcn typcn-user'></i>Users</a></li>
					<li><a href='' ng-click="setActiveTab(1)" ng-class='{active : isActiveTab(1)}'><i class='typcn typcn-group'></i>Groups</a></li>
					<li><a href='' ng-click="setActiveTab(2)" ng-class='{active : isActiveTab(2)}'><i class='typcn typcn-business-card'></i>Roles</a></li>
				</ul> <!--- /nav --->
			</div> <!-- /panel-body -->
		</div> <!--- /userman-nav.panel --->
	</div> <!--- /3 --->
	<ng-include src="templates[activeTab]"> 
</div> <!-- /controller -->