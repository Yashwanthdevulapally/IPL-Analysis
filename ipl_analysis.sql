-- ================================================================
-- PROJECT  : IPL Analysis
-- AUTHOR   : Yashwanth
-- TOOL     : PostgreSQL 17 | pgAdmin 4
-- DATASET  : IPL Complete Dataset (2008 - 2026)
-- ROWS     : 283,678
-- SOURCE   : Kaggle

-- ================================================================
-- DESCRIPTION:
-- This project analyzes ball-by-ball IPL data to uncover
-- insights on batting, bowling, team and match performance
-- across 17+ seasons of the Indian Premier League.
-- ================================================================

-- ================================================================
-- BATTING ANALYSIS
-- ================================================================

-- 1. Top 10 Run Scorers of All Time
SELECT batter, 
       SUM(runs_batter) AS total_runs
FROM ipl_balls
GROUP BY batter
ORDER BY total_runs DESC
LIMIT 10;


-- 2. Top 10 Highest Strike Rates (min 500 balls faced)
SELECT batter,
       SUM(runs_batter) AS total_runs,
       COUNT(valid_ball) AS balls_faced,
       ROUND(100.0 * SUM(runs_batter) / NULLIF(COUNT(valid_ball), 0), 2) AS strike_rate
FROM ipl_balls
WHERE valid_ball = 1
GROUP BY batter
HAVING COUNT(valid_ball) >= 500
ORDER BY strike_rate DESC
LIMIT 10;


-- 3. Most Sixes Hit by a Batsman
SELECT batter,
       COUNT(*) AS total_sixes
FROM ipl_balls
WHERE runs_batter = 6
GROUP BY batter
ORDER BY total_sixes DESC
LIMIT 10;


-- 4. Most Fours Hit by a Batsman
SELECT batter,
       COUNT(*) AS total_fours
FROM ipl_balls
WHERE runs_batter = 4
GROUP BY batter
ORDER BY total_fours DESC
LIMIT 10;


-- ================================================================
-- BOWLING ANALYSIS
-- ================================================================

-- 5. Top 10 Wicket Takers
SELECT bowler,
       COUNT(*) AS total_wickets
FROM ipl_balls
WHERE wicket_kind IS NOT NULL
AND wicket_kind NOT IN ('run out', 'retired hurt', 'obstructing the field')
GROUP BY bowler
ORDER BY total_wickets DESC
LIMIT 10;


-- 6. Best Bowling Economy (min 300 valid balls)
SELECT bowler,
       SUM(runs_bowler) AS runs_given,
       COUNT(valid_ball) AS balls_bowled,
       ROUND(SUM(runs_bowler) * 6.0 / NULLIF(COUNT(valid_ball), 0), 2) AS economy
FROM ipl_balls
WHERE valid_ball = 1
GROUP BY bowler
HAVING COUNT(valid_ball) >= 300
ORDER BY economy ASC
LIMIT 10;


-- 7. Most Dot Balls Bowled
SELECT bowler,
       COUNT(*) AS dot_balls
FROM ipl_balls
WHERE runs_total = 0
AND valid_ball = 1
GROUP BY bowler
ORDER BY dot_balls DESC
LIMIT 10;


-- ================================================================
-- MATCH ANALYSIS
-- ================================================================

-- 8. Toss Impact — Does Winning Toss Help Win Match?
SELECT toss_decision,
       COUNT(DISTINCT match_id) AS total_matches,
       SUM(CASE WHEN toss_winner = match_won_by THEN 1 ELSE 0 END) AS toss_winner_won,
       ROUND(100.0 * SUM(CASE WHEN toss_winner = match_won_by THEN 1 ELSE 0 END) 
             / COUNT(DISTINCT match_id), 2) AS win_percentage
FROM ipl_balls
GROUP BY toss_decision;


-- 9. Matches Played Per Season
SELECT season,
       COUNT(DISTINCT match_id) AS total_matches
FROM ipl_balls
GROUP BY season
ORDER BY season;


-- 10. Top Venues by Number of Matches
SELECT venue,
       city,
       COUNT(DISTINCT match_id) AS total_matches
FROM ipl_balls
GROUP BY venue, city
ORDER BY total_matches DESC
LIMIT 10;


-- ================================================================
-- TEAM ANALYSIS
-- ================================================================

-- 11. Team Win Percentage
SELECT match_won_by AS team,
       COUNT(DISTINCT match_id) AS matches_won
FROM ipl_balls
WHERE match_won_by IS NOT NULL
GROUP BY match_won_by
ORDER BY matches_won DESC;


-- 12. Most Runs Scored by a Team in a Single Match
SELECT match_id,
       batting_team,
       innings,
       SUM(runs_total) AS total_runs
FROM ipl_balls
GROUP BY match_id, batting_team, innings
ORDER BY total_runs DESC
LIMIT 10;


-- 13. Best Scoring Overs (highest average runs per over)
SELECT over,
       ROUND(AVG(runs_total), 2) AS avg_runs
FROM ipl_balls
GROUP BY over
ORDER BY avg_runs DESC;


-- ================================================================
-- PLAYER  ANALYSIS
-- ================================================================

-- 14. Most Player of the Match Awards
SELECT player_of_match,
       COUNT(DISTINCT match_id) AS awards
FROM ipl_balls
WHERE player_of_match IS NOT NULL
GROUP BY player_of_match
ORDER BY awards DESC
LIMIT 10;

-- 15. Top 3 Run Scorers Per Season
SELECT season, batter, total_runs, rank
FROM (
    SELECT season,
           batter,
           SUM(runs_batter) AS total_runs,
           RANK() OVER (PARTITION BY season ORDER BY SUM(runs_batter) DESC) AS rank
    FROM ipl_balls
    GROUP BY season, batter
) AS ranked
WHERE rank <= 3
ORDER BY season, rank;

-- 16. Most Ducks (Out for 0 runs)
SELECT player_out,
       COUNT(*) AS ducks
FROM ipl_balls
WHERE player_out IS NOT NULL
AND batter_runs = 0
AND wicket_kind IS NOT NULL
GROUP BY player_out
ORDER BY ducks DESC
LIMIT 10;

-- 17. Batsmen Who Hit Most Sixes in Death Overs (16-20)
SELECT batter,
       COUNT(*) AS sixes_in_death
FROM ipl_balls
WHERE runs_batter = 6
AND over BETWEEN 16 AND 19
GROUP BY batter
ORDER BY sixes_in_death DESC
LIMIT 10;


-- 18. Bowlers With Most Wickets in Powerplay (0-5)
SELECT bowler,
       COUNT(*) AS powerplay_wickets
FROM ipl_balls
WHERE wicket_kind IS NOT NULL
AND wicket_kind NOT IN ('run out', 'retired hurt')
AND over BETWEEN 0 AND 5
GROUP BY bowler
ORDER BY powerplay_wickets DESC
LIMIT 10;

