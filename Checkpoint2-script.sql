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
-- 2. The column Songs.genreID (a foreign key to Genres) was removed and
--    replaced by a plain text column Songs.genre, since Genres no longer
--    exists as a table.
-- 3. A view, SongCatalog, is created in Statement 16.
-- ============================================================================
-- ============================================================================
-- MEMBER CONTRIBUTIONS SUMMARY (GROUPED AT THE TOP)
-- ============================================================================
-- This project was completed by one person.
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
-- ============================================================================
-- SECTION 1: SIMPLE STATEMENTS (Statements 1 to 6)
-- ============================================================================
-- ----------------------------------------------------------------------------
-- Statement 01: Long Songs Over Four Minutes
-- Explanation: Retrieve the title, genre, and duration of all songs longer than
-- 4 minutes (240 seconds), sorted from longest to shortest.
-- ----------------------------------------------------------------------------
SELECT title, genre, duration
FROM Songs
WHERE duration > 240
ORDER BY duration DESC;
-- ----------------------------------------------------------------------------
-- Statement 02: Artists Whose Names Start With "The" (Pattern Matching)
-- Explanation: Find the name and country of all artists whose names begin with
-- the word "The" using the LIKE operator with a wildcard.
-- ----------------------------------------------------------------------------
SELECT name, country
FROM Artists
WHERE name LIKE 'The %';
-- ----------------------------------------------------------------------------
-- Statement 03: Aggregate Song Duration Metrics
-- Explanation: Compute the total number of songs in the catalog along with the
-- average, shortest, and longest song duration in seconds.
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS totalSongs,
       ROUND(AVG(duration), 1) AS avgDurationSec,
       MIN(duration) AS shortestSec,
       MAX(duration) AS longestSec
FROM Songs;
-- ----------------------------------------------------------------------------
-- Statement 04: Insert New Artist
-- Explanation: Insert a new artist profile for Nas, including his country and
-- debut year, into the Artists table.
-- ----------------------------------------------------------------------------
INSERT INTO Artists (artistID, name, country, debutYear)
VALUES (12, 'Nas', 'USA', 1994);
-- ----------------------------------------------------------------------------
-- Statement 05: Update Artist Country
-- Explanation: Update the country of the newly inserted artist from the
-- abbreviation "USA" to the full name "United States".
-- ----------------------------------------------------------------------------
UPDATE Artists
SET country = 'United States'
WHERE artistID = 12;
-- ----------------------------------------------------------------------------
-- Statement 06: Delete Newly Added Artist
-- Explanation: Remove the newly inserted artist from the Artists table, since
-- no albums or song credits reference him.
-- ----------------------------------------------------------------------------
DELETE FROM Artists
WHERE artistID = 12;
-- ============================================================================
-- SECTION 2: INTERMEDIATE STATEMENTS (Statements 7 to 11)
-- ============================================================================
-- ----------------------------------------------------------------------------
-- Statement 07: Songs with Album and Artist Details (3-Table Inner Join)
-- Explanation: Retrieve every song alongside the title of its album and the name
-- of the artist who released that album, sorted by artist, album, and song title.
-- ----------------------------------------------------------------------------
SELECT s.title AS song, al.title AS album, ar.name AS artist
FROM Songs s
JOIN Albums al ON s.albumID = al.albumID
JOIN Artists ar ON al.artistID = ar.artistID
ORDER BY ar.name, al.title, s.title;
-- ----------------------------------------------------------------------------
-- Statement 08: Album Count per Artist (LEFT OUTER JOIN)
-- Explanation: Count the number of albums released by each artist, using a left
-- outer join so that artists with no albums are still listed with a count of 0.
-- ----------------------------------------------------------------------------
SELECT a.name, COUNT(al.albumID) AS numAlbums
FROM Artists a
LEFT JOIN Albums al ON a.artistID = al.artistID
GROUP BY a.artistID, a.name
ORDER BY numAlbums DESC, a.name;
-- ----------------------------------------------------------------------------
-- Statement 09: Albums with Multiple Songs (GROUP BY & HAVING)
-- Explanation: Identify albums that contain at least 2 songs in the catalog and
-- calculate the average song duration for each of those albums.
-- ----------------------------------------------------------------------------
SELECT al.title AS album, COUNT(*) AS numSongs, ROUND(AVG(s.duration), 1) AS avgDurationSec
FROM Albums al
JOIN Songs s ON al.albumID = s.albumID
GROUP BY al.albumID, al.title
HAVING COUNT(*) >= 2
ORDER BY avgDurationSec DESC;
-- ----------------------------------------------------------------------------
-- Statement 10: Songs Longer Than the Catalog Average (Scalar Subquery)
-- Explanation: Find all songs whose duration is strictly greater than the
-- average duration of all songs, which is computed with a scalar subquery.
-- ----------------------------------------------------------------------------
SELECT title, duration
FROM Songs
WHERE duration > (SELECT AVG(duration) FROM Songs)
ORDER BY duration DESC;
-- ----------------------------------------------------------------------------
-- Statement 11: Standardize UK Country Names (Conditional Update)
-- Explanation: Update the country value to "United Kingdom" for every artist
-- whose country is currently recorded as "UK".
-- ----------------------------------------------------------------------------
UPDATE Artists
SET country = 'United Kingdom'
WHERE country = 'UK';
-- ============================================================================
-- SECTION 3: COMPLEX STATEMENTS (Statements 12 to 18)
-- ============================================================================
-- ----------------------------------------------------------------------------
-- Statement 12: Artists with No Albums (Correlated NOT EXISTS)
-- Explanation: Find artists who have no matching row in the Albums table, which
-- identifies featured-only artists who appear on songs without releasing an album.
-- ----------------------------------------------------------------------------
SELECT a.name
FROM Artists a
WHERE NOT EXISTS (
    SELECT 1 FROM Albums al WHERE al.artistID = a.artistID
);
-- ----------------------------------------------------------------------------
-- Statement 13: Very Long or Electronic Songs (UNION)
-- Explanation: Combine songs longer than 300 seconds with all Electronic songs
-- into one list using the UNION operator, which removes duplicate rows.
-- ----------------------------------------------------------------------------
SELECT title, duration FROM Songs WHERE duration > 300
UNION
SELECT title, duration FROM Songs WHERE genre = 'Electronic'
ORDER BY duration DESC;
-- ----------------------------------------------------------------------------
-- Statement 14: Two Longest Songs per Genre (CTE & ROW_NUMBER)
-- Explanation: Rank songs by duration within each genre using ROW_NUMBER() in a
-- common table expression, then return only the top two songs from each genre.
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
-- Explanation: Rank artists by the number of songs they are credited on through
-- the ArtistContributions junction table, giving tied artists the same rank
-- with no gaps.
-- ----------------------------------------------------------------------------
SELECT a.name,
       COUNT(*) AS songsCredited,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS creditRank
FROM Artists a
JOIN ArtistContributions ac ON a.artistID = ac.artistID
GROUP BY a.artistID, a.name
ORDER BY creditRank, a.name;
-- ----------------------------------------------------------------------------
-- Statement 16: Create Song Catalog View (DDL View)
-- Explanation: Create a view that joins Songs, Albums, and Artists so that each
-- song is exposed with its genre, duration, album title, and artist name in
-- one result.
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS SongCatalog;
CREATE VIEW SongCatalog AS
SELECT s.songID, s.title AS song, s.genre, s.duration,
       al.title AS album, ar.name AS artist
FROM Songs s
JOIN Albums al ON s.albumID = al.albumID
JOIN Artists ar ON al.artistID = ar.artistID;
-- ----------------------------------------------------------------------------
-- Statement 17: Query the Song Catalog View
-- Explanation: Query the SongCatalog view to retrieve the song, album, and
-- artist for all Hip-Hop songs, sorted by song title.
-- ----------------------------------------------------------------------------
SELECT song, album, artist
FROM SongCatalog
WHERE genre = 'Hip-Hop'
ORDER BY song;
-- ----------------------------------------------------------------------------
-- Statement 18: Song Length Categories (CASE Expression)
-- Explanation: Classify each song as Short (under 200 seconds), Medium (200 to
-- 280 seconds), or Long (over 280 seconds) using a CASE expression, then count
-- the songs in each category.
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