CREATE TABLE warehouse_products_details
(
    warehouse_name     VARCHAR(40),
    product_quantities VARCHAR(1000)
);
CREATE OR REPLACE PROCEDURE list_warehouse_products_details()
    language plpgsql
AS
$$
DECLARE
    wh_info CURSOR IS SELECT id, name
                      FROM warehouse;
    product_instance_info CURSOR (wh_id integer) IS
        SELECT p.name, pi.quantity
        from product_instance pi
                 join product p on p.id = pi.product_id
        where pi.warehouse_id = wh_id;
    warehouse_id      INTEGER;
    warehouse_name    VARCHAR(40)   := '';
    product_name      VARCHAR(40)   := '';
    product_quantity     INT;
    product_info_list VARCHAR(1000) := '';
BEGIN
    DELETE FROM warehouse_products_details;
    OPEN wh_info;
    LOOP
        FETCH wh_info INTO warehouse_id,warehouse_name;
        IF NOT FOUND THEN
            EXIT;
        END IF;
        OPEN product_instance_info(warehouse_id);
        product_info_list := '';
        LOOP
            FETCH product_instance_info INTO product_name, product_quantity;
            IF NOT FOUND THEN
                EXIT;
            END IF;
            product_info_list := product_info_list || product_name || ':' || product_quantity || ';';
        END LOOP;
        CLOSE product_instance_info;
        INSERT INTO warehouse_products_details VALUES (warehouse_name, product_info_list);
    END LOOP;
    CLOSE wh_info;
    COMMIT;
END ;
$$;

call list_warehouse_products_details();
select * from warehouse_products_details;
