const cssnext = require('postcss-cssnext');
const variables = require('./src/css-variables');

module.exports = {
  plugins: [
    require('postcss-lh'),
    cssnext({
      features: {
        customProperties: {
          variables,
        }
      }
    })
  ],
};
