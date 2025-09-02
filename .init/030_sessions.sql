-- Cookie-based login sessions
CREATE TABLE sessions (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  csrf_token    text,         -- if you use double-submit CSRF
  ip_address    inet,
  user_agent    text,
  created_at    timestamptz NOT NULL DEFAULT NOW(),
  last_seen_at  timestamptz NOT NULL DEFAULT NOW(),
  expires_at    timestamptz NOT NULL,
  revoked_at    timestamptz
);

CREATE INDEX idx_sessions_user     ON sessions(user_id);
CREATE INDEX idx_sessions_expires  ON sessions(expires_at);
CREATE INDEX idx_sessions_revoked  ON sessions(revoked_at);

-- Optional: prevent >1 active session per user (remove if you want multi-device login)
-- CREATE UNIQUE INDEX uniq_active_session ON sessions(user_id)
-- WHERE revoked_at IS NULL AND expires_at > NOW();
