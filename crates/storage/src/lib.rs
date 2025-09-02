use sqlx::{PgPool, Postgres, Transaction};
use anyhow::Result;
use async_trait::async_trait;
use sqlx::postgres::PgPoolOptions;
use domain::password::ArgonPassword;

#[async_trait]
pub trait Database {
    async fn connect(database_url : &str) -> Result<PgPool>;
    async fn create_user(db: &PgPool, email: &str, hash: &str, display_name: Option<&str>) -> Result<String>;

    fn list_users() -> Result<()>;
}

pub struct PostgresDB;

#[async_trait]
impl Database for PostgresDB {
    async fn connect(database_url : &str) -> Result<PgPool> {
        let pool = PgPoolOptions::new().max_connections(5).connect(database_url).await?;

        // Create tables if they don't exist
        sqlx::query(r#"
            CREATE TABLE IF NOT EXISTS users (
                id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
                email TEXT UNIQUE NOT NULL,
                display_name TEXT,
                is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            );

            CREATE TABLE IF NOT EXISTS user_credentials (
                user_id TEXT PRIMARY KEY REFERENCES users(id),
                password_hash TEXT NOT NULL,
                hash_scheme TEXT NOT NULL,
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            );
        "#).execute(&pool).await?;

        Ok(pool)
    }
    async fn create_user(db: &PgPool, email: &str, password: &str, display_name: Option<&str>)
    -> Result<String> {
        let mut tx = db.begin().await?;

        // Try insert user
        let rec = sqlx::query!(
            r#"
            INSERT INTO users (email, display_name, is_email_verified)
            VALUES ($1, $2, $3)
            ON CONFLICT (email)
            DO UPDATE SET updated_at = NOW()
            RETURNING id
            "#,
            email,
            display_name,
            false
        ).fetch_one(&mut *tx).await?;

        let user_id = rec.id;

        // Hash password
        let password_hash = ArgonPassword::new(password.to_string())
            .hash_password_argon2ID()
            .map_err(|e| anyhow::anyhow!("Error hashing password: {}", e))?;

        // Insert/Update credentials
        sqlx::query!(
            r#"
            INSERT INTO user_credentials (user_id, password_hash, hash_scheme)
            VALUES ($1, $2, 'argon2id-v1')
            ON CONFLICT (user_id) DO UPDATE
              SET password_hash = EXCLUDED.password_hash,
                  hash_scheme   = EXCLUDED.hash_scheme,
                  updated_at    = NOW()
            "#,
            user_id,
            password_hash
        ).execute(&mut *tx).await?;

        tx.commit().await?;
        Ok(user_id.to_string())
    }


    fn list_users() -> Result<()> {
        todo!()
    }
}

pub async fn pool(database_url : &str) -> Result<PgPool> {
    let pool = PgPoolOptions::new().max_connections(5).connect(database_url).await?;

    // Create tables if they don't exist
    sqlx::query(r#"
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
            email TEXT UNIQUE NOT NULL,
            display_name TEXT,
            is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );

        CREATE TABLE IF NOT EXISTS user_credentials (
            user_id TEXT PRIMARY KEY REFERENCES users(id),
            password_hash TEXT NOT NULL,
            hash_scheme TEXT NOT NULL,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );
    "#).execute(&pool).await?;

    Ok(pool)
}

pub async fn create_user(db : &PgPool) -> Result<()> {

    Ok(())
}