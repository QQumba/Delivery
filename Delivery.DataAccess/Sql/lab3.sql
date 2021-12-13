CREATE SEQUENCE audit_pi_id;

CREATE TABLE audit_pi
(
    command_id integer     not null primary key,
    table_name varchar(30) not null,
    date       timestamp   not null,
    command    varchar(10) not null
);

CREATE OR REPLACE FUNCTION process_audit()
    RETURNS TRIGGER AS
$$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_pi SELECT nextval('audit_pi_id'), 'product', now(), 'INSERT';
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_pi SELECT nextval('audit_pi_id'), 'product', now(), 'UPDATE';
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_pi SELECT nextval('audit_pi_id'), 'product', now(), 'DELETE';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER process_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE
    ON product
    FOR EACH ROW
EXECUTE PROCEDURE process_audit();


CREATE SEQUENCE audit_update_pi_id;
CREATE TABLE audit_update_pi
(
    id         integer     not null,
    command_id integer     not null,
    field_name varchar(30) not null,
    old_value  varchar(30) not null,
    new_value  varchar(30) not null,
    FOREIGN KEY (command_id) REFERENCES audit_pi (command_id)
);

CREATE OR REPLACE FUNCTION registration_audit_records_for_update() RETURNS TRIGGER AS
$$
BEGIN
    IF (old.name != new.name) THEN
        INSERT INTO audit_update_pi
        SELECT nextval('audit_update_pi_id'),
               (SELECT max(command_id) FROM audit_pi),
               'name',
               old.name,
               new.name;
        RETURN NEW;
    ELSIF (old.price != new.price) THEN
        INSERT INTO audit_update_pi
        SELECT nextval('audit_update_pi_id'),
               (SELECT max(command_id) FROM audit_pi),
               'price',
               old.price,
               new.price;
        RETURN NEW;
    ELSIF (old.description != new.description) THEN
        INSERT INTO audit_update_pi
        SELECT nextval('audit_update_pi_id'),
               (SELECT max(command_id) FROM audit_pi),
               'description',
               old.description,
               new.description;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER registration_audit_records_for_update
    AFTER UPDATE
    ON product
    FOR EACH ROW
EXECUTE FUNCTION registration_audit_records_for_update();

CREATE FUNCTION product_instance_wednesday_strict_insert() RETURNS TRIGGER AS
$$
BEGIN
    IF (select extract(dow from now()) = 3) THEN
        raise exception 'Сьогодні середа';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER product_wednesday_strict_insert
    BEFORE INSERT
    ON product_instance
    FOR EACH ROW
EXECUTE FUNCTION product_instance_wednesday_strict_insert();


CREATE SEQUENCE product_copy_id;
CREATE SEQUENCE product_update_count;
CREATE SEQUENCE product_delete_count;

create table if not exists product_copy
(
    id          int         not null
        constraint pk_product_copy
            primary key,
    product_id  int         not null,
    name        varchar(50) not null,
    price       integer     not null,
    description varchar(255),
    operation   varchar(255)
);

CREATE OR REPLACE FUNCTION copy_product_on_operation() RETURNS TRIGGER AS
$$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        raise debug 'update';
        IF (mod(nextval('product_update_count'), 3) = 0) THEN
            INSERT INTO product_copy
            SELECT nextval('product_copy_id'), new.id, new.name, new.price, new.description, 'UPDATE';
        END IF;
    END IF;
    IF (TG_OP = 'DELETE') THEN
        IF (mod(nextval('product_delete_count'), 2) = 0) THEN
            INSERT INTO product_copy
            SELECT nextval('product_copy_id'), old.id, old.name, old.price, old.description, 'DELETE';
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER copy_product_on_operation
    AFTER UPDATE OR DELETE
    ON product
    FOR EACH ROW
EXECUTE FUNCTION copy_product_on_operation();

---------------------------------------------------

delete
from audit_pi;
delete
from audit_update_pi;
delete
from product_copy;

select *
from audit_pi;
select *
from audit_update_pi;
select *
from product;

insert into product_instance (product_id, warehouse_id, quantity)
values (3, 10, 12);

update product
set price = price + 1;
select *
from product_copy;
select *
from product;

insert into product (name, price)
values ('ready to be deleted', '-1');
delete
from product
where name = 'ready to be deleted';
select *
from product_copy;

delete
from product
where price < 0;

delete
from product_instance
where product_id = 1;