CREATE OR REPLACE FUNCTION _sysinternal.on_create_hypertable_replica()
    RETURNS TRIGGER LANGUAGE PLPGSQL AS
$BODY$
DECLARE
    hypertable_row hypertable;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT *
        INTO STRICT hypertable_row
        FROM hypertable AS h
        WHERE h.name = NEW.hypertable_name;

        PERFORM _sysinternal.create_replica_table(NEW.schema_name, NEW.table_name, hypertable_row.root_schema_name,
                                                  hypertable_row.root_table_name);
        PERFORM _sysinternal.create_replica_table(NEW.distinct_schema_name, NEW.distinct_table_name,
                                                  hypertable_row.distinct_schema_name, hypertable_row.distinct_table_name);
        RETURN NEW;
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RAISE EXCEPTION 'Only inserts and deletets supported on hypertable_replica table, got %', TG_OP
    USING ERRCODE = 'IO101';

    RETURN NEW;
END
$BODY$
SET SEARCH_PATH = 'public';