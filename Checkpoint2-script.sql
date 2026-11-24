-- ============================================================================
-- CSE 111 Fall 2026: Project Checkpoint 2 Script
-- Project Title: Airbuds Music Catalog Database
-- Team Members: [Andrew Li]
-- File: Checkpoint2-script.sql
-- ============================================================================
-- ============================================================================
-- SCHEMA MODIFICATIONS SINCE CHECKPOINT 1
-- ============================================================================
-- Modifications:
-- 1. The design was reduced to three entities (Artists, Albums, Songs) and one
--    junction table (ArtistContributions); Genres, Users, Playlists, and
--    PlaylistSongs were removed.
-- 2. Songs.genreID (foreign key to Genres) was replaced by a plain text
--    column Songs.genre, since Genres no longer exists as a table.
-- 3. A view, SongCatalog, is created in Statement 16 (no table changes).
-- ============================================================================
-- ============================================================================
-- MEMBER CONTRIBUTIONS SUMMARY (GROUPED AT THE TOP)
-- ============================================================================
-- Each statement sums to 100%. This project was completed by one team member.
--
-- SECTION 1: SIMPLE STATEMENTS
-- Statement 01: [Andrew Li]: 100%
-- Statement 02: [Andrew Li]: 100%
-- Statement 03: [Andrew Li]: 100%
-- Statement 04: [Andrew Li]: 100%
-- Statement 05: [Andrew Li]: 100%
-- Statement 06: [Andrew Li]: 100%
--
-- SECTION 2: INTERMEDIATE STATEMENTS
-- Statement 07: [Andrew Li]: 100%
-- Statement 08: [Andrew Li]: 100%
-- Statement 09: [Andrew Li]: 100%
-- Statement 10: [Andrew Li]: 100%
-- Statement 11: [Andrew Li]: 100%
--
-- SECTION 3: COMPLEX STATEMENTS
-- Statement 12: [Andrew Li]: 100%
-- Statement 13: [Andrew Li]: 100%
-- Statement 14: [Andrew Li]: 100%
-- Statement 15: [Andrew Li]: 100%
-- Statement 16: [Andrew Li]: 100%
-- Statement 17: [Andrew Li]: 100%
-- Statement 18: [Andrew Li]: 100%
-- ============================================================================
-- Ensure SQLite foreign key constraints are enforced
PRAGMA foreign_keys = ON;
-- Set output format for readability during evaluation
.headers on
.mode column
-- ============================================================================
-- SECTION 1: SIMPLE STATEMENTS
-- Focus: Single-table projections/filters, simple inserts/updates/deletes,
-- basic sorting, simple aggregate functions, and pattern matching.
-- ============================================================================
-- ----------------------------------------------------------------------------
-- Statement 01: Songs Longer Than 4 Minutes
-- Explanation: Lists songs longer than 4 minutes (240 seconds), longest first.
-- ----------------------------------------------------------------------------
SELECT title, genre, duration
FROM Songs
WHERE duration > 240
ORDER BY duration DESC;
-- ----------------------------------------------------------------------------
-- Statement 02: Artists Whose Names Start With "The"
-- Explanation: Uses pattern matching to find artists whose names start with
-- "The ".
-- ----------------------------------------------------------------------------
SELECT name, country
FROM Artists
WHERE name LIKE 'The %';
-- ----------------------------------------------------------------------------
-- Statement 03: Song Count and Duration Statistics
-- Explanation: Computes scalar aggregates over all songs: the count, average,
-- shortest, and longest duration.
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS totalSongs,
       ROUND(AVG(duration), 1) AS avgDurationSec,
       MIN(duration) AS shortestSec,
       MAX(duration) AS longestSec
FROM Songs;
-- ----------------------------------------------------------------------------
-- Statement 04: Insert a New Artist
-- Explanation: Inserts a new artist into the catalog.
-- ----------------------------------------------------------------------------
INSERT INTO Artists (artistID, name, country, debutYear)
VALUES (12, 'Nas', 'USA', 1994);
-- ----------------------------------------------------------------------------
-- Statement 05: Update the New Artist's Country
-- Explanation: Updates the country name of the newly inserted artist.
-- ----------------------------------------------------------------------------
UPDATE Artists
SET country = 'United States'
WHERE artistID = 12;
-- ----------------------------------------------------------------------------
-- Statement 06: Delete the New Artist
-- Explanation: Deletes the new artist, who has no albums or song credits yet.
-- ----------------------------------------------------------------------------
DELETE FROM Artists
WHERE artistID = 12;
-- ============================================================================
-- SECTION 2: INTERMEDIATE STATEMENTS
-- Focus: Multi-table inner joins, left outer joins, aggregation with GROUP BY
-- and HAVING, scalar subqueries, table aliasing, and conditional updates.
-- ============================================================================
-- ----------------------------------------------------------------------------
-- Statement 07: Songs With Their Album and Artist
-- Explanation: Joins Songs, Albums, and Artists to show each song with its
-- album and main artist.
-- ----------------------------------------------------------------------------
SELECT s.title AS song, al.title AS album, ar.name AS artist
FROM Songs s
JOIN Albums al ON s.albumID = al.albumID
JOIN Artists ar ON al.artistID = ar.artistID
ORDER BY ar.name, al.title, s.title;
-- ----------------------------------------------------------------------------
-- Statement 08: Album Count per Artist
-- Explanation: Uses a LEFT JOIN to count albums per artist, including artists
-- with no albums.
-- ----------------------------------------------------------------------------
SELECT a.name, COUNT(al.albumID) AS numAlbums
FROM Artists a
LEFT JOIN Albums al ON a.artistID = al.artistID
GROUP BY a.artistID, a.name
ORDER BY numAlbums DESC, a.name;
-- ----------------------------------------------------------------------------
-- Statement 09: Albums With 2 or More Songs
-- Explanation: Finds albums with 2 or more songs using GROUP BY and HAVING,
-- and reports each album's average song length.
-- ----------------------------------------------------------------------------
SELECT al.title AS album, COUNT(*) AS numSongs, ROUND(AVG(s.duration), 1) AS avgDurationSec
FROM Albums al
JOIN Songs s ON al.albumID = s.albumID
GROUP BY al.albumID, al.title
HAVING COUNT(*) >= 2
ORDER BY avgDurationSec DESC;
-- ----------------------------------------------------------------------------
-- Statement 10: Songs Longer Than the Average
-- Explanation: Uses a scalar subquery to list songs longer than the average
-- song duration.
-- ----------------------------------------------------------------------------
SELECT title, duration
FROM Songs
WHERE duration > (SELECT AVG(duration) FROM Songs)
ORDER BY duration DESC;
-- ----------------------------------------------------------------------------
-- Statement 11: Spell Out "UK" (Conditional Update)
-- Explanation: Conditional update that changes "UK" to "United Kingdom" for
-- every artist from the UK.
-- ----------------------------------------------------------------------------
UPDATE Artists
SET country = 'United Kingdom'
WHERE country = 'UK';
-- ============================================================================
-- SECTION 3: COMPLEX STATEMENTS
-- Focus: Correlated subqueries (EXISTS/NOT EXISTS), set operations
-- (UNION, INTERSECT, EXCEPT), Common Table Expressions (WITH / CTEs),
-- window functions (ROW_NUMBER, DENSE_RANK), VIEW creation/querying,
-- multi-condition triggers, and complex analytics.
-- ============================================================================
-- ----------------------------------------------------------------------------
-- Statement 12: Artists With No Albums (NOT EXISTS)
-- Explanation: Uses a correlated NOT EXISTS subquery to find artists who have
-- never released an album.
-- ----------------------------------------------------------------------------
SELECT a.name
FROM Artists a
WHERE NOT EXISTS (
    SELECT 1 FROM Albums al WHERE al.artistID = a.artistID
);
-- ----------------------------------------------------------------------------
-- Statement 13: Long or Electronic Songs (UNION)
-- Explanation: Uses UNION to list songs that are either very long (over 300
-- seconds) or Electronic, with no duplicates.
-- ----------------------------------------------------------------------------
SELECT title, duration FROM Songs WHERE duration > 300
UNION
SELECT title, duration FROM Songs WHERE genre = 'Electronic'
ORDER BY duration DESC;
-- ----------------------------------------------------------------------------
-- Statement 14: Two Longest Songs per Genre (CTE and ROW_NUMBER)
-- Explanation: Uses a CTE with ROW_NUMBER to show the two longest songs in
-- each genre.
-- ----------------------------------------------------------------------------
WITH ranked AS (
    SELECT genre, title, duration,
           ROW_NUMBER() OVER (PARTITION BY genre ORDER BY duration DESC) AS rn
    FROM Songs
)
SELECT genre, title, duration
FROM ranked
WHERE rn <= 2
ORDER BY genre, rn;
-- ----------------------------------------------------------------------------
-- Statement 15: Artist Ranking by Song Credits (DENSE_RANK)
-- Explanation: Uses DENSE_RANK to rank artists by the number of songs they are
-- credited on in the many-to-many ArtistContributions table.
-- ----------------------------------------------------------------------------
SELECT a.name,
       COUNT(*) AS songsCredited,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS creditRank
FROM Artists a
JOIN ArtistContributions ac ON a.artistID = ac.artistID
GROUP BY a.artistID, a.name
ORDER BY creditRank, a.name;
-- ----------------------------------------------------------------------------
-- Statement 16: Create the SongCatalog View
-- Explanation: Creates a view that joins each song to its album and main
-- artist so the join does not have to be rewritten.
-- ----------------------------------------------------------------------------
CREATE VIEW SongCatalog AS
SELECT s.songID, s.title AS song, s.genre, s.duration,
       al.title AS album, ar.name AS artist
FROM Songs s
JOIN Albums al ON s.albumID = al.albumID
JOIN Artists ar ON al.artistID = ar.artistID;
-- ----------------------------------------------------------------------------
-- Statement 17: Query the SongCatalog View
-- Explanation: Queries the SongCatalog view for all Hip-Hop songs, ordered by
-- title.
-- ----------------------------------------------------------------------------
SELECT song, album, artist
FROM SongCatalog
WHERE genre = 'Hip-Hop'
ORDER BY song;
-- ----------------------------------------------------------------------------
-- Statement 18: Song Length Categories (CASE)
-- Explanation: Uses a CASE expression to bucket songs into Short, Medium, and
-- Long and counts how many fall into each bucket.
-- ----------------------------------------------------------------------------
SELECT CASE
           WHEN duration < 200 THEN 'Short (under 200s)'
           WHEN duration <= 280 THEN 'Medium (200-280s)'
           ELSE 'Long (over 280s)'
       END AS lengthCategory,
       COUNT(*) AS numSongs
FROM Songs
GROUP BY lengthCategory
ORDER BY numSongs DESC;