# Client API

## TL;DR

Competitors need to implement two webhooks, `POST /start` and `POST /move`, and their webserver must be on a routeable IP address.

## Overview
In BattleSnake, all games run on the BattleSnake game server, while all competitors' code runs on separate web servers. The game server communicates will competitors servers, here-in referred to as clients, by calling the agent's webhooks. These webhooks are called to find out if the agent is up, how the game server should display in on the board, and on each turn, where they would like to move.

Naturally, the game server can't be expected to wait forever for your client to respond, so all clients are expected to respond within __200ms__ (subject to change based on network quality day of the event). In the event that a client does not respond, a "random" move will be chosen for them, what move is chosen is _undefined_ so do not make any assumptions as to what it will be.

Clients are expected to respond to HTTP requests, serve from a routable IP address and provide a route for `POST /start` and `POST /move`.

The below image diagrams the basic structure of a game, and how clients and the game server interact. The game begins, the game server collects all players information, and then on each turn, it asks each player for their move.

<div class="mermaid">
sequenceDiagram
    participant G as Game Server
    participant P1 as Player 1
    participant P2 as Player 1
    G ->>+ G: Start game
    G ->> P1: POST /start
    P1 -->> G: {"name":"player 1"}
    G ->> P2: POST /start
    P2 -->> G: {"name":"player 2"}
    G -->>- G: Players are ready
    loop every turn
        G ->>+ G: Get players' moves
        G ->>+ P1: POST /move {"you": ...}
        P1 -->>- G: {"move":"up"}
        G ->>+ P2: POST /move {"you": ...}
        P2 -->>- G: {"move":"down"}
        G -->>- G: All players responded
        G ->> G: Run all game rules
    end
</div>

### Why HTTP?
While HTTP is not necessarily the best protocol for this sort of competition it tends to be the easiest thing to explain and get running for competitors that don't have prior experience with network programming or web development.

## POST /start Webhook
When the Game begins, the game server will issue a request to `POST /start` to each client competing in the game. This request lets the game server check if the host is up, and lets clients tell the game server how they should be displayed. If a client doesn't respond it will be dropped from the game.

> Game Server: Hey, I'm about to start the game, but I need to know I need your information first.

> Client: Hey, I'm here, my name is "ruby snake", and I'm red.

## POST /Move Webhook

Each turn the game server calls each clients' `POST /move` webhook to find out what action they wish to take on the next turn.

When the the game server calls this webhook it provides the current state of the game board, with the client's position and information, along with all other snakes' information, board dimensions and the location of food.

### The world object

```typescript
type Move = 'up' | 'down' | 'left' | 'right';
```

```typescript
interface World {
  object: 'world';
  id: number;
  you: Snake;
  snakes: List<Snake>;
  height: number;
  width: number;
  turn: number;
  food: List<Point>;
}

interface Snake {
  body: List<Point>;
  health: number;
  id: string;
  length: number;
  name: string;
  object: 'snake';
  taunt: string;
}

interface List<T> {
  object: 'list';
  data: T[];
}

interface Point {
  object: 'point';
  x: number;
  y: number;
}
```

## Example World JSON
```json
{
  "food": {
    "data": [
      {
        "object": "point",
        "x": 4,
        "y": 1
      }
    ],
    "object": "list"
  },
  "height": 6,
  "id": 3,
  "object": "world",
  "snakes": {
    "data": [
      {
        "body": {
          "data": [
            {
              "object": "point",
              "x": 4,
              "y": 3
            },
            {
              "object": "point",
              "x": 4,
              "y": 3
            },
            {
              "object": "point",
              "x": 4,
              "y": 3
            }
          ],
          "object": "list"
        },
        "health": 100,
        "id": "a47abbfc-b321-4828-ab90-669202dc0563",
        "length": 3,
        "name": "Typescript Snake",
        "object": "snake",
        "taunt": ""
      },
      {
        "body": {
          "data": [
            {
              "object": "point",
              "x": 3,
              "y": 2
            },
            {
              "object": "point",
              "x": 3,
              "y": 2
            },
            {
              "object": "point",
              "x": 3,
              "y": 2
            }
          ],
          "object": "list"
        },
        "health": 100,
        "id": "30f0a3fa-1d1b-462f-87cd-44ba8e18fb0e",
        "length": 3,
        "name": "Ruby Snake",
        "object": "snake",
        "taunt": ""
      }
    ],
    "object": "list"
  },
  "turn": 0,
  "width": 6,
  "you": {
    "body": {
      "data": [
        {
          "object": "point",
          "x": 4,
          "y": 3
        },
        {
          "object": "point",
          "x": 4,
          "y": 3
        },
        {
          "object": "point",
          "x": 4,
          "y": 3
        }
      ],
      "object": "list"
    },
    "health": 100,
    "id": "a47abbfc-b321-4828-ab90-669202dc0563",
    "length": 3,
    "name": "Typescript Snake",
    "object": "snake",
    "taunt": ""
  }
}
```
