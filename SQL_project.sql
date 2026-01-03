-- 重置資料庫 (避免重複錯誤)
DROP DATABASE IF EXISTS music_stream_app;
CREATE DATABASE music_stream_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE music_stream_app;

-- 1. 建立訂閱方案 (Plans) - [Entity 1]
CREATE TABLE plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL, -- 例如: Free, Premium, Family
    price DECIMAL(10, 2) NOT NULL   -- 例如: 0, 149, 249
);

-- 2. 建立使用者 (Users) - [Entity 2]
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    plan_id INT, -- FK: 關聯到方案表
    register_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

-- 3. 建立音樂曲風 (Genres) - [Entity 3]
CREATE TABLE genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL UNIQUE -- 例如: Pop, Rock, K-Pop
);

-- 4. 建立歌手/藝人 (Artists) - [Entity 4]
CREATE TABLE artists (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(100) NOT NULL,
    country VARCHAR(50)
);

-- 5. 建立專輯 (Albums) - [Entity 5]
CREATE TABLE albums (
    album_id INT AUTO_INCREMENT PRIMARY KEY,
    album_title VARCHAR(150) NOT NULL,
    release_date DATE,
    artist_id INT, -- FK: 誰發行的
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

-- 6. 建立歌曲 (Songs) - [Entity 6]
CREATE TABLE songs (
    song_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    duration_seconds INT, -- 歌曲長度(秒)
    album_id INT,         -- FK: 收錄在哪張專輯
    genre_id INT,         -- FK: 什麼曲風
    play_count BIGINT DEFAULT 0, -- 播放次數 (這也是 Spotify 的核心數據)
    FOREIGN KEY (album_id) REFERENCES albums(album_id),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

-- 7. 建立播放清單 (Playlists) - [Entity 7]
CREATE TABLE playlists (
    playlist_id INT AUTO_INCREMENT PRIMARY KEY,
    playlist_name VARCHAR(100) NOT NULL,
    user_id INT, -- FK: 誰建立的
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 8. 播放清單與歌曲的關聯表 (Playlist_Songs) - [Entity 8: 多對多中間表]
CREATE TABLE playlist_songs (
    playlist_id INT,
    song_id INT,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, song_id), -- 複合主鍵
    FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id),
    FOREIGN KEY (song_id) REFERENCES songs(song_id)
);

-- A. 建立方案
INSERT INTO plans (plan_name, price) VALUES 
('Free', 0), 
('Premium Individual', 149), 
('Premium Family', 269);

-- B. 建立使用者
INSERT INTO users (username, email, plan_id) VALUES 
('Jason_Wang', 'jason@scu.edu.tw', 2), -- Jason 用個人付費版
('Alice_Lin', 'alice@gmail.com', 1),   -- Alice 用免費版
('Bob_Chen', 'bob@yahoo.com', 3);      -- Bob 用家庭版

-- C. 建立曲風
INSERT INTO genres (genre_name) VALUES ('Pop'), ('R&B'), ('K-Pop'), ('Rock');

-- D. 建立歌手
INSERT INTO artists (artist_name, country) VALUES 
('Jay Chou', 'Taiwan'), 
('Taylor Swift', 'USA'), 
('BLACKPINK', 'South Korea');

-- E. 建立專輯
INSERT INTO albums (album_title, release_date, artist_id) VALUES 
('Greatest Works of Art', '2022-07-15', 1), -- 周杰倫
('Midnights', '2022-10-21', 2),             -- Taylor Swift
('BORN PINK', '2022-09-16', 3);             -- BLACKPINK

-- F. 建立歌曲 (最核心的資料)
INSERT INTO songs (title, duration_seconds, album_id, genre_id, play_count) VALUES 
('Mojito', 185, 1, 1, 50000),             -- 周杰倫 / Pop
('Anti-Hero', 200, 2, 1, 85000),          -- Taylor / Pop
('Pink Venom', 186, 3, 3, 120000),        -- BLACKPINK / K-Pop
('Still Wandering', 245, 1, 2, 3000);     -- 周杰倫 / R&B

-- G. 建立播放清單
INSERT INTO playlists (playlist_name, user_id) VALUES 
('Coding Music', 1),      -- Jason 的清單
('Workout Mix', 2);       -- Alice 的清單

-- H. 把歌加入清單 (多對多關聯)
INSERT INTO playlist_songs (playlist_id, song_id) VALUES 
(1, 1), (1, 2), -- Jason 的清單有 Mojito 和 Anti-Hero
(2, 3);         -- Alice 的清單有 Pink Venom

SELECT 
    u.username, 
    p.playlist_name, 
    s.title AS song_title, 
    a.artist_name
FROM users u
JOIN playlists p ON u.user_id = p.user_id
JOIN playlist_songs ps ON p.playlist_id = ps.playlist_id
JOIN songs s ON ps.song_id = s.song_id
JOIN artists a ON s.artist_id = a.artist_id
WHERE u.username = 'Jason_Wang';

SELECT 
    pl.plan_name, 
    COUNT(u.user_id) AS user_count, 
    SUM(pl.price) AS total_revenue
FROM plans pl
LEFT JOIN users u ON pl.plan_id = u.plan_id
GROUP BY pl.plan_name;

SELECT title, artist_name, play_count
FROM songs s
JOIN artists a ON s.artist_id = a.artist_id
ORDER BY play_count DESC
LIMIT 1;

UPDATE users 
SET plan_id = 2 -- 改成 Premium Individual
WHERE username = 'Alice_Lin';