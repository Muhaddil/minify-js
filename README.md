# Minify-JS Action

Github action to minify HTML, Javascript and CSS files, using [html-minifier-terser](https://www.npmjs.com/package/html-minifier-terser), [minify](https://www.npmjs.com/package/minify) and [cssnano](https://www.npmjs.com/package/cssnano).

## Usage
First you need to check out your repository, then configure the Minify-JS job, at the end you can commit to your repository.  
Below is an example of how to do all of this.

```yaml
name: Minify Workflow
on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      # Checks-out your repository
      - uses: actions/checkout@v4

      # Job for Minify-JS
      - name: Minify-JS Action
        uses: Lenni009/minify-js@main
        with:
          directory: 'src/component.js' # (OPTIONAL)
          output: 'minify/src/' # (OPTIONAL)
          overwrite: true # (OPTIONAL)
          
      # Auto-commit to repository
      - uses: stefanzweifel/git-auto-commit-action@v4
        with:
          commit_message: 'Minify-JS : Commit Pipeline'
          branch: ${{ github.ref }}
```

## Changes in this Fork
This fork is adjusted to a very specific use case and style of writing web apps. It may not work for you or work in unexpected ways. All changes in this fork can be found below:
* CSS minification is done with the cssnano package
* Don't inline import statements in CSS files
* Add option to overwrite existing files instead of using separate `.min` files
* HTML files are minified with the html-minifier-terser package
* NodeJS version bumped from 14 to 16
