-- main-database/init/01_schema.sql
-- Runs automatically when the container is first created.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── Users ──────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS users (
    id          VARCHAR(50) PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    alias       VARCHAR(255) NOT NULL,
    email       VARCHAR(255) NOT NULL UNIQUE,
    number      VARCHAR(255) NOT NULL,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    roles       JSON NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ix_users_number ON users(number);

-- ─── Recipients ─────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS recipients (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(255) NOT NULL,
    phone       VARCHAR(50) NOT NULL UNIQUE,
    email       VARCHAR(255),
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── Distribution Lists ────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS distribution_lists (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(63) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── Distribution List ↔ Recipients (junction) ─────────────────────────────

CREATE TABLE IF NOT EXISTS distribution_list_recipients (
    distribution_list_id UUID NOT NULL REFERENCES distribution_lists(id),
    recipient_id         UUID NOT NULL REFERENCES recipients(id),
    PRIMARY KEY (distribution_list_id, recipient_id)
);

-- ─── Message Outbox ─────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS message_outbox (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_phone         VARCHAR(50) NOT NULL,
    recipient_name          VARCHAR(255) NOT NULL,
    message_body            TEXT NOT NULL,
    status                  VARCHAR(20) NOT NULL,
    distribution_list_name  VARCHAR(255) NOT NULL,
    message_id              UUID NOT NULL,
    initiated_by            VARCHAR(255) NOT NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    processed_at            TIMESTAMPTZ,
    completed_at            TIMESTAMPTZ,
    error_message           VARCHAR(2000),
    attempt_count           INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS ix_message_outbox_message_id ON message_outbox(message_id);
CREATE INDEX IF NOT EXISTS ix_message_outbox_status ON message_outbox(status);

-- ─── WhatsApp Gateway DB user ───────────────────────────────────────────────

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'whatsapp_gw') THEN
        CREATE ROLE whatsapp_gw WITH LOGIN PASSWORD 'whatsapp_gw_secret';
    END IF;
END
$$;

GRANT CONNECT ON DATABASE appdb TO whatsapp_gw;
GRANT USAGE ON SCHEMA public TO whatsapp_gw;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE message_outbox TO whatsapp_gw;
