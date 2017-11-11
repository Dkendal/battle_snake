import {Configuration} from "webpack";

const webpack = require("webpack");
const {CheckerPlugin} = require("awesome-typescript-loader");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const {BundleAnalyzerPlugin} = require("webpack-bundle-analyzer");
const path = require("path");

const relativePath = path.resolve.bind(path, __dirname);
const config: Configuration = {};

module.exports = config;

config.entry = {
  game: "./src/app/Game.ts",
  test: "./src/app/Test.ts",
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
  new CopyWebpackPlugin([
    {
      context: "static",
      from: "**/*",
    },
  ]),
  new BundleAnalyzerPlugin({
    openAnalyzer: false,
  }),
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

const jsRule = {
  test: /\.jsx?$/,
  exclude: /(node_modules|bower_components)/,
  use: {
    loader: "babel-loader",
    options: {
      plugins: [
        [
          "@babel/transform-async-to-generator",
          {
            module: "bluebird",
            method: "coroutine",
          },
        ],
      ],
    },
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
  rules: [jsRule, tsRule, cssRule, elmRule],
};

config.resolve = {
  modules: ["node_modules", "src"],
  alias: {
    elm: relativePath("elm/src"),
  },
  extensions: [".js", ".jsx", ".ts", ".tsx", ".elm", ".json"],
};

config.devtool = "#source-map";
