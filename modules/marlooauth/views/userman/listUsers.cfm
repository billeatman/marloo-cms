<div ng-controller='UserManTabController as userManTab'>
	<div class='col-md-3'>
		<div class='panel-group'>
			<div id='userman-nav-panel' class='panel panel-default'>
				<div class='panel-heading'>
					<h2 class='panel-title'><i class='typcn typcn-group-outline'></i> User Manager</h2>
				</div> <!--- /panel-heading --->
				<div class='panel-body'>
					<div class='btn-group-vertical' role='group'>
						<a href='' ng-click="setActiveTab(0)" ng-class='{active : isActiveTab(0)}' class='btn btn-default btn-lg'><i class='typcn typcn-user'></i> Users</a>
						<a href='' ng-click="setActiveTab(1)" ng-class='{active : isActiveTab(1)}' class='btn btn-default btn-lg'><i class='typcn typcn-group'></i> Groups</a>
						<a href='' ng-click="setActiveTab(2)" ng-class='{active : isActiveTab(2)}' class='btn btn-default btn-lg'><i class='ti ti-id-badge'></i> Roles</a>
					</div> <!--- /btn-group-v --->
				</div> <!--- /panel-body --->
			</div> <!--- /panel --->
		</div> <!--- /panel-group --->
	</div> <!--- /3 --->
	<ng-include src="templates[activeTab]"> 
</div>


