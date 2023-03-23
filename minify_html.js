const fs = require('fs');
const HTMLParser = require('node-html-parser');

const inputFile = process.argv[2];

const inputFileContent = fs.readFileSync(inputFile, 'utf8');

const regex = /(?:\t+|\r\n|\r|\n)+/g;

const dom = HTMLParser.parse(inputFileContent).removeWhitespace();
const output = dom.toString().replace(regex, ' ');

process.stdout.write(output);