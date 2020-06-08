
CREATE USER authn WITH PASSWORD 'authn';
CREATE DATABASE authn;
GRANT ALL PRIVILEGES on DATABASE authn TO authn;
CREATE TABLE IF NOT EXISTS accounts (
    id SERIAL PRIMARY KEY,
    username TEXT UNIQUE DEFAULT NULL,
    password TEXT DEFAULT NULL,
    locked boolean NOT NULL DEFAULT false,
    require_new_password boolean NOT NULL DEFAULT false,
    password_changed_at timestamptz DEFAULT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    deleted_at timestamptz DEFAULT NULL
);

CREATE USER feeds WITH PASSWORD 'feeds';
CREATE DATABASE feeds;
GRANT ALL PRIVILEGES on DATABASE feeds TO feeds;

CREATE USER uat_feeds WITH PASSWORD 'uat_feeds';
CREATE DATABASE uat_feeds;
GRANT ALL PRIVILEGES on DATABASE uat_feeds TO uat_feeds;
commit;

