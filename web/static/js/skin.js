// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".
import socket from "./socket"
import $ from "jquery";
import Mousetrap from "mousetrap";
import GameRenderer from "./snake";

const gameId = window.BattleSnake.gameId;
const logError = resp => { console.error("Unable to join", resp) };

var game_renderer;

const init = () => {
    const boardViewerChannel = socket.channel(`board_viewer:${gameId}`, {contentType: "json"});
    const gameAdminChannel = socket.channel(`game_admin:${gameId}`);

    game_renderer = new GameRenderer("#snake-board", "#snake-info-list");
    
    boardViewerChannel.on("tick", ({content}) => {
        console.time("skin.tick");
        //console.log("skin.js: tick content=" + content)
        try {
            var board = JSON.parse(content);

            // fixup snake data structure
            for(var i=0; i<board.snakes.length; i++) {
                var snake = board.snakes[i];
                snake.board_id = snake.id;
                snake.health = snake.health_points;
            }
        
            game_renderer.render(board);
        }
        catch(err) {
            console.error("error rendering content! err=" + err + " content=" + content);
        }
        console.timeEnd("skin.tick");
    });

    boardViewerChannel.
        join().
        receive("error", logError);

    gameAdminChannel.
        join().
        receive("error", logError);

    const cmd = (request) => {
        console.log("skin.js: cmd=" + request);
        gameAdminChannel.
            push(request).
            receive("error", e => console.error(`push "${request}" failed`, e));
    };

    Mousetrap.bind(["q"], () => cmd("stop"));
    Mousetrap.bind(["h", "left"], () => cmd("prev"));
    Mousetrap.bind(["j", "up"], () => cmd("resume"));
    Mousetrap.bind(["k", "down"], () => cmd("pause"));
    Mousetrap.bind(["l", "right"], () => cmd("next"));
    Mousetrap.bind("R", () => cmd("replay"));
}

function resize() {
    if( game_renderer ) {
        game_renderer.resize();
    }
}

console.log("skin.js: gameId=" + gameId)

if(typeof gameId !== "undefined") {
    $(init)

    // TODO: debounce? 
    $(window).on("resize", resize);
}

