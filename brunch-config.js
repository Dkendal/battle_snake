exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
        joinTo: {
          'js/app.js': /^(web\/static\/js)|(node_modules)/,
          'js/skin.js': /^(web\/static\/js)|(node_modules)/
        }
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: ["web/static/css/app.css"] // concat app.css last
      }
    },
    templates: {
      joinTo: "js/app.js",
      joinTo: "js/skin.js",
    }
  },

  conventions: {
    assets: /^(web\/static\/assets)/
  },

  paths: {
    watched: [
      "web/static",
      "test/static"
    ],

    public: "priv/static"
  },

  plugins: {
    sass: {
      mode: 'ruby',
      allowCache: true,
      sourceMapEmbeded: true,
    },
    babel: {
      presets: ['es2015', 'es2016'],
      ignore: [/web\/static\/vendor/]
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"],
      "js/skin.js": ["web/static/js/skin"],
    }
  }
};
