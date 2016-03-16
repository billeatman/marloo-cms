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


	// create initial page
	process.createPageWithData(title="pagetest", info="draft0", parent_id=0, page_id=1, comment="created by ajaxPage_test.cfc");
	
	// create two drafts 
	process.savePage(title="pagetest", info="draft2", ID=1);
	process.savePage(title="pagetest", info="draft3", ID=1);

	describe("getLatestDraft", function() {
		it("asdf", function() {
			writeDump(variables.ajaxPage.getLatestDraft(page_id: 1));
		});
	});

	application.defaultTemplate = local.oldDefaultTemplate;
	application.datasource = local.oldDSN;
}

}