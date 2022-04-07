# Nightwatch MMO Game Assignment

Release at: https://murmuring-beach-35202.herokuapp.com/game

### Stack used
- Phoenix
- Phoenix LiveView


### Points of concern

Supervision trees: [Application](lib/mmo_nightwatch/application.ex) and [GameSupervisor](lib/mmo_nightwatch/game_supervisor.ex)

Main Logic: [Board](lib/mmo_nightwatch/board.ex), [GameState](lib/mmo_nightwatch/game_state.ex), [HeroState](lib/mmonightwatch/hero_state.ex) and [LiveMonitor](lib/mmo_nightwatch/live_monitor.ex)

Tests: [BoardTest](test/board_test.exs) and [GameStateTest](test/game_state_test.exs)

### Launch instructions
```bash
mix phx.server
```
and head to
http://localhost:4000/game

Name of the hero can be chosen with url arguments like this
http://localhost:4000/game?name=wende

Controls with W A S D keys for movement and E key for attack