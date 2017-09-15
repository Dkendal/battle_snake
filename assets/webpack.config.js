const path = require('path');
const relativePath = path.resolve.bind(path, __dirname);
const {CheckerPlugin} = require('awesome-typescript-loader');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const config = {};

module.exports = config;

config.entry = './src/app.ts';

config.output = {
  path: relativePath('../priv/static/js'),
  filename: 'app.js',
};

const tsRule = {
  test: /\.tsx?$/,
  loader: 'awesome-typescript-loader',
  options: {
    useBabel: true,
    useCache: true,
    reportFiles: [
      'src/**/*.{ts,tsx}',
    ],
  },
};

const cssRule = {
  test: /\.css$/,
  use: [
    {
      loader: 'style-loader',
      options: {
        sourceMap: true,
      },
    },
    {
      loader: 'css-loader',
      options: {
        sourceMap: true,
        importLoaders: 1,
      },
    },
    {
      loader: 'postcss-loader',
    },
  ],
};

const elmRule = {
  test: /\.elm$/,
  exclude: [/elm-stuff/, /node_modules/],
  use: {
    loader: 'elm-webpack-loader',
    options: {
      cwd: relativePath('elm'),
    },
  },
};

config.module = {
  rules: [tsRule, cssRule, elmRule],
};

config.resolve = {
  modules: ['node_modules', 'js'],
  alias: {
    elm: relativePath('elm/src'),
  },
  extensions: ['.js', '.json', '.ts', '.elm'],
};

config.devtool = '#source-map';

config.plugins = [
  new CheckerPlugin(),
  new CopyWebpackPlugin([{from: './static'}]),
];
