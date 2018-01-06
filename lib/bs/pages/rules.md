# Game Rules

BattleSnake is an adaptation of the classic video game "Snake", where the player maneuvers a snake around the game board to collect food pellets, which makes the snake grow longer. The main objective is to collect as much food as as possible while avoiding obstacles like walls and snakes' body.

In BattleSnake a number of snakes are pitted against each other and the last snake alive wins.

## Game Start
All snakes will start the game in a random location, and begin with a length of _three_ body segments. They initial start stacked, with all three segments on the same tile which will grow out of over the next three turns (see below examples).

## Avoid Walls

If a snake leaves the last tile of the board, they will die.

![](../assets/static/images/rule-wall.gif)

## Eat Food

Eating a food pellet will make snakes one segment longer. Snakes grow out of their tail: new tail segment will appear in the same square that the tail was in the previous turn.

Eating a food pellet will restore snakes' health-points to 💯.

The amount of food can vary from game to game, but within the same game it will always stay the same. As soon as a piece of food is eaten, it will respawn at a random, unoccupied location on the next turn.


![](../assets/static/images/rule-food.gif)

## Don't Starve

Every turn snakes will loose one health-point. In BattleSnake health-points serve like the snake's hunger bar, and if it reaches zero, the snake will starve and die. Eating food will restore snake's health to one-hundred points on the next turn.

![](../assets/static/images/rule-starvation.gif)

## Don't Collide with Snakes' Tails

If a snake collides with itself, it dies.

![](../assets/static/images/rule-self.gif)

## Head on Collisions

Head-to-head collisions follow different rules than the previously mentioned tail collisions.

In head-on collisions, the longer snake will survive.

![](../assets/static/images/rule-head-longer.gif)

But if both snakes are the same size, they both die. Note that in the below scenario, the food remains (collisions are resolved before food is eaten).

![](../assets/static/images/rule-head-same-size.gif)


