DELETE FROM sessions
WHERE expires_at < NOW() OR revoked_at IS NOT NULL;
