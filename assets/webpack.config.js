const path = require("path");
const relativePath = path.resolve.bind(path, __dirname);
const { CheckerPlugin } = require("awesome-typescript-loader");
const config = {};

module.exports = config;

config.entry = "./js/app.js";

config.output = {
  path: relativePath("../priv/static/js"),
  filename: "app.js"
};

const tsRule = {
  test: /\.tsx?$/,
  loader: "awesome-typescript-loader"
};

const scssRule = {
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
};

config.module = {
  rules: [tsRule, scssRule]
};

config.resolve = {
  alias: {
    css: relativePath("css")
  },
  extensions: [".css", ".js", ".json", ".scss", ".ts"]
};

config.devtool = "#source-map";

config.plugins = [new CheckerPlugin()];
