SELECT ip_address, email_input, COUNT(*) AS failures
FROM login_attempts
WHERE success = false AND created_at > NOW() - INTERVAL '15 minutes'
GROUP BY ip_address, email_input
ORDER BY failures DESC;
