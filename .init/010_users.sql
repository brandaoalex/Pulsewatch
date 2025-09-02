CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
   id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
   email             citext NOT NULL UNIQUE,
   email_normal      citext GENERATED ALWAYS AS (LOWER(email)) STORED,
   is_email_verified boolean NOT NULL DEFAULT false,
   display_name      text,
   created_at        timestamptz NOT NULL DEFAULT NOW(),
   updated_at        timestamptz NOT NULL DEFAULT NOW(),
   last_login_at     timestamptz
);

CREATE INDEX idx_users_email_normal ON users(email_normal);

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
