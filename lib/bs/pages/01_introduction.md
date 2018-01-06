# Competitors' Guide

[[./bs-logo-dark.png]]

## Introduction
Like previous years, all competing clients are expected to provide a web
application that is available at a routeable URL.

Clients are expected to respond to HTTP requests and provide a route for [[#post-start][POST /start]] and [[#post-move][POST /move]].

All clients are expected to respond within 200ms of the server's initial
request. Failing to respond before the timemout may result in the server
choosing a random move for you.

All responses are expected to have a =200 OK= status code.

## Callbacks
### `POST /start`
Called when a new game is started.

Game IDs are guaranteed to be unique[fn:2].

The purpose of this callback is for clients to report what their snake's
name, colour, and other display properties should be for this game.

This callback should not be used to manage internal snake state it is not
guaranteed that as you will be notified when the game ends, or when your
snake dies.

All attributes the request are provided to maintain backwards compatibility
with 2015 snake clients - it is *strongly* recommend that clients exclusively
use the [[#post-move][move callback]] for any and all game play logic.

| *URL*     | /start                         |
| *Method*  | POST                           |
| *Headers* | Content-Type: application-json |

#### Request attributes
| Attribute | Type    |
|-----------|---------|
| *game_id* | UUID    |
| *height*  | integer |
| *width*   | integer |
|-----------|---------|
#### Example Request
```json
{
  "width": 20,
  "height": 20,
  "game_id": "b1dadee8-a112-4e0e-afa2-2845cd1f21aa"
}
```

#### Response Attributes
| Attribute         |            | Type     |                                                                                                                                |
|-------------------+------------+----------+--------------------------------------------------------------------------------------------------------------------------------|
| *color*           |            | [[#type-color][Color]]    | Primary color for your snake and avatar                                                                                        |
| *name*            |            | string   | Your snake's name.                                                                                                             |
| *head_url*        | /optional/ | url      | An image to be displayed as your avatar. Name is for compatibility with previous years. Avatars are displayed in a square box. |
| *taunt*           | /optional/ | string   | Message to display in the game client.                                                                                         |
| *head_type*       | /optional/ | [[#type-head-type][HeadType]] | String matching one of the snake heads listed [[#type-head-type][here]].                                                                            |
| *tail_type*       | /optional/ | [[#type-tail-type][TailType]] | String matching one of the snake tails listed [[#type-tail-type][here]].                                                                            |
| *secondary_color* | /optional/ | [[#type-color][Color]]    | Accent color used by some snake heads.                                                                                         |

#### Example Response
```json
{
  "color": "#FF0000",
  "secondary_color": "#00FF00",
  "head_url": "http://placecage.com/c/100/100",
  "name": "Cage Snake",
  "taunt": "OH GOD NOT THE BEES"
  "head_type": "pixel",
  "tail_type": "pixel"
}
```

#### Sample call
```sh
my_snake_server_url="localhost:4000/test-snake"

curl $my_snake_server_url/start \
       -X POST \
       -H "Content-Type: application/json" \
       --data @- <<-REQUEST_BODY
{"width":20,"height":20,"game_id":"example-game-id"}
REQUEST_BODY
```

```json
{"name":"test-snake","color":"#123123"}
```

### `POST /move`
The game server will issue a request for this callback on each turn to
request the client's move.

This callback should be used for all game logic.

| *URL*     | /start                         |
| *Method*  | POST                           |
| *Headers* | Content-Type: application-json |

#### Request Attributes
| Attribute    | Type         |                                                                            |
|--------------+--------------+----------------------------------------------------------------------------|
| <l>          | <l>          |                                                                            |
| *food*       | Array<[[#type-point][Point]]> | Array of all food currently on the board                                   |
| *game_id*    | UUID         |                                                                            |
| *height*     | integer      |                                                                            |
| *snakes*     | Array<[[#type-snake][Snake]]> | Array of all living snakes in the game                                     |
| *dead_snake* | Array<[[#type-snake][Snake]]> | Array of all dead snakes in the game                                       |
| *turn*       | integer      | The current turn.                                                          |
| *width*      | integer      |                                                                            |
| *you*        | UUID         | A reference to your snake's id, the snake object can be found in =snakes=. |
|--------------+--------------+----------------------------------------------------------------------------|

#### Example Request
```json
{
  "you": "2c4d4d70-8cca-48e0-ac9d-03ecafca0c98",
    "width": 2,
    "turn": 0,
    "snakes": [
    {
      "taunt": "git gud",
      "name": "my-snake",
      "id": "2c4d4d70-8cca-48e0-ac9d-03ecafca0c98",
      "health_points": 93,
      "coords": [
        [
          0,
      0
        ],
        [
          0,
        0
        ],
        [
          0,
        0
        ]
      ]
    },
    {
      "taunt": "gotta go fast",
      "name": "other-snake",
      "id": "c35dcf26-7f48-492c-b7b5-94ae78fbc713",
      "health_points": 50,
      "coords": [
        [
          1,
      0
        ],
        [
          1,
        0
        ],
        [
          1,
        0
        ]
      ]
    }
  ],
  "height": 2,
  "game_id": "a2facef2-b031-44ba-a36c-0859c389ef96",
  "food": [
    [
      1,
  1
    ]
  ],
  "dead_snakes": [
  {
    "taunt": "gotta go fast",
    "name": "other-snake",
    "id": "83fdf2b9-c8d0-44f4-acb2-0c506139079e",
    "health_points": 50,
    "coords": [
      [
        5,
    0
      ],
      [
        5,
      0
      ],
      [
        5,
      0
      ]
    ]
  }
  ]
}
```

####  Response Attributes

| Attribute |            | Type                                         |
|-----------+------------+----------------------------------------------|
| *move*    |            | "up" \vert "left" \vert "down" \vert "right" |
| *taunt*   | /optional/ | string                                       |
|-----------+------------+----------------------------------------------|

#### Example Response
- Code: =200 OK=
- Content:
```json
{
  "move": "up",
  "taunt": "gotta go fast"
}
```
#### Sample call
```sh
curl $my_snake_server_url/move \
       -X POST \
       -H "Content-Type: application/json" \
       --data @- <<-REQUEST_BODY
{{"you": {"name": "my-snake", "coords": [[0, 0], [0, 0], [0, 0]]}, "turn": 0, "snakes": [{"name": "my-snake", "coords": [[0, 0], [0, 0], [0, 0]]}], "game_id": 0, "food": [[0, 1]]}
REQUEST_BODY
```

```json
{"move":"right"}
```


#### Notes
Requests timeout after 200ms, failing to respond will result in the server
choosing a move for you.
### Simple Example Snake
Below is a simple example snake. This is what the bare minimum implementation
of a /functional/ snake might look like.

This example is written in Ruby, but you are of course not limited in what
technology you wish to use.

In the below example we create a basic Sinatra[fn:1] web application. The app
severs the two post callbacks, and provides a response containing only the
required attributes for both.

```ruby
# ./Gemfile
source "https://rubygems.org"
gem "sinatra", require: "sinatra/base"
gem "rack"

# ./ruby_snake.rb
require "json"

class RubySnake < Sinatra::Base
  post "/start" do
    {
      name: "simple-ruby-example-snake",
      color: "#123456"
    }.to_json
  end

  post "/move" do
    {
      move: "up"
    }.to_json
  end
end
```

This Snake only goes up, but it works!


## Data Types
### Point
A 2-dimensional vector.

```
x :: 0..infinity
y :: 0..infinity
Point :: [x, y]
```

```
[0, 1]
```

### Snake
| Attributes      |   | Type         |
|-----------------+---+--------------|
| *coords*        |   | Array<[[#type-point][Point]]> |
| *health_points* |   | 0..100       |
| *id*            |   | UUID         |
| *name*          |   | string       |
| *taunt*         |   | string       |

```json
{
  "taunt": "git gud",
    "name": "my-snake",
    "id": "5b079dcd-0494-4afd-a08e-72c9a7c2d983",
    "health_points": 93,
    "coords": [
      [0, 0],
      [0, 0],
      [0, 0]
    ]
}
```


`coords` is a complete list of a snakes head and body segments. The first
segment in `coords` is a snakes head.

When a snake moves its' head segment will move in the direction specified,
     and all it's tail segments will advance to space ocupied by the previous
     segment

     Eating food extends your snake's tail, and restores your health points.

     For example:

```json
     // before eating food
{
  "taunt": "git gud",
  "name": "my-snake",
  "id": "5b079dcd-0494-4afd-a08e-72c9a7c2d983",
  "health_points": 50,
  "coords": [
    [2, 0],
    [1, 0],
    [0, 0]
  ]
}
// moves right, (1, 0), into a space that occupies food (3, 0)
// the new state of the snake would be
{
  "taunt": "git gud",
    "name": "my-snake",
    "id": "5b079dcd-0494-4afd-a08e-72c9a7c2d983",
    "health_points": 100,
    "coords": [
      [3, 0],
      [2, 0],
      [1, 0],
      [1, 0]
    ]
}
// the tail has been extended by 1 and the health restored to 100
```

### Color
```
color :: hexcode | hsl | named_color | rbg
```

```
"gold"
```

```
"#ffffff"
```

```
"rgb(255, 255, 255)"
```

```
"hsl(255, 100%, 100%)"
```

### HeadType
A string matching one of the values listed below:
| Value         | Preview                                                      |
| ="bendr"=     | @@html:<img width="100px" src="./bendr-snakehead.png" />@@   |
| ="dead"=      | @@html:<img width="100px" src="./dead-snakehead.png" />@@    |
| ="fang"=      | @@html:<img width="100px" src="./fang-snakehead.png" />@@    |
| ="pixel"=     | @@html:<img width="100px" src="./pixel-snakehead.png" />@@   |
| ="regular"=   | @@html:<img width="100px" src="./regular-snakehead.png" />@@ |
| ="safe"=      | @@html:<img width="100px" src="./safe-snakehead.png" />@@    |
| ="sand-worm"= | @@html:<img width="100px" src="./sand-worm.png" />@@         |
| ="shades"=    | @@html:<img width="100px" src="./shades-snakehead.png" />@@  |
| ="smile"=     | @@html:<img width="100px" src="./smile-snakehead.png" />@@   |
| ="tongue"=    | @@html:<img width="100px" src="./tongue-snakehead.png" />@@  |

### TailType
:PROPERTIES:
:CUSTOM_ID: type-tail-type
:END:
A string matching one of the values listed below:
| Value            | Preview                                                           |
| ="small-rattle"= | @@html:<img width="100px" src="./small-rattle-snaketail.png" />@@ |
| ="skinny-tail"=  | @@html:<img width="100px" src="./skinny-tail-snaketail.png" />@@  |
| ="round-bum"=    | @@html:<img width="100px" src="./round-bum-snaketail.png" />@@    |
| ="regular"=      | @@html:<img width="100px" src="./pointed-snaketail.png" />@@      |
| ="pixel"=        | @@html:<img width="100px" src="./pixel-snaketail.png" />@@        |
| ="freckled"=     | @@html:<img width="100px" src="./freckled-snaketail.png" />@@     |
| ="fat-rattle"=   | @@html:<img width="100px" src="./fat-rattle-snaketail.png" />@@   |
| ="curled"=       | @@html:<img width="100px" src="./curled-snaketail.png" />@@       |
| ="block-bum"=    | @@html:<img width="100px" src="./block-bum-snaketail.png" />@@    |
## Game Rules
### Objective

BattleSnake is an adaptation of the classic video game "Snake", where the player
maneuvers a snake around the play field to collect food pellets, which makes
the snake grow longer. The main objective is to collect as much food as
as possible, while avoiding hitting obstacles, such as walls and most
importantly - your own snake.

In BattleSnake, each round X number of snakes is pitted against each other,
   and the goal is to be the last snake left alive at the end of the round.

### You lose if your snake...
   * Runs into another snake's body.
   * Runs into its own body.
   * Runs into the walls of the play field.
   * Collides head-to-head with a longer snake (both die if they are of the same size).
   * Starves.

### Starvation rules
   * Your snake starts out with 100 life and counts down by 1 each turn.
   * When your snake's life total reaches 0, it dies of starvation.

### Avoiding starvation
   * Food pellets spawn randomly around the play field.
   * Each food pellet increases your snake's length by 1 and resets its life to 100.

### Sportsmanship
   - No DDoSing your opponents.
   - No manual control of your snake.

## Footnotes

   [fn:2] https://en.wikipedia.org/wiki/Universally_unique_identifier#Collisions

   [fn:1] http://www.sinatrarb.com/intro.html
