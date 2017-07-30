exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
        joinTo: {
          'js/app.js': /^(js)|(node_modules)/,
          'js/skin.js': /^(js)|(node_modules)/
        }
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: ["css/app.css"] // concat app.css last
      }
    },
    templates: {
      joinTo: "js/app.js",
      joinTo: "js/skin.js",
    }
  },

  conventions: {
    assets: /^(assets)/
  },

  paths: {
    watched: ["static", "css", "js", "vendor"],

    public: "../priv/static"
  },

  plugins: {
    sass: {
      mode: 'ruby',
      allowCache: true,
      sourceMapEmbeded: true,
    },
    babel: {
      presets: ['es2015', 'es2016'],
      ignore: [/vendor/]
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["js/app"],
      "js/skin.js": ["js/skin"],
    }
  }
};
