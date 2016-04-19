<div class='col-md-2 sidebar sidebar-mrl'>
</div> <!-- /2 -->
<div class='col-md-8'>
	<div id='userman-nav'>
		<ul class='text-center nav nav-justified nav-pills' role='group' ng-controller='UsermanController as userman'>
			<li><a ng-href='{{currentURL}}#Users' class='btn btn-default'><i class='typcn typcn-user'></i>Users</a></li>
			<li><a ng-href='{{currentURL}}#Groups' class='btn btn-default'><i class='typcn typcn-group'></i>Groups</a></li>
			<li><a ng-href='{{currentURL}}#Roles' class='btn btn-default'><i class='typcn typcn-business-card'></i>Roles</a></li>
		</ul> <!--- /btn-group --->
	</div> <!--- /userman-nav --->
	<hr />
	<ng-view></ng-view>
</div> <!--- /8 --->
<div class='col-md-2 sidebar sidebar-mrl'>
</div> <!-- /2 -->

 


