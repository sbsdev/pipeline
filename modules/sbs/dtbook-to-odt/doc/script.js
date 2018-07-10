window.onload = function() {
	var wrapper = "<_ xmlns:text='urn:oasis:names:tc:opendocument:xmlns:text:1.0'"
	              + " xmlns:draw='urn:oasis:names:tc:opendocument:xmlns:drawing:1.0'"
	              + " xmlns:svg='urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0'"
	              + " xmlns:math='http://www.w3.org/1998/Math/MathML'>";
	var parser = new DOMParser();
	var srcBlocks = document.getElementsByClassName("src-odt");
	for (var i = 0, srcBlock; srcBlock = srcBlocks[i]; i++) {
		var odt = parser.parseFromString(
			wrapper
				+ srcBlock.textContent.replace(/\s[a-z]+:([a-z][-a-z]*=)/g, " $1")
				+ "</_>",
			"text/xml"
		).documentElement;
		srcBlock.parentNode.appendChild(odt);
	}
}
