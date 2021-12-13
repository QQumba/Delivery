CREATE OR REPLACE PACKAGE product_pkg
IS
    PROCEDURE add_product_description(min_quantity integer, max_quantity integer);
    FUNCTION last_week_destination_warehouses(product_quantity_threshold integer);
END product_pkg;

CREATE OR REPLACE PACKAGE BODY product_pkg
IS
    PROCEDURE add_product_description(min_quantity integer, max_quantity integer) IS
    BEGIN
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
    END;

    FUNCTION last_week_destination_warehouses(product_quantity_threshold integer) RETURN VARCHAR
    AS
        text VARCHAR(1000);
    BEGIN
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
    END;
END product_pkg;


BEGIN 
    product_pckg.add_product_description(10,1000);
END;
select * from product;