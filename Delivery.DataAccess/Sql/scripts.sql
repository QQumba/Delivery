select *
from warehouse;
select *
from product;
select *
from product_instance;
select *
from cargo;


UPDATE product
SET description = 'Abundance'
WHERE id IN (
    SELECT p.id
    FROM product p
    WHERE (
              SELECT sum(pi.quantity)
              FROM product_instance pi
              WHERE pi.product_id = p.id
              GROUP BY pi.product_id
          ) > 1000) = product.id;

UPDATE product p
SET description = 'Abundance'
WHERE p.id IN (
    SELECT t.id
    FROM total_product_quantity t
    WHERE t.quantity > 1000);

UPDATE product p
SET description = 'Lack'
WHERE p.id IN (
    SELECT t.id
    FROM total_product_quantity t
    WHERE t.quantity < 100);

CALL add_product_description(100, 1000);

CREATE VIEW total_product_quantity AS
SELECT p.id as id, sum(pi.quantity) as quantity
from product_instance pi
         inner join product p on p.id = pi.product_id
group by p.id;

SELECT *
FROM total_product_quantity;

select *
from product_instance;

SELECT *
FROM product
order by id;

select p.*
from product p
where (
          select sum(pi.quantity)
          from product_instance pi
          where pi.product_id = p.id
          group by pi.product_id
      ) > 1000;

select p.name, sum(pi.quantity)
from product_instance pi
         inner join product p on p.id = pi.product_id
group by p.name;

select sum(pi.quantity)
from product_instance pi
group by pi.product_id;

select *
from product_instance;

EXPLAIN
SELECT w.name, dw.name, pi.quantity, p.name, c.delivery_date
FROM warehouse dw
         INNER JOIN cargo c
                    on dw.id = c.destination_warehouse_id
         INNER JOIN product_instance pi
                    on pi.id = c.product_instance_id
         INNER JOIN warehouse w
                    on w.id = pi.warehouse_id
         INNER JOIN product p
                    on p.id = pi.product_id
WHERE p.id = 3;

CREATE VIEW cargo_product_info AS
SELECT p.id, p.name, p.price, pi.quantity, pi.warehouse_id, c.destination_warehouse_id, c.delivery_date
FROM product p
         INNER JOIN product_instance pi on p.id = pi.product_id
         INNER JOIN cargo c on pi.id = c.product_instance_id;

SELECT p.id, p.name, t.quantity, p.description
FROM total_product_quantity t
         INNER JOIN product p ON t.id = p.id
ORDER BY t.quantity DESC;

CALL add_product_discount(6, 25);

SELECT *
FROM cargo_product_info;

SELECT *
FROM total_product_quantity;

SELECT *
FROM product;

CREATE PROCEDURE add_product_description(min_quantity INT, max_quantity INT)
    LANGUAGE sql
AS
$$
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

CREATE PROCEDURE add_product_discount(product_id INT, discount INT)
    LANGUAGE sql
AS
$$
UPDATE product p
SET description = 'Discount ' || discount || ' %'
WHERE p.id = product_id
$$;

ALTER TABLE warehouse
    ADD info text;

CREATE PROCEDURE add_expensive_product_info(processed_warehouse_id INT)
    LANGUAGE sql
AS
$$
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

drop procedure add_expensive_product_info;
CALL add_expensive_product_info(2);

SELECT *
FROM warehouse;

SELECT p.name
FROM product p
         INNER JOIN product_instance pi on p.id = pi.product_id
         INNER JOIN warehouse w on w.id = pi.warehouse_id
WHERE w.id = 2
ORDER BY p.price DESC
    FETCH NEXT 1 ROW ONLY;

SELECT p.name, p.price, warehouse_id
FROM product_instance
         inner join product p on p.id = product_instance.product_id;

CREATE PROCEDURE apply_product_discount(processed_warehouse_id INT, discount INT)
    LANGUAGE sql
AS
$$
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

CALL apply_product_discount(6, 15);

SELECT *
FROM warehouse_product
WHERE warehouse_id = 6;

CREATE VIEW warehouse_product
AS
SELECT w.id as warehouse_id, p.*, pi.quantity
FROM warehouse w
         INNER JOIN product_instance pi on w.id = pi.warehouse_id
         INNER JOIN product p on pi.product_id = p.id
ORDER BY w.id;

CREATE FUNCTION warehouse_product(wh_id INT)
    RETURNS TABLE
            (
                product_id   INT,
                product_name varchar(50),
                price        INT,
                description  TEXT,
                quantity     INT
            )
    LANGUAGE sql
AS
$$
SELECT p.*, pi.quantity
FROM warehouse w
         INNER JOIN product_instance pi on w.id = pi.warehouse_id
         INNER JOIN product p on pi.product_id = p.id
WHERE warehouse_id = wh_id
GROUP BY p.id, w.id, pi.id;
$$;

DROP FUNCTION warehouse_product;

CREATE PROCEDURE add_date_info(wh_id INT)
    LANGUAGE sql
AS
$$
UPDATE warehouse
SET info = to_char(current_date, 'YYYY-MM-DD')
WHERE id = wh_id;
$$;

SELECT *
FROM warehouse
WHERE id = 6;

CALL add_date_info(6);

create function last_week_destination_warehouses(product_quantity_threshold integer)
    returns text
    language plpgsql
as
$$
declare
    names text;
begin
    select string_agg(w.name, ', ')
    into names
    from (
             select w.name
             from warehouse w
                      join cargo c on w.id = c.destination_warehouse_id
                      join product_instance pi on c.product_instance_id = pi.id
             where c.delivery_date < current_date
               and c.delivery_date > cast(current_date - interval '7' day as date)
             group by w.id
             having sum(pi.quantity) < product_quantity_threshold
         ) w;

    return names;
end;
$$;
