-- extensions & helper
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
RETURN NEW;
END; $$ LANGUAGE plpgsql;

-- users
CREATE TABLE IF NOT EXISTS users (
                                     id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           CITEXT NOT NULL UNIQUE,
    email_normal    CITEXT GENERATED ALWAYS AS (LOWER(email)) STORED,
    is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    display_name    TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at   TIMESTAMPTZ
    );
CREATE INDEX IF NOT EXISTS idx_users_email_normal ON users(email_normal);
DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- user_credentials (argon2id hash stored here)
CREATE TABLE IF NOT EXISTS user_credentials (
                                                user_id       UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    password_hash TEXT NOT NULL,
    hash_scheme   TEXT NOT NULL DEFAULT 'argon2id-v1',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
DROP TRIGGER IF EXISTS trg_user_credentials_updated_at ON user_credentials;
CREATE TRIGGER trg_user_credentials_updated_at
    BEFORE UPDATE ON user_credentials
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- sessions (cookie-based)
CREATE TABLE IF NOT EXISTS sessions (
                                        id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    csrf_token    TEXT,
    ip_address    INET,
    user_agent    TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_seen_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at    TIMESTAMPTZ NOT NULL,
    revoked_at    TIMESTAMPTZ
    );
CREATE INDEX IF NOT EXISTS idx_sessions_user     ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires  ON sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_sessions_revoked  ON sessions(revoked_at);

-- login_attempts (audit + rate limiting)
CREATE TABLE IF NOT EXISTS login_attempts (
                                              id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email_input   CITEXT,
    user_id       UUID REFERENCES users(id) ON DELETE SET NULL,
    success       BOOLEAN NOT NULL,
    ip_address    INET,
    user_agent    TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    error_code    TEXT,
    error_detail  TEXT
    );
CREATE INDEX IF NOT EXISTS idx_login_attempts_email   ON login_attempts(email_input);
CREATE INDEX IF NOT EXISTS idx_login_attempts_user    ON login_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_login_attempts_created ON login_attempts(created_at);
