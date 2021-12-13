create sequence even_warehouse_id_seq
    as integer
    increment by 2;

alter sequence even_warehouse_id_seq owner to postgres;

create table if not exists warehouse
(
    id integer default nextval('even_warehouse_id_seq'::regclass) not null
        constraint pk_warehouse
            primary key,
    name varchar(50) not null
        constraint uc_warehouse
            unique,
    info text
);

alter table warehouse owner to postgres;

create index if not exists warehouse_name_index
    on warehouse (name);

create table if not exists product
(
    id serial not null
        constraint pk_product
            primary key,
    name varchar(50) not null,
    price integer not null,
    description varchar(255)
);

alter table product owner to postgres;

create table if not exists product_instance
(
    id serial not null
        constraint pk_product_instance
            primary key,
    product_id integer not null
        constraint fk_product_instance_product
            references product,
    warehouse_id integer not null
        constraint fk_product_instance_warehouse
            references warehouse,
    quantity integer not null,
    constraint uc_product_instance
        unique (product_id, warehouse_id)
);

alter table product_instance owner to postgres;

create table if not exists cargo
(
    id serial not null
        constraint pk_cargo
            primary key,
    destination_warehouse_id integer not null
        constraint fk_cargo_destination_warehouse
            references warehouse,
    product_instance_id integer not null
        constraint fk_cargo_product_instance
            references product_instance,
    delivery_date date not null,
    constraint uc_cargo
        unique (destination_warehouse_id, product_instance_id, delivery_date)
);

alter table cargo owner to postgres;

create or replace view cargo_product_info(id, name, price, quantity, warehouse_id, destination_warehouse_id, delivery_date) as
SELECT p.id,
       p.name,
       p.price,
       pi.quantity,
       pi.warehouse_id,
       c.destination_warehouse_id,
       c.delivery_date
FROM product p
         JOIN product_instance pi ON p.id = pi.product_id
         JOIN cargo c ON pi.id = c.product_instance_id;

alter table cargo_product_info owner to postgres;

create or replace view total_product_quantity(id, quantity) as
SELECT p.id,
       sum(pi.quantity) AS quantity
FROM product_instance pi
         JOIN product p ON p.id = pi.product_id
GROUP BY p.id;

alter table total_product_quantity owner to postgres;

create or replace view warehouse_product(warehouse_id, id, name, price, description, quantity) as
SELECT w.id AS warehouse_id,
       p.id,
       p.name,
       p.price,
       p.description,
       pi.quantity
FROM warehouse w
         JOIN product_instance pi ON w.id = pi.warehouse_id
         JOIN product p ON pi.product_id = p.id
ORDER BY w.id;

alter table warehouse_product owner to postgres;

create or replace procedure add_product_description(min_quantity integer, max_quantity integer)
    language sql
as $$
UPDATE product p
SET description = 'Abundance'
WHERE p.id IN (
    SELECT t.id
    FROM total_product_quantity t
    WHERE t.quantity > max_quantity);

UPDATE product p
SET description = 'Lack'
WHERE p.id IN (
    SELECT t.id
    FROM total_product_quantity t
    WHERE t.quantity < min_quantity);
$$;

alter procedure add_product_description(integer, integer) owner to postgres;

create or replace procedure add_product_discount(product_id integer, discount integer)
    language sql
as $$
UPDATE product p
SET description = 'Discount ' || discount || ' %'
WHERE p.id = product_id
$$;

alter procedure add_product_discount(integer, integer) owner to postgres;

create or replace procedure add_expensive_product_info(processed_warehouse_id integer)
    language sql
as $$
UPDATE warehouse
SET info = 'The most expensive product is: ' || p.name
FROM (
         SELECT p.name
         FROM product p
                  INNER JOIN product_instance pi on p.id = pi.product_id
                  INNER JOIN warehouse w on w.id = pi.warehouse_id
         WHERE w.id = processed_warehouse_id
         ORDER BY p.price DESC
             FETCH NEXT 1 ROW ONLY) p
WHERE id = processed_warehouse_id;
$$;

alter procedure add_expensive_product_info(integer) owner to postgres;

create or replace procedure apply_product_discount(processed_warehouse_id integer, discount integer)
    language sql
as $$
UPDATE product
SET price = price - price * discount / 100
WHERE id IN
      (
          SELECT p.id
          FROM product p
                   INNER JOIN product_instance pi on p.id = pi.product_id
                   INNER JOIN warehouse w on pi.warehouse_id = w.id
          WHERE w.id = processed_warehouse_id
      )
$$;

alter procedure apply_product_discount(integer, integer) owner to postgres;

create or replace procedure add_date_info(wh_id integer)
    language sql
as $$
UPDATE warehouse
SET info = to_char(current_date,'YYYY-MM-DD')
WHERE id = wh_id;
$$;

alter procedure add_date_info(integer) owner to postgres;

