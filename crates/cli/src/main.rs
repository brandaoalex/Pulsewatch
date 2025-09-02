// Pulsewatch/
// Cargo.toml (workspace)
// justfile
// docker-compose.yml (postgres, redis, app)
// .env (DATABASE_URL, REDIS_URL, JWT_SECRET)
// crates/
// api/
// domain/
// storage/
// jobs/
// telemetry/
// migrations/  (sqlx-cli)

use std::env;
use clap::builder::TypedValueParser;
use clap::error::ContextValue::String;
use clap::Parser;
use cli::cli::{Args, Commands};

use storage::{Database, PostgresDB};

#[tokio::main]
pub async  fn main() -> Result<(), Box<dyn std::error::Error>> {
    dotenvy::dotenv().ok();

    let args = Args::parse();
    match args.command {
        Commands::CreateUser { email, password, display_name } => {
            println!("Creating user: {}", email);
            println!("Password: {}", password);
            println!("Display name: {:?}", display_name);

            let database_url = env::var("DATABASE_URL")?;
            println!("Database URL: {:?}", database_url);
            let pool = PostgresDB::connect(database_url.as_str()).await?;
            let userid = PostgresDB::create_user(&pool, email.as_ref(), password.as_ref(), display_name.as_deref()).await?;

            println!("User ID: {:?}", userid);
            Ok(())
        }
        Commands::ListUsers => {
            println!("Listing users...");
            Ok(())
        }
    }

}
