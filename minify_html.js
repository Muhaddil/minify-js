import { parse } from 'npm:node-html-parser';

const inputFile = Deno.args[0];

const inputFileContent = Deno.readTextFileSync(inputFile);

const regex = /(?:\t+|\r\n|\r|\n)+/g;

const dom = parse(inputFileContent).removeWhitespace();
const output = dom.toString().replace(regex, ' ');

console.log(output);