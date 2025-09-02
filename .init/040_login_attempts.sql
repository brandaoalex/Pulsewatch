-- Audit & rate-limit support (don’t block logins in DB; app reads this to decide)
CREATE TABLE login_attempts (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email_input   citext,
    user_id       uuid REFERENCES users(id) ON DELETE SET NULL,
    success       boolean NOT NULL,
    ip_address    inet,
    user_agent    text,
    created_at    timestamptz NOT NULL DEFAULT NOW(),
    error_code    text,     -- e.g., "invalid_credentials", "locked"
    error_detail  text
);

CREATE INDEX idx_login_attempts_email   ON login_attempts(email_input);
CREATE INDEX idx_login_attempts_user    ON login_attempts(user_id);
CREATE INDEX idx_login_attempts_created ON login_attempts(created_at);
