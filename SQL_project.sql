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

-- B. 建立使用者 (users)

INSERT INTO users (username, email, plan_id) VALUES 
('Jason_Wang', 'jason@scu.edu.tw', 2), -- Jason 用個人付費版
('Alice_Lin', 'alice@gmail.com', 1),   -- Alice 用免費版
('Bob_Chen', 'bob@yahoo.com', 3),      -- Bob 用家庭版
('David_Wu', 'david.wu@hotmail.com', 2),    -- David 付費個人
('Eva_Chang', 'eva_c@gmail.com', 1),        -- Eva 免費仔
('Frank_Liu', 'frank1999@scu.edu.tw', 1),   -- Frank 學生免費用戶
('Grace_Hsieh', 'grace.h@outlook.com', 3),  -- Grace 媽媽開家庭版
('Henry_Tsai', 'henry_t@yahoo.com.tw', 2),  -- Henry 付費個人
('Ivy_Kuo', 'ivy.kuo@gmail.com', 1),        -- Ivy 免費版
('Jacky_Chen', 'jacky_music@gmail.com', 2); -- Jacky 音樂狂熱者

-- C. 建立曲風
INSERT INTO genres (genre_name) VALUES ('Pop');  
INSERT INTO genres (genre_name) VALUES ('R&B');
INSERT INTO genres (genre_name) VALUES ('K-Pop');
INSERT INTO genres (genre_name) VALUES ('Rock');

-- D. 建立歌手

INSERT INTO artists (artist_name, country) VALUES 
('Jay Chou', 'Taiwan'),       -- 周杰倫
('Taylor Swift', 'USA'),      -- 泰勒絲
('BLACKPINK', 'South Korea'), -- BLACKPINK
('Ed Sheeran', 'UK'),         -- 紅髮艾德
('BTS', 'South Korea'),       -- 防彈少年團
('Mayday', 'Taiwan'),         -- 五月天
('Jolin Tsai', 'Taiwan'),     -- 蔡依林
('Justin Bieber', 'Canada'),  -- 小賈斯汀
('YOASOBI', 'Japan'),         -- YOASOBI
('Adele', 'UK');              -- 愛黛兒 

-- E. 建立專輯

INSERT INTO albums (album_title, release_date, artist_id) VALUES 
('Greatest Works of Art', '2022-07-15', 1), -- 周杰倫 (最偉大的作品)
('Midnights', '2022-10-21', 2),             -- Taylor Swift
('BORN PINK', '2022-09-16', 3),             -- BLACKPINK
('Equals', '2021-10-29', 4),                -- Ed Sheeran (紅髮艾德)
('Proof', '2022-06-10', 5),                 -- BTS (防彈少年團)
('History of Tomorrow', '2016-07-21', 6),   -- Mayday (五月天 - 自傳)
('Ugly Beauty', '2018-12-26', 7),           -- Jolin Tsai (蔡依林)
('Justice', '2021-03-19', 8),               -- Justin Bieber (小賈斯汀)
('THE BOOK', '2021-01-06', 9),              -- YOASOBI
('30', '2021-11-19', 10);                   -- Adele (愛黛兒)


-- F. 建立歌曲

INSERT INTO songs (title, duration_seconds, album_id, genre_id, play_count) VALUES 
('Mojito', 185, 1, 1, 50000),             -- 周杰倫 (Pop)
('Anti-Hero', 200, 2, 1, 85000),          -- Taylor Swift (Pop)
('Pink Venom', 186, 3, 3, 120000),        -- BLACKPINK (K-Pop)
('Bad Habits', 231, 4, 1, 95000),         -- Ed Sheeran (Pop)
('Yet To Come', 193, 5, 3, 110000),       -- BTS (K-Pop)
('Party Animal', 224, 6, 4, 60000),       -- 五月天 派對動物 (Rock)
('Ugly Beauty', 182, 7, 1, 45000),        -- 蔡依林 怪美的 (Pop)
('Peaches', 198, 8, 2, 78000),            -- Peaches (R&B)
('Yoru ni Kakeru', 261, 9, 1, 150000),    -- YOASOBI 向夜晚奔去 (Pop)
('Easy On Me', 224, 10, 2, 88000);        -- Adele (R&B/Soul)

-- G. 建立播放清單
INSERT INTO playlists (playlist_name, user_id) VALUES 
('Coding Music', 1),        -- ID 1 (Jason)
('Workout Mix', 2),         -- ID 2 (Alice)
('Family Road Trip', 3),    -- ID 3 (Bob)
('Deep Focus', 4),          -- ID 4 (David)
('Relaxing Jazz', 5),       -- ID 5 (Eva)
('Finals Week Study', 6),   -- ID 6 (Frank)
('90s Nostalgia', 7),       -- ID 7 (Grace)
('Rock Classics', 8),       -- ID 8 (Henry)
('Sunday Morning', 9),      -- ID 9 (Ivy)
('Gaming BGM', 10);         -- ID 10 (Jacky)

-- H. 把歌加入清單 (多對多關聯)
INSERT INTO playlist_songs (playlist_id, song_id) VALUES 
(1, 1), (1, 9),  -- Coding Music
(2, 3), (2, 6),  -- Workout Mix
(3, 1), (3, 4),  -- Family Road Trip
(4, 10),         -- Deep Focus
(6, 10),         -- Finals Week Study
(8, 6),          -- Rock Classics
(9, 8),          -- Sunday Morning
(10, 5), (10, 3);-- Gaming BGM


-- 用戶行為分析
SELECT 
    u.username AS 'User', 
    p.playlist_name AS 'Playlist', 
    s.title AS 'Song', 
    ar.artist_name AS 'Artist'
FROM users u
JOIN playlists p ON u.user_id = p.user_id
JOIN playlist_songs ps ON p.playlist_id = ps.playlist_id
JOIN songs s ON ps.song_id = s.song_id
JOIN albums al ON s.album_id = al.album_id     
JOIN artists ar ON al.artist_id = ar.artist_id  
WHERE u.username = 'Jason_Wang'                 
ORDER BY p.playlist_name;


-- 計算每位藝人的總播放量
SELECT 
    art.artist_name, 
    SUM(s.play_count) AS total_plays
FROM artists art
JOIN albums alb ON art.artist_id = alb.artist_id
JOIN songs s ON alb.album_id = s.album_id
GROUP BY art.artist_name
ORDER BY total_plays DESC;





