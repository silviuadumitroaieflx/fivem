const fs = require('fs'); // Node.js file system module
const css = fs.readFileSync('dope.css', 'utf8'); // Replace 'dope.css' with the path to your CSS file
const outputFilePath = 'output_dope.css'; // Set the path for the output converted CSS file
const baseFontSize = 18.74; // Set your base font size
const viewportHeight = 1080; // Set your viewport total height
const viewportWidth = 1920; // Set your viewport total width

// Custom conversion function for units (vh, vw, px) to em
function convertToEm(match, value, unit) {
  if (unit === 'vh') {
    return ((value * viewportHeight) / 100) / baseFontSize + 'em';
  } else if (unit === 'vw') {
    return ((value * viewportWidth) / 100) / baseFontSize + 'em';
  } else if (unit === 'px') {
    return value / baseFontSize + 'em';
  }
  return match; // Leave other units as is
}

// Regular expression to match numeric values with vh, vw, or px units
const valueRegex = /(\d*\.?\d+)(vh|vw|px)/g;

// Replace numeric values with em values, keeping other units intact, except for the specified pattern
const emCss = css.replace(/^(?!--font-size: calc\(\(1vh\+1vw\)\/2\);).*/mg, line => {
  return line.replace(valueRegex, convertToEm);
});

// Write the converted CSS to the output file
fs.writeFileSync(outputFilePath, emCss);

console.log(`Conversion complete. Converted CSS saved to ${outputFilePath}`);