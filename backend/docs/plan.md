# Game storage plan

## Database (on the server)

### Initial plan

Tables:

1. Player

   - ID (String - uuid)
   - Color (Enum)
   - Name (String)

2. Game

   - ID (String - uuid)
   - Players (array of Player)
   - Scores (array of objects with player id and score)
   - Actions (array of objects with player id and available actions)
   - Blocks (array of objects with player id and number of blocks received)

3. Question

   - Text (String)
   - Answer (Number)

4. Action

   - Type (String)

### New plan

**MySql DB on the machine**

Tables:

1. Player

   - ID (String - uuid)
   - Color (Enum)
   - Name (String)

2. Game

   - ID (String - uuid)

3. Game_Player

   - Game ID (FOREIGN KEY)
   - Player ID (FOREIGN KEY)
   - game_id, player_id (PRIMARY KEY)

4. Question

   - Text (String)
   - Answer (Number)

5. Action

   - Type (Enum)
   - Description (String)

6. Lobby

   - ID (String - uuid)

7. Lobby_Player

   - Lobby ID (FOREIGN KEY)
   - Player ID (FOREIGN KEY)
   - lobby_id, player_id (PRIMARY KEY)

**Redis (on the machine)**

| Data            | Stored in                                                     |
| --------------- | ------------------------------------------------------------- |
| Scores          | Redis (game:{gameId}:scores → {playerId: score})              |
| Actions         | Redis (game:{gameId}:actions → {playerId: available_actions}) |
| Blocks Received | Redis (game:{gameId}:blocks → {playerId: num_blocks})         |
