/* Explodey Battlesnake skin
 * Noel Burton-Krahn <noel@burton-krahn.com>
 */
import $ from "jquery";
import * as THREE from "three";
import * as TWEEN from "tween.js";
import { Howler, Howl } from 'howler';
import Vue from 'vue/dist/vue.js';

var SNAKE_HEAD_URL = "/images/snake_head_nerdy.png";
var SNAKE_HEAD_SCALE = 1.5;
var FOOD_URL = "/images/food.png"
var AUDIO_URL = "/audio/"
var AUDIO_PLAYLISTS_URL = AUDIO_URL + "playlists.json"

function audio_url(url) {
    if( url[0] == '.' ) {
        url = AUDIO_URL + url;
    }
    return url;
}

function audio_list(list, preload) {
    var audios = [];
    for(var i=0; i<list.length; i++) {
        var play_entry = list[i];
        var player;
        if( preload ) {
            player = new Howl({src: [audio_url(play_entry.url)],
                               format: [play_entry.format || "mp3"]});
        }
        audios.push({player: player, playlist: list[i]});
    }
    return audios;
}

function choose(list) {
    var i = Math.floor(Math.random() * list.length);
    if( i >= list.length ) {
        i = list.length;
    }
    return list[i];
}

var effects_playlist = {};
var effects_volume = 0.5;
function set_effects_volume(val) {
    effects_volume = val;
}
var effects_on = true;
function set_effects_on(val) {
    effects_on = val;
    $('#effects-on').prop('checked', effects_on);
}
function play_effects(name) {
    if( effects_on && effects_playlist ) {
        var player = choose(effects_playlist[name]);
        var volume = effects_volume * (player.playlist.volume || 1);
        player.player.play();
        player.player.volume(volume);
    }
}

var music_playlist = {};
var music_volume = 0.2;
var music_theme;
var music_player;
var music_on = false;
function set_music_volume(val) {
    music_volume = val;
    if( music_player ) {
        var volume = music_volume * (music_player.volume || 1);
        music_player.player.volume(volume);
    }
}
function set_music_on(val) {
    music_on = val;
    play_music();
}
function play_music(theme, continue_theme) {
    if( continue_theme && theme == music_theme ) {
        return;
    }
    
    if( theme ) {
        music_theme = theme;
    }
    
    if( music_playlist && music_theme ) {
        var old_player = music_player;
        if( old_player && old_player.player ) {
            old_player.player.off('end');
            old_player.player.stop();
        }
        if( music_on ) {
            music_player = choose(music_playlist[music_theme]);
            var volume = music_volume * (music_player.volume || 1);
            if( !music_player.player ) {
                music_player.player = new Howl({
                    src: [audio_url(music_player.playlist.url)],
                    format: [music_player.playlist.format || "mp3"],
                    volume: volume,
                    onend: function() {
                        play_music(music_theme);
                    },
                    loaderror: function(id, msg) {
                        console.error("play_music loaderror msg=" + msg);
                        play_music(music_theme);
                    }
                });
            }
            music_player.player.play();
            music_player.player.volume(volume);
        }
    }
}

function SnakeInfoDiv(div_id, data) {
    // render snake info into a div using Vue
    var self = this;
    self.div_id = div_id;
    var vue = null;

    function init() {
        var template = $('#snake-info-template');
        var div = template.clone().prop('id', self.div_id);
        template.parent().append(div);
        div.show();
        self.data = {
            'name': null,
            'taunt': null,
            'health': null,
            'color': null,
            'img': SNAKE_HEAD_URL,
            'killed': null,
            'turns': null
        }

        vue = new Vue({
            el: '#' + self.div_id,
            data: self.data
        });

        if( data ) {
            self.set_data(data);
        }
    }

    self.div = function(child) {
        var selector = '#' + self.div_id
        if( child ) {
            selector += ' ' + child;
        }
        return $(selector);
    }

    self.set_data = function(data) {
        for(var key in self.data ) {
            if( key in data ) {
                self.data[key] = data[key];
            }
        }
    }

    self.remove = function() {
        self.div().remove();
    }

    init(data);
}

function getRealCssColor(el, css_prop) {
    if( css_prop == undefined ) {
        'background-color'
    }
    return el.parents().filter(function() {
        var color = $(this).css(css_prop);
        if(color != 'transparent' && color != 'rgba(0, 0, 0, 0)' && color != undefined) {
            return color;
        }
    }).css(css_prop);
}

function stringToColor(str) {
    // when you can't pick a color, hash a string
    var hash = 0;
    for (var i = 0; i < str.length; i++) {
        hash = str.charCodeAt(i) + ((hash << 5) - hash);
    }
    var color = '#';
    for (var i = 0; i < 3; i++) {
        var value = (hash >> (i * 8)) & 0xFF;
        color += ('00' + value.toString(16)).substr(-2);
    }
    return color;
}

function hex2rgba(hex, opacity) {
    // utility to make hex color transparent
    hex = hex.replace('#','');
    var r = parseInt(hex.substring(0,2), 16);
    var g = parseInt(hex.substring(2,4), 16);
    var b = parseInt(hex.substring(4,6), 16);

    var result = 'rgba('+r+','+g+','+b+','+opacity/100+')';
    return result;
}

function interpolateWithArcs(pts) {
    /*
      return a function(t) that interpolates pts with straight lines and arcs, 0<=t<=1
    */

    var EPSILON = 1e-6; // Number.EPSILON is too small for roundoff errors
    
    function interp_arc(pt0, pt1, pt2) {
        // return a function(t) that interpolates from the
        // midpoints m0 and m1 between pt0,pt1 and p1,pt2 with a
        // straight line or arc
        var c =  (new THREE.Vector3()).addVectors(pt0, pt2).multiplyScalar(0.5);
        var m0 = (new THREE.Vector3()).addVectors(pt0, pt1).multiplyScalar(0.5);
        var m1 = (new THREE.Vector3()).addVectors(pt1, pt2).multiplyScalar(0.5);
        if( c.distanceTo(pt1) < EPSILON ) {
            // m0, m1, and c are colinear, interpolate a line
            var v = new THREE.Vector3();
            return function(t) {
                return v.copy(m0).lerp(m1, t);
            }
        }
        else {
            // m0, m1, and c are not colinear, so interpolate an arc
            m0.sub(c);
            m1.sub(c);
            var angle = m0.angleTo(m1);
            var cross = (new THREE.Vector3()).crossVectors(m0, m1).normalize();
            // correct angleTo's sign so applyAxisAngle(cross, angle) == m1
            var err;
            err = (new THREE.Vector3()).copy(m0).applyAxisAngle(cross, angle).distanceTo(m1);
            if( Math.abs(err) > EPSILON ) {
                angle *= -1;
            }
            // assertion: m0.applyAxisAngle(cross, angle) == m1
            err = (new THREE.Vector3()).copy(m0).applyAxisAngle(cross, angle).distanceTo(m1);
            if( Math.abs(err) > EPSILON ) {
                console.error("ERROR: m0=" + m0 + " can't rotate to m1=" + m1 + " angle=" + angle + " error=" + err);
            }

            var v = new THREE.Vector3();
            return function(t) {
                return v.copy(m0).applyAxisAngle(cross, t*angle).add(c);
            }
        }
    }

    if( pts.length < 2 ) {
        var f = function(t) { return pts[0]; }
        return f;
    }

    var interp_funcs = []
    for(var i=1; i+1<pts.length; i++) {
        // make interpolating functions for 0.5 <= t * N < N-0.5
        interp_funcs.push(interp_arc(
            pts[i-1],
            pts[i],
            pts[i+1]
        ));
    }

    return function(t) {
        t = t * (pts.length - 1);
        if( t < 0.5 ) {
            return pts[0].clone().lerp(pts[1], t);
        }
        else if( t < pts.length - 1 - 0.5 ) {
            t -= 0.5;
            var i = Math.floor(t);
            return interp_funcs[i](t - i);
        }
        else {
            t -= pts.length - 1 - 0.5;
            var m1 = pts[pts.length-1].clone().add(pts[pts.length-2]).multiplyScalar(0.5);
            return m1.clone().lerp(pts[pts.length - 1], t*2);
        }
    }
}

/*
 * memoize.js
 * by @philogb and @addyosmani
 * with further optimizations by @mathias
 * and @DmitryBaranovsk
 * perf tests: http://bit.ly/q3zpG3
 * Released under an MIT license.
 */
function memoize(fn) {
    return function () {
        var args = Array.prototype.slice.call(arguments)
        var hash = "";
        var i = args.length;
        var currentArg = null;
        while (i--) {
            currentArg = args[i];
            hash += (currentArg === Object(currentArg)) ?
                JSON.stringify(currentArg) : currentArg;
            fn.memoize || (fn.memoize = {});
        }
        return (hash in fn.memoize) ? fn.memoize[hash] :
            fn.memoize[hash] = fn.apply(this, args);
    };
}

var texture_cache = {};
var load_texture = function(url, callback) {
    var tex = texture_cache[url];
    if( tex ) {
        if( callback ) {
            callback(tex);
        }
        return tex;
    }
    
    var loader = new THREE.TextureLoader();
    loader.crossOrigin = '';
    var tex = loader.load(url
                          ,function(tex) {
                              tex.minFilter = THREE.LinearFilter;
                              texture_cache[url] = tex;
                              if( callback ) {
                                  callback(tex);
                              }
                          }
                          ,function(xhr) {}
                          ,function(xhr) {
                              if( url != SNAKE_HEAD_URL ) {
                                  tex = loader.load(SNAKE_HEAD_URL);
                                  tex.minFilter = THREE.LinearFilter;
                                  texture_cache[url] = tex;
                                  if( callback ) {
                                      callback(tex);
                                  }
                              }
                          });
    tex.minFilter = THREE.LinearFilter;
    return tex;
};

var radialCanvas = memoize(function(width, height, stops) {
    var canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    var context = canvas.getContext('2d');
    var gradient = context.createRadialGradient(width/2, height/2, 0, width/2, height/2, width/2);
    for(var i=0; i<stops.length; i+=2) {
        gradient.addColorStop(stops[i], stops[i+1]);
    }
    context.fillStyle = gradient;
    context.fillRect( 0, 0, canvas.width, canvas.height );
    return canvas;
});

function radialMaterial(width, height, stops) {
    return new THREE.SpriteMaterial({
        map: new THREE.CanvasTexture(radialCanvas(width, height, stops))
    });
}

function snakeBodyMaterial(color) {
    var mat = radialMaterial(32, 32, [
        0.0, color
        ,0.6, color
        ,0.95, '#000000'
        ,1, hex2rgba('#000000', 0)
    ]);
    return mat;
}

function explodeMaterial() {
    var mat = radialMaterial(16, 16, [
        0, 'rgba(255,255,0,1)',
        1, 'rgba(255,0,0,0)'
    ]);
    mat.blending = THREE.AdditiveBlending;
    return mat;
}

function foodMaterial() {
    var mat = radialMaterial(16, 16, [
        0, 'rgba(0,255,0,1)',
        1, 'rgba(0,255,0,0)'
    ]);
    mat.blending = THREE.AdditiveBlending;
    return mat;
}


// render a snake as an array of particles.  Explode the snake when it dies
function SnakeRenderer(board_renderer) {
    var self = this;
    self.board_renderer = board_renderer;

    var body_particles = [];
    var body_material = null;
    var head_material = null;
    var head_particle = null;

    self.render = function(snake) {
        //console.time("SnakeRenderer.render");
        var color = snake.color;
        var body = snake.body;

        // body
        if( !body_material ) {
            body_material = snakeBodyMaterial(color);
        }
        var body_pts = [];
        for(var body_i=0; body_i<body.length; body_i++) {
            body_pts.push(
                self.board_renderer.board_point(body[body_i][0],
                                                body[body_i][1],
                                                self.board_renderer.cell_width));
        }

        var body_interp = interpolateWithArcs(body_pts);
        var NSUBS = 5;
        var n = (body.length * NSUBS);
        var body_particle_i = 0;
        for(var i=1; i<n; i++) {
            var particle;
            if( body_particle_i < body_particles.length ) {
                particle = body_particles[body_particle_i];
            }
            else {
                particle = new THREE.Sprite(body_material);
                body_particles.push(particle);
                self.board_renderer.board_node.add(particle);
            }
            body_particle_i++;

            // taper the body
            var pt = body_interp(i/(n-1));
            var scale = (1 - i/(n-1)) * 0.7 + 0.3;
            particle.position.copy(pt);
            particle.position.z *= scale;
            particle.scale.x = particle.scale.y = scale;
        }
        // remove any leftover body particles
        for(var i=body_particle_i; i<body_particles.length; i++) {
            var particle = body_particles[i];
            self.board_renderer.board_node.remove(particle);
        }
        if( body_particle_i < body_particles.length ) {
            body_particles.splice(body_particle_i);
        }

        // head
        var img = snake.img;
        if( !head_material ) {
            // TODO - reload material if head changes
            head_material = new THREE.SpriteMaterial({
            });
            load_texture(img, function(tex) {head_material.map = tex});
        }
        if( !head_particle ) {
            head_particle = new THREE.Sprite(head_material);
            head_particle.scale.set(SNAKE_HEAD_SCALE, SNAKE_HEAD_SCALE, 0);
            self.board_renderer.board_node.add(head_particle);
        }
        head_particle.position.copy(body_pts[0]);
        head_particle.position.z += 0.01;
        //console.timeEnd("SnakeRenderer.render");
    }

    self.explode = function() {
        var delay = 0;
        var dur = 750;
        var mag = 5;

        play_effects("explode");
        
        // explode particles
        var explode_material = explodeMaterial();
        new TWEEN.Tween(explode_material)
            .delay(delay)
            .to({opacity: .01}, dur)
            .start();
        for(var i=0; i<body_particles.length; i++) {
            var body_particle = body_particles[i];
            for(var j=0; j<3; j++) {
                var p0 = body_particle.position;
                var particle = new THREE.Sprite(explode_material);
                particle.position.copy(body_particle.position);
                particle.scale.x = particle.scale.y = Math.random()*4;
                new TWEEN.Tween(particle.position)
                    .delay(dur*i/body_particles.length)
                    .onStart((function(particle) {
                        return function() {
                            self.board_renderer.board_node.add(particle);
                        }
                    })(particle))
                    .to({x: p0.x + (Math.random() - 0.5) * mag,
                         y: p0.y + (Math.random() - 0.5) * mag,
                         z: p0.z + (Math.random()*mag/2)}, dur)
                    .start();
                new TWEEN.Tween(particle.scale)
                    .delay(delay)
                    .to({x: 0.01, y: 0.01}, dur)
                    .onComplete((function(particle) {
                        return function() {
                            self.board_renderer.board_node.remove(particle);
                        }
                    })(particle))
                    .start();
            }
        }

        // head flies into camera and fades out
        if( head_particle ) {
            var particle = head_particle;
            new TWEEN.Tween(particle.scale)
                .delay(0)
                .to({x: 20, y: 20}, dur)
                .onComplete((function(particle) {
                    return function() {
                        self.board_renderer.board_node.remove(particle);
                    }
                })(particle))
                .start();
            new TWEEN.Tween(head_material)
                .delay(delay)
                .to({opacity: .01}, dur)
                .start();
            head_particle = null;
        }

        // fade out body
        delay = dur;
        dur = 1250;
        mag = 20;

        new TWEEN.Tween(body_material)
            .delay(delay)
            .to({opacity: .01}, dur)
            .start();

        for(var i=0; i<body_particles.length; i++) {
            var particle = body_particles[i];
            new TWEEN.Tween(particle)
                .delay(delay)
                .to({}, dur)
                .onComplete((function(particle) {
                    return function() {
                        self.board_renderer.board_node.remove(particle);
                    }
                })(particle))
                .start();
        }
        body_particles = [];

        self.board_renderer.shake(dur);
    }

    self.remove = function() {
        // remove any leftover body particles
        for(var i=0; i<body_particles.length; i++) {
            var particle = body_particles[i];
            self.board_renderer.board_node.remove(particle);
        }
        body_particles = [];
    }
}

function FoodRenderer(board_renderer, food_pt) {
    var self = this;

    var material = new THREE.SpriteMaterial();
    load_texture(FOOD_URL, function(tex) { material.map = tex; });
    var sprite = new THREE.Sprite(material);
    board_renderer.board_node.add(sprite);
    sprite.position.copy(food_pt);

    self.explode = function() {
        play_effects("eat");

        var explode_material = foodMaterial();
        var mag = 5;
        var dur = 750;
        var delay = 0;
        for(var j=0; j<10; j++) {
            var p0 = sprite.position;

            // sparks from the food
            var particle = new THREE.Sprite(explode_material);
            particle.position.copy(sprite.position);
            particle.scale.x = particle.scale.y = Math.random()*2;
            board_renderer.board_node.add(particle);

            // particle flies away
            new TWEEN.Tween(particle.position)
                .delay(delay)
                .to({x: p0.x + (Math.random() - 0.5) * mag,
                     y: p0.y + (Math.random() - 0.5) * mag,
                     z: p0.z + (Math.random()*mag/2)}, dur)
                .start();

            // particle expands
            new TWEEN.Tween(particle.scale)
                .delay(delay)
                .to({x: 0.01, y: 0.01}, dur)
                .onComplete((function(particle) {
                    return function() {
                        board_renderer.board_node.remove(particle);
                    }
                })(particle))
                .start();
        }

        // fade out spark material
        new TWEEN.Tween(explode_material)
            .delay(delay)
            .to({opacity: .01}, dur)
            .onComplete(function() {
                //explode_material.map.dispose();
                explode_material.dispose();
            })
            .start();

        dur *= .5;

        // expand food
        new TWEEN.Tween(sprite.scale)
            .delay(delay)
            .to({x: 3, y: 3}, dur)
            .onComplete(function() {
                board_renderer.board_node.remove(sprite);
            })
            .start();

        // fade out food
        new TWEEN.Tween(material)
            .delay(delay)
            .to({opacity: .01}, dur)
            .onComplete(function() {
                //material.map.dispose();
                material.dispose();
            })
            .start();
    }

    self.dispose = function() {
        //material.map.dispose();
    }

}

function SnakeBoardRenderer(game_renderer) {
    // render the board, snakes, and snake_infos
    var self = this;
    self.game_renderer = game_renderer
    self.board_node = game_renderer.board_node; // the THREE.Object that I should attach child objects to
    self.board_size = game_renderer.board_size; // board size in scene units
    self.snake_info_div = game_renderer.snake_info_div;

    self.board = null;
    self.cell_width = null;

    var food_renderers = {};  // map from food_key() -> FoodRenderer
    var snake_renderers = {}; // map from id -> SnakeRenderer
    var snake_infos = {};     // map from id -> SnakeInfoDiv
    var grid_mesh = null;
    var board_info_vue = null;

    self.fixup_snake = function(snake) {
        if( !('board_id' in snake) ) {
            snake.board_id = snake.id;
        }
        if( !('img' in snake) ) {
            snake.img = snake.head_url || SNAKE_HEAD_URL;
        }
        if( !('color' in snake) || !snake.color ) {
            snake.color = stringToColor(snake.board_id);
        }
        if( !('body' in snake) ) {
            snake.body = snake.coords;
        }
        if( snake.cause_of_death ) {
            snake.taunt = snake.cause_of_death;
        }
    }
    
    self.fixup_snakes = function(snakes) {
        for(var i=0; i<snakes.length; i++) {
            self.fixup_snake(snakes[i]);
        }
    }
    
    // the center point of a board cell
    self.board_point = function(cell_x, cell_y, pt_z) {
        var pt_x = (cell_x + 0.5) * self.board_size / self.board.width - self.board_size / 2;
        var pt_y = self.board_size / 2 - (cell_y + 0.5) * self.board_size / self.board.height;
        return new THREE.Vector3(pt_x, pt_y, pt_z);
    }

    function layout_snake_info() {
        //console.time("layout_snake_info");

        // sort into living and dead
        var snake_info_killed = [];
        var snake_info_living = [];
        for(var id in snake_infos) {
            var snake_info = snake_infos[id];
            if( snake_info.killed ) {
                snake_info_killed.push(snake_info);
            }
            else {
                snake_info_living.push(snake_info);
            }
        }

        var container = $('#snake-info-list');
        var pos = container.position();
        if( !pos ) {
            return;
        }
        pos.bottom = pos.top + container.innerHeight();
        var left = pos.left;

        // killed snakes go from bottom to top
        snake_info_killed.sort(function(a, b) { return a.data.turns - b.data.turns });
        var y = 0;
        function div_width(container, div) {
            return container.innerWidth()
                - parseFloat(div.css('padding-left')) - parseFloat(div.css('padding-right'))
                - parseFloat(div.css('border-left')) - parseFloat(div.css('border-right'))
                - parseFloat(div.css('margin-left')) - parseFloat(div.css('margin-right'))
            ;
        }

        for(var i=0; i<snake_info_killed.length; i++) {
            var div = snake_info_killed[i].div();
            var height = div.outerHeight(true);
            y += height;
            var top = pos.bottom - y;
            var width = div_width(container, div);
            div.animate({top: top, left: left, width: width}, 750);
        }

        // living snakes go from top to bottom
        snake_info_living.sort(function(a, b) { return a.order - b.order });
        y = 0;
        for(var i=0; i<snake_info_living.length; i++) {
            var div = snake_info_living[i].div();
            var height = div.outerHeight(true);
            var top = pos.top + y;
            var width = div_width(container, div);
            y += height;
            div.animate({top: top, left: left, width: width}, 750);
        }

        //console.timeEnd("layout_snake_info");
    }

    function get_snake_info(id, snake_i) {
        var snake_info = snake_infos[id];
        if( !snake_info ) {
            var snake_info_id = "snake-info-" + id;
            snake_info = new SnakeInfoDiv(snake_info_id);
            if( snake_i != null ) {
                snake_info.order = snake_i;
            }
            snake_infos[id] = snake_info;
        }
        return snake_info;
    }

    function food_key(food) {
        return '[' + food[0] + ',' + food[1] + ']';
    }

    self.render = function(board) {
        //console.time("SnakeBoardRenderer.render");

        // fixup board
        if( !('killed' in board) ) {
            board.killed = board.dead_snakes;
        }
        self.fixup_snakes(board.snakes);
        self.fixup_snakes(board.killed);

        self.board = board;
        self.cell_width = self.board_size / board.width / 2 * .9;

        // audio
        var music_theme;
        if( board.turn == 0 ) {
            music_theme = "prologue";
        }
        else if( board.end ) {
            music_theme = "epilogue";
        }
        else {
            music_theme = "fight";
        }
        play_music(music_theme, true);
        
        if( !board_info_vue ) {
            board_info_vue = new Vue({
                el: '#scoreboard-game-info',
                data: {
                    game_name: '',
                    game_turn: 0,
                }
            });
        }

        // board turns
        board_info_vue.$data.game_turn = board.turn;
        board_info_vue.$data.game_name = board.game_id;

        // grid
        if( !grid_mesh ) {
            var grid_material = new THREE.LineBasicMaterial({
                color: 0x888888,
                linewidth: 1
            });
            var dx = self.board_size / board.width;
            var x0 = -self.board_size / 2;
            var x1 = self.board_size / 2;
            var dy = self.board_size / board.width;
            var y0 = -self.board_size / 2;
            var y1 = self.board_size / 2;
            var grid_geometry = new THREE.Geometry();
            for(var x=0; x<=board.width; x++) {
                grid_geometry.vertices.push(new THREE.Vector3(x0 + x*dx, y0, 0),
                                            new THREE.Vector3(x0 + x*dx, y1, 0));
            }
            for(var y=0; y<=board.height; y++) {
                grid_geometry.vertices.push(new THREE.Vector3(x0, y0 + y*dy, 0),
                                            new THREE.Vector3(x1, y0 + y*dy, 0));
            }
            grid_mesh = new THREE.LineSegments(grid_geometry, grid_material);
            self.board_node.add(grid_mesh);

            var grid2_material = new THREE.LineBasicMaterial({
                color: 0x888888
                ,linewidth: 5
            });
            var grid2_geometry = new THREE.Geometry();
            grid2_geometry.vertices.push(
                new THREE.Vector3(x0, y0, 0)
                ,new THREE.Vector3(x0, y1, 0)
                ,new THREE.Vector3(x1, y1, 0)
                ,new THREE.Vector3(x1, y0, 0)
                ,new THREE.Vector3(x0, y0, 0));
            var grid2_mesh = new THREE.Line(grid2_geometry, grid2_material);
            self.board_node.add(grid2_mesh);
        }

        // food
        for(k in food_renderers) {
            food_renderers[k].keep = false;
        }
        for(var i=0; i<board.food.length; i++) {
            var food = board.food[i];
            var k = food_key(food);
            if( !(k in food_renderers) ) {
                var pt = self.board_point(food[0],
                                          food[1],
                                          self.cell_width);
                food_renderers[k] = new FoodRenderer(self, pt);
            }
            food_renderers[k].keep = true;
        }
        for(k in food_renderers) {
            if( !food_renderers[k].keep ) {
                food_renderers[k].explode();
                delete food_renderers[k];
            }
        }

        // mark all snakes as killed
        for(var id in snake_renderers) {
            if( snake_renderers[id] ) {
                snake_renderers[id].killed = true;
            }
        }

        // re-layout the snake_info blocks
        var snake_info_layout = false;

        if( board.turn == 0 ) {
            for(var id in snake_infos) {
                var snake_info = snake_infos[id];
                snake_info.remove();
            }
            snake_infos = {};
            snake_info_layout = true;
        }

        // render living snakes
        for(var snake_i=0; snake_i<board.snakes.length; snake_i++) {
            var snake = board.snakes[snake_i];

            var snake_renderer = snake_renderers[snake.id];
            if( !snake_renderer ) {
                snake_renderer = new SnakeRenderer(self);
                snake_renderers[snake.id] = snake_renderer;
                snake_info_layout = true;
            }
            snake_renderer.render(snake);
            snake_renderer.killed = false;

            var snake_info = get_snake_info(snake.id, snake_i);
            if( snake_info.killed ) {
                snake_info.killed = false;
                snake_info_layout = true;
            }
            snake_info.set_data(snake);
        }

        // update killed snake_infos
        if( board.killed ) {
            for(var snake_i=0; snake_i<board.killed.length; snake_i++) {
                var snake = board.killed[snake_i];
                var snake_info = get_snake_info(snake.id);
                if( !snake_info.killed ) {
                    snake_info.killed = true;
                    snake_info_layout = true;
                    snake_info.set_data(snake);
                }
            }
        }

        // explode killed snakes
        for(var id in snake_renderers) {
            var snake_renderer = snake_renderers[id];
            if( snake_renderer.killed ) {
                snake_renderer.explode();
                delete snake_renderers[id];

                var snake_info = snake_infos[id];
                if( snake_info ) {
                    snake_info.killed = true;
                    snake_info_layout = true;
                }
            }
        }

        // re-layout snake_infos
        if( snake_info_layout ) {
            layout_snake_info();
        }

        //console.timeEnd("SnakeBoardRenderer.render");
    }

    self.resize = function () {
        layout_snake_info();
    }

    self.shake = function(dur) {
        self.game_renderer.shake(dur);
    }

}

function GameRenderer(board_div, info_div) {
    // render a snake game in a container:  board in the center, info blocks on the right
    var self = this;
    self.board_div = $(board_div);
    self.info_div = $(info_div);

    var renderer;
    var camera;
    var scene;
    var clock;

    var board_node;
    var camera_pos = new THREE.Vector3(0, 0, 28);
    var camera_shake = null;
    var play_pause = 0;

    var board_renderer;

    // board size in renderer units
    self.board_size = 20;
    self.scene_size = self.board_size * 1.05;

    function update_camera(innerWidth, innerHeight) {
        var w, h;
        w = h = self.scene_size;
        if( innerWidth > innerHeight ) {
            w *= innerWidth / innerHeight;
        }
        else {
            h *= innerHeight / innerWidth;
        }
        if( !camera ) {
            camera = new THREE.OrthographicCamera(-w/2, w/2, h/2, -h/2, 0.1, 100);
        }
        else {
            camera.left   = -w / 2;
            camera.right  =  w / 2;
            camera.top    =  h / 2;
            camera.bottom = -h / 2;
            camera.updateProjectionMatrix();
        }
    }

    function render() {
        //console.time("render");
        TWEEN.update();

        if( camera_shake ) {
            camera.position.copy(camera_pos)
            camera.position.add(camera_shake);
        }
        renderer.render(scene, camera);

        requestAnimationFrame(render);
        //console.timeEnd("render");
    }

    self.resize = function() {
        if( camera && renderer ) {
            var innerWidth = self.board_div.innerWidth();
            var innerHeight = self.board_div.innerHeight();
            update_camera(innerWidth, innerHeight);
            renderer.setSize(innerWidth, innerHeight);
        }

        if( board_renderer ) {
            board_renderer.resize();
        }
    }

    self.render = function(board) {
        board_renderer.render(board);
    }

    self.shake = function(dur) {
        // shake the camera and pause the game
        new TWEEN.Tween({mag: 3})
            .to({mag: 0}, dur)
            .onUpdate(function() {
                camera_shake = new THREE.Vector3((Math.random()-0.5)*this.mag,
                                                 (Math.random()-0.5)*this.mag,
                                                 0); // Math.random()*self.mag);
            })
            .onComplete(function() {
                camera_shake = null;
            })
            .start();
    }

    function init() {
        // load audio playlists
        $.getJSON(AUDIO_PLAYLISTS_URL)
            .done(function(data) {
                for(var name in data.effects) {
                    effects_playlist[name] = audio_list(data.effects[name], true);
                }
                for(var theme in data.music) {
                    music_playlist[theme] = audio_list(data.music[theme], false);
                }
            })
            .fail(function(response, error) {
                console.error("failed to load: " + AUDIO_PLAYLISTS_URL + " error: " + error[2]);
            });

        // audio controls
        $("#effects-on").change(function() { set_effects_on($(this).is(':checked')) });
        $('#effects-on').prop('checked', effects_on);
        
        $("#effects-volume-slider")
            .val(effects_volume*100)
            .on('input', function() { set_effects_volume($(this).val()/100); });
        $('#music-on').prop('checked', music_on);
        $("#music-on").change(function() { set_music_on($(this).prop('checked')) })
        $("#music-volume-slider")
            .val(music_volume*100)
            .on('input', function() { set_music_volume($(this).val()/100); });
        $('.ui-slider-handle').show();

        clock = new THREE.Clock();
        scene = new THREE.Scene();

        var innerWidth = self.board_div.innerWidth();
        var innerHeight = self.board_div.innerHeight();

        update_camera(innerWidth, innerHeight)
        camera.position.copy(camera_pos);
        camera.lookAt(scene.position);

        renderer = new THREE.WebGLRenderer();
        renderer.setClearColor(getRealCssColor(self.board_div, "background-color"), 1.0);
        renderer.setSize(innerWidth, innerHeight);
        renderer.domElement.style.position = 'absolute';
        renderer.domElement.style.zIndex = 0;
        renderer.domElement.style.top = 0;
        renderer.domElement.style.bottom = 0;
        renderer.domElement.style.left = 0;
        renderer.domElement.style.right = 0;
        self.board_div.append(renderer.domElement);

        self.board_node = new THREE.Group();
        scene.add(self.board_node);
        board_renderer = new SnakeBoardRenderer(self);

        self.resize();
        render();
    }

    init();
}

export default GameRenderer;
