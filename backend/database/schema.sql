-- CREATE DATABASE IF NOT EXISTS geography_board_game_db;
-- USE geography_board_game_db;

CREATE TABLE IF NOT EXISTS Player (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    color ENUM('RED', 'BLUE', 'GREEN', 'YELLOW') NOT NULL
);

CREATE TABLE IF NOT EXISTS Game (
    id CHAR(36) PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Lobby (
    id CHAR(36) PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Game_Player (
    game_id CHAR(36),
    player_id CHAR(36),
    PRIMARY KEY (game_id, player_id),
    FOREIGN KEY (game_id) REFERENCES Game(id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES Player(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Lobby_Player (
    lobby_id CHAR(36),
    player_id CHAR(36),
    PRIMARY KEY (lobby_id, player_id),
    FOREIGN KEY (lobby_id) REFERENCES Lobby(id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES Player(id) ON DELETE CASCADE
);

CREATE TABLE Question (
    id INT AUTO_INCREMENT PRIMARY KEY,
    text TEXT NOT NULL,
    answer FLOAT NOT NULL
);

CREATE TABLE Action (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(255) NOT NULL
);
