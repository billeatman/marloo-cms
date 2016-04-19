<div class='col-md-3'>
	<div class='panel-group'>
		<div id='userman-nav-panel' class='panel panel-default'>
			<div class='panel-heading'>
				<h2 class='panel-title'><i class='typcn typcn-group-outline'></i> User Manager</h2>
			</div> <!--- /panel-heading --->
			<div class='panel-body'>
				<div class='btn-group-vertical' role='group' ng-controller='UsermanController as userman'>
				{{currentURL}}
					<a ng-href='{{currentURL}}#Users' class='btn btn-default btn-lg active'><i class='typcn typcn-user'></i> Users</a>
					<a ng-href='{{currentURL}}#Groups' class='btn btn-default btn-lg'><i class='typcn typcn-group'></i> Groups</a>
					<a ng-href='{{currentURL}}#Roles' class='btn btn-default btn-lg'><i class='ti ti-id-badge'></i> Roles</a>
				</div> <!--- /btn-group-v --->
			</div> <!--- /panel-body --->
		</div> <!--- /panel --->
	</div> <!--- /panel-group --->
</div> <!--- /3 --->
<ng-view></ng-view>
 


