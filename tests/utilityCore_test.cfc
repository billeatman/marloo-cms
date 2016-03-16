component displayName="utilityCore Tests" extends="core.testcore" {

// executes before all tests
function beforeTests() {
}

// executes after all tests
function afterTests() {}

function setup() {
	variables.utilityCore = new assets.ajax.core.utilityCore();
}

function testObjectInit() {
	$assert.typeOf( "component", utilityCore);
}

function run() {
	setup();
	testObjectInit();

	describe("StringToSEOURL", function(){
		it("'at&t' -> 'att'", function() {
			expect(utilityCore.StringToSEOURL("at&t")).toBe("att");
		});

		it("'. ' to '-'", function() {
			expect(utilityCore.StringToSEOURL("hello. world")).toBe("hello-world");
		});

		it("' | ' to '-'", function() {
			expect(utilityCore.StringToSEOURL("hello | world")).toBe("hello-world");
		});

		it("' - ' to '-'", function() {
			expect(utilityCore.StringToSEOURL("hello - world")).toBe("hello-world");
		});

		it("'/' -> '-'", function() {
			expect(utilityCore.StringToSEOURL("hello/world")).toBe("hello-world");
		});

		it("'!' -> ''", function() {
			expect(utilityCore.StringToSEOURL("hello!world")).toBe("helloworld");
		});

		it("' ' -> '-'", function() {
			expect(utilityCore.StringToSEOURL("hello world")).toBe("hello-world");
		});

		it("'.' -> ''", function() {
			expect(utilityCore.StringToSEOURL("hello.world")).toBe("helloworld");
		});

		it("'#chr(39)#' -> ''", function() {
			expect(utilityCore.StringToSEOURL("hello#chr(39)#world")).toBe("helloworld");
		});

		it("'#chr(38)#' -> 'and'", function() {
			expect(utilityCore.StringToSEOURL("hello #chr(38)# world")).toBe("hello-and-world");
		});

		it("' #chr(38)# ' -> NOT ' and '", function() {
			expect(utilityCore.StringToSEOURL("hello #chr(38)# world")).notToBe("hello and world");
		});

		it ("'Hello World’s' -> 'hello-worlds'", function() {
			expect(utilityCore.StringToSEOURL("Hello World’s")).toBe("hello-worlds");
		});
		
		/* new tests 04/03/2015 */
		it ("“This is a quote.” -> 'This is a quote.'", function() {
			expect(utilityCore.StringToSEOURL("“This is a quote.”")).toBe("This-is-a-quote"); 	
		});

		it ("'_hello_world' -> 'hello-world'", function() {
			expect(utilityCore.StringToSEOURL("_hello_world")).toBe("hello-world");
		});

		it ("make sure last and beginning character are not '-'", function() {
			expect(utilityCore.StringToSEOURL("_hello_world")).notToBe("-hello-world");
		});
		
		it ("check whitelist", function() {
			local.allchars = "";
			for (local.i = 0;local.i < 256; local.i++){
	 			local.allchars &= chr(local.i);		
			}	
			expect(utilityCore.StringToSEOURL(local.allchars)).toBe("and--0123456789abcdefghijklmnopqrstuvwxyz-abcdefghijklmnopqrstuvwxyz");
		});

		it ("lower case string", function() {
			expect(utilityCore.StringToSEOURL("AbCdEf")).toBe("abcdef");
		});

		it ("trim string", function() {
			expect(utilityCore.StringToSEOURL(" Hello World")).toBe("hello-world");
		});

	});		
}

}

