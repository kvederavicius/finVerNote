DROP TABLE IF EXISTS notes;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS notebooks;

CREATE TABLE notebooks (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    title TEXT NOT NULL,

    owner BIGINT,

    insert_TStamp timestamp without time zone NOT NULL DEFAULT now(),

    FOREIGN KEY (owner) REFERENCES notebooks(id)
);

CREATE TABLE notes (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    notebook BIGINT NOT NULL,

    title TEXT NOT NULL DEFAULT '',
    content JSON NOT NULL,

    tags BIGINT[], --bridge tbl?

    insert_TStamp timestamp without time zone NOT NULL DEFAULT now(),
    update_TStamp timestamp without time zone NOT NULL DEFAULT now(),

    FOREIGN KEY (notebook) REFERENCES notebooks(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE
);

CREATE TABLE tags (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    title TEXT NOT NULL,

    insert_TStamp timestamp without time zone NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION note_update_TStamp()
    RETURNS trigger LANGUAGE 'plpgsql'
    COST 100
    STABLE NOT LEAKPROOF
AS $BODY$

BEGIN
  NEW.update_TStamp := now();
RETURN NEW;
END;
$BODY$;

CREATE OR REPLACE TRIGGER upd_note
    BEFORE UPDATE ON notes
    FOR EACH ROW
    EXECUTE FUNCTION public.note_update_TStamp();
