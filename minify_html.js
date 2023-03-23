const fs = require('fs');
const { XMLParser, XMLBuilder } = require("fast-xml-parser");

const inputFile = process.argv[2];

const inputFileContent = fs.readFileSync(inputFile, 'utf8');

const parsingOptions = {
	ignoreAttributes: false,
	unpairedTags: ["hr", "br", "link", "meta"],
	stopNodes: ["*.pre", "*.script"],
	processEntities: true,
	htmlEntities: true
}

const parser = new XMLParser(parsingOptions);
const obj = parser.parse(inputFileContent);

const builderOptions = {
	ignoreAttributes: false,
	format: false,
	preserveOrder: true,
	suppressEmptyNode: false,
	unpairedTags: ["hr", "br", "link", "meta", "img", "input"],
	stopNodes: ["*.pre", "*.script"],
}

const builder = new XMLBuilder(builderOptions);
const output = builder.build(obj);

process.stdout.write(output);