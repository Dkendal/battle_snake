# Changelog for BattleSnake v1.0

- App renamed from `:battle_snake_server` to `:battle_snake`
- `BattleSnakeServer` namespace folded into `BattleSnake`
- `Snake` and `Game` models renamed to `SnakeForm` and `GameForm` respectively
- Elixir version bumped to v1.4
- OTP version bumped to 19.0
- Client requests are now executed in parallel
- API requests will now timeout after 200ms.
If no request is received within 200ms a default ("up") move is recorded.
Similarly if any 'client' failure occurs a default move is chosen.
'client failure' includes malformed JSON resulting in parser errors, or the host going down.
- World.moves is no longer formless maps, replaced with [%BattleSnake.Move{}], which contains information about the response for the move.
This will include information about if the request timed out or resulted in an error.
