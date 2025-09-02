-- One row per user for password auth (Argon2id hash stored here)
CREATE TABLE user_credentials (
    user_id       uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    password_hash text NOT NULL,
    hash_scheme   text NOT NULL DEFAULT 'argon2id-v1',
    created_at    timestamptz NOT NULL DEFAULT NOW(),
    updated_at    timestamptz NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_user_credentials_updated_at
    BEFORE UPDATE ON user_credentials
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
