function getSiteTree(){

}
var defaultTreeData = [
	{
		text: 'Parent 1',
		href: '#parent1',
		icon: 'typcn typcn-home-outline',
		tags: ['4'],
		nodes: [
			{
				text: 'Child 1',
				href: '#child1',
				icon: 'typcn typcn-document',
				tags: ['2'],
				nodes: [
					{
						text: 'Grandchild 1',
						href: '#grandchild1',
						tags: ['0']
					},
					{
						text: 'Grandchild 2',
						href: '#grandchild2',
						tags: ['0']
					}
				]
			},
			{
				text: 'Child 2',
				href: '#child2',
				tags: ['0']
			}
		]
	},
	{
		text: 'Parent 2',
		href: '#parent2',
		tags: ['0']
	},
	{
		text: 'Parent 3',
		href: '#parent3',
		tags: ['0']
	},
	{
		text: 'Parent 4',
		href: '#parent4',
		tags: ['0']
	}
];

$('#site-tree').treeview({
	data: defaultTreeData,
	collapseIcon: 'fa fa-caret-up',
	expandIcon: 'fa fa-caret-right'
});



$(function() {
  $.contextMenu({
      selector: '.node-site-tree', 
      callback: function(key, options) {
          var m = "clicked: " + key;
          window.console && console.log(m) || alert(m); 
      },
      items: {
          "edit": {name: "Edit", icon: "edit"},
          "cut": {name: "Cut", icon: "cut"},
         copy: {name: "Copy", icon: "copy"},
          "paste": {name: "Paste", icon: "paste"},
          "delete": {name: "Delete", icon: "delete"},
          "sep1": "---------",
          "quit": {name: "Quit", icon: function(){
              return 'context-menu-icon context-menu-icon-quit';
          }}
      }
  });

  $('.node-site-tree').on('click', function(e){
      console.log('clicked', this);
  })    
});