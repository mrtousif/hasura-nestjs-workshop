CREATE OR REPLACE FUNCTION set_current_timestamp_updated_at()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE users
(
    id           SERIAL      NOT NULL,
    email        TEXT        NOT NULL UNIQUE,
    display_name TEXT,
    coins        INT         NOT NULL DEFAULT 50 CHECK (coins >= 0),
    created_at   timestamptz NOT NULL DEFAULT NOW(),
    updated_at   timestamptz NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

CREATE TRIGGER set_users_updated_at
    BEFORE UPDATE
    ON users
    FOR EACH ROW
EXECUTE PROCEDURE set_current_timestamp_updated_at();


CREATE TABLE user_created_items
(
    id          SERIAL      NOT NULL,
    user_id     INT         NOT NULL REFERENCES users (id),
    name        TEXT        NOT NULL,
    description TEXT,
    secret      TEXT        NOT NULL,
    cost        INT         NOT NULL DEFAULT 0,
    created_at  timestamptz NOT NULL DEFAULT NOW(),
    updated_at  timestamptz NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

CREATE VIEW public_items AS SELECT id, user_id, name, description, cost, created_at, updated_at FROM user_created_items;

CREATE TRIGGER set_user_created_items_updated_at
    BEFORE UPDATE
    ON user_created_items
    FOR EACH ROW
EXECUTE PROCEDURE set_current_timestamp_updated_at();

CREATE TABLE user_purchased_items
(
    user_id       INT         NOT NULL REFERENCES users (id),
    user_item_id  INT         NOT NULL REFERENCES user_created_items (id),
    purchase_cost INT         NOT NULL,
    purchased_at  timestamptz NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, user_item_id)
);