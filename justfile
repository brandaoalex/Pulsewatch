set shell := ["bash", "-cu"]

# Default task if you just run `just`
default:
    @just --list

#Run user creation (email, password, (Op. Display name)
create-user email password display_name=" -":
    cargo run -p cli -- create-user --email {{email}} --password {{password}} --display-name {{display_name}}

# Run the API server
dev:
    cargo watch -x 'run -p api'

# Run background jobs worker
worker:
    cargo watch -x 'run -p jobs'

#Run tests
test:
    cargo test --all

# Format & lint
lint:
    cargo clippy --all-targets -- -D warnings
fmt:
    cargo fmt --all

# Database
migrate:
    sqlx migrate run

new-migration name:
    sqlx migrate add {{name}}

reset-db:
    sqlx database reset --yes

#Refresh Query cash for database
refresh-db :
    cargo sqlx prepare --database-url postgres://pulse:pulse@localhost:5432/pulsewatch