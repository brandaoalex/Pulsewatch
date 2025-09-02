-- Handy for "forgot password"
CREATE TABLE password_resets (
     id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
     user_id       uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
     token_hash    bytea NOT NULL UNIQUE,     -- store hash of token only
     created_at    timestamptz NOT NULL DEFAULT NOW(),
     expires_at    timestamptz NOT NULL,
     used_at       timestamptz,
     ip_requester  inet
);

CREATE INDEX idx_pwresets_user   ON password_resets(user_id);
CREATE INDEX idx_pwresets_exp    ON password_resets(expires_at);
