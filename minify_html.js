import { parse } from 'npm:node-html-parser';

const inputFile = Deno.args[0];

const inputFileContent = Deno.readTextFileSync(inputFile);

const regex = /(?:\s|\r\n|\r|\n)+/g;

const dom = parse(inputFileContent).removeWhitespace();
const output = dom.toString().replaceAll('\t', '').replace(regex, ' ');

console.log(output);