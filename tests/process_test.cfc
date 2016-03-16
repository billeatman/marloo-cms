component displayName="Process.cfc Tests" extends="core.testcore" {

function setup() {
	variables.ajaxPage = new assets.ajax.ajaxPage();
	resetDatabase('LEOTEST');
	variables.process = new assets.ajax.process();
	$assert.typeOf( "component", variables.process);
}

function testObjectInit() {
	$assert.typeOf( "component", variables.ajaxPage);
}

function run() {
	local.oldDSN = application.datasource;
	application.datasource = "LEOTEST";
	local.oldDefaultTemplate = application.defaultTemplate;
	application.defaultTemplate = "leotest";

	setup();
	testObjectInit();

	describe("savePage", function() {
		it("Ensure saved drafts have unique modified dates", function() {
			//writeDump()

			// create initial page
			process.createPageWithData(title="pagetest", info="draft0", parent_id=0, page_id=1, comment="created by ajaxPage_test.cfc");

			// rapidly create 100 new drafts  
			for( local.i = 1; i < 1000; i++){
			//	process.savePage(title="pagetest", info="draft#i#", ID=1);
			}

			//local.qDrafts = new Query(datasource="LEOTEST").setSql("select distinct [modifieddate] from [mrl_pageRevision]").execute();

			//expect(local.qDrafts.getResult().recordcount).toBe(1001);
		});
	});
	
	application.defaultTemplate = local.oldDefaultTemplate;
	application.datasource = local.oldDSN;
}

}