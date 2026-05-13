-- main-database/init/02_seed.sql
-- Seed data — runs after 01_schema.sql on first container creation.

-- ─── Users ──────────────────────────────────────────────────────────────────

INSERT INTO users (id, name, alias, email, number, roles) VALUES
    ('122@lid', 'Antonia M',  'Anto',  'antonia@m.com',       '122@lid', '["admin"]'),
    ('111@lid', 'Pepa López',  'Pepa', 'pepa@lopez.com', '112@lid', '["admin"]');

-- ─── Recipients ─────────────────────────────────────────────────────────────

INSERT INTO recipients (name, phone, email) VALUES
    ('Pepa López',  '111@lid', 'pepa@lopez.com'),
    ('Antonia M',  '122@lid',  NULL),
    ('Mario P',   '133@lid',   NULL);

-- ─── Distribution Lists ────────────────────────────────────────────────────

INSERT INTO distribution_lists (name, description) VALUES
    ('Comunidad',         'Lista general de la comunidad'),
    ('Socios',            'Socios'),
    ('Equipo', 'Equipo interno trabajadores');

-- ─── Distribution List ↔ Recipients ─────────────────────────────────────────
-- Comunidad

INSERT INTO distribution_list_recipients (distribution_list_id, recipient_id)
SELECT dl.id, r.id
FROM distribution_lists dl, recipients r
WHERE dl.name = 'Comunidad'
  AND r.phone IN ('122@lid', '111@lid', '133@lid');

-- Socios

INSERT INTO distribution_list_recipients (distribution_list_id, recipient_id)
SELECT dl.id, r.id
FROM distribution_lists dl, recipients r
WHERE dl.name = 'Socios'
  AND r.phone = '122@lid';

-- Equipo

INSERT INTO distribution_list_recipients (distribution_list_id, recipient_id)
SELECT dl.id, r.id
FROM distribution_lists dl, recipients r
WHERE dl.name = 'Equipo'
  AND r.phone = '111@lid';
