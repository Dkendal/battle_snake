import {Configuration} from "webpack";

const webpack = require("webpack");
const {CheckerPlugin} = require("awesome-typescript-loader");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const path = require("path");

const relativePath = path.resolve.bind(path, __dirname);
const config: Configuration = {};

module.exports = config;

config.entry = {
  app: "./src/app.ts",
  index: "./src/index.ts",
  vendor: ["phoenix", "phoenix_html"],
};

config.output = {
  path: relativePath("../priv/static"),
  filename: "js/[name].js",
};

config.plugins = [
  new CheckerPlugin(),
  new webpack.HashedModuleIdsPlugin(),
  new webpack.optimize.CommonsChunkPlugin({
    name: "vendor",
  }),
  new webpack.optimize.CommonsChunkPlugin({
    name: "runtime",
  }),
  new CopyWebpackPlugin([{
    context: "static",
    from: "**/*",
  }]),
];

const tsRule = {
  test: /\.tsx?$/,
  loader: "awesome-typescript-loader",
  options: {
    useBabel: true,
    useCache: true,
    reportFiles: ["src/**/*.{ts,tsx}"],
  },
};

const cssRule = {
  test: /\.css$/,
  use: [
    {
      loader: "style-loader",
      options: {
        sourceMap: true,
      },
    },
    {
      loader: "css-loader",
      options: {
        sourceMap: true,
        importLoaders: 1,
      },
    },
    {
      loader: "postcss-loader",
    },
  ],
};

const elmRule = {
  test: /\.elm$/,
  exclude: [/elm-stuff/, /node_modules/],
  use: {
    loader: "elm-webpack-loader",
    options: {
      cwd: relativePath("elm"),
    },
  },
};

config.module = {
  rules: [tsRule, cssRule, elmRule],
};

config.resolve = {
  modules: ["node_modules", "src"],
  alias: {
    elm: relativePath("elm/src"),
  },
  extensions: [".js", ".jsx", ".ts", ".tsx", ".elm", ".json"],
};

config.devtool = "#source-map";
