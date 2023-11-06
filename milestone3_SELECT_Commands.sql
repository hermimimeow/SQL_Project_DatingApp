SELECT * FROM project.match

SELECT *
FROM project.match
INNER JOIN project.in_app_conversation
ON project.match.match_id = project.in_app_conversation.match_id;


SELECT * FROM project.users
WHERE income_level > 80000 and birthdate < '1980-04-03';


SELECT receiver_id, COUNT(*) likes_received
FROM project.match
GROUP BY receiver_id
ORDER BY likes_received DESC;


---Supervips' matches

WITH svip_matches AS (
  SELECT m.sender_id, m.receiver_id
  FROM project.match m
  INNER JOIN project.membership s ON m.sender_id = s.user_id
  INNER JOIN project.membership r ON m.receiver_id = r.user_id
  WHERE s.package_name = 'Supervip'
    AND r.package_name = 'Supervip'
    AND m.response_date IS NOT NULL
)
SELECT COUNT(*) as svip_matches_count
FROM svip_matches;




---What if we charge "Supervip" 50 dollars, and "Vip" for 30 dollars. 
---How much we earned from this group of users so far. This is an app 
---everyone needs a membership

WITH active_memberships AS (
  SELECT m.user_id, m.membership_id, m.package_name
  FROM project.membership m
  
), active_matches AS (
  SELECT m.sender_id, m.receiver_id, m.match_id
  FROM project.match m
  INNER JOIN active_memberships s ON m.sender_id = s.user_id
  INNER JOIN active_memberships r ON m.receiver_id = r.user_id
  WHERE m.response_date IS NOT NULL
), revenue_cal AS (
  SELECT a.membership_id, SUM(
    CASE 
      WHEN a.package_name = 'Supervip' THEN 50.0 
      WHEN a.package_name = 'Vip' THEN 30.0 
    END
  ) AS revenue
  FROM active_memberships a
  INNER JOIN active_matches am ON a.user_id = am.sender_id OR a.user_id = am.receiver_id
  INNER JOIN project.match m ON am.match_id = m.match_id
  GROUP BY a.membership_id
)
SELECT SUM(revenue) AS total_revenue
FROM revenue_cal;
