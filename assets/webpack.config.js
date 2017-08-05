const path = require("path");
const relativePath = path.resolve.bind(path, __dirname);

const config = {};

module.exports = config;

config.entry = "./js/app.js";

config.output = {
  path: relativePath("../priv/static/js"),
  filename: "app.js"
};

config.module = {
  rules: [
    {
      test: /\.scss$/,
      use: [
        {
          loader: "style-loader",
          options: {
            sourceMap: true
          }
        },
        {
          loader: "css-loader",
          options: {
            sourceMap: true
          }
        },
        {
          loader: "sass-loader",
          options: {
            sourceMap: true
          }
        }
      ]
    }
  ]
};

config.resolve = {
  alias: {
    css: relativePath('css'),
  }
}

config.devtool = "#source-map";
