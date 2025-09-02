use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "pulsewatch-cli")]
#[command(about = "Manage users and tasks for Pulsewatch")]
#[command(version = "0.0.1")]
pub struct Args {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Create a new user
    CreateUser {
        #[arg(long)]
        email: String,
        #[arg(long)]
        password: String,
        #[arg(long)]
        display_name: Option<String>,
    },

    /// List all users
    ListUsers,
}