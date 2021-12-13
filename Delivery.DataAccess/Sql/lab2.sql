CREATE OR REPLACE PROCEDURE set_product_price(p_id INT, new_price INT)
    LANGUAGE plpgsql
AS
$$
DECLARE
    product_total_quantity INTEGER;
    product_price          NUMERIC;
BEGIN
    SELECT sum(pi.quantity) INTO product_total_quantity FROM product_instance pi WHERE pi.product_id = p_id;
    SELECT p.price INTO product_price FROM product p WHERE p.id = p_id;

    IF new_price < 0 THEN
        raise exception 'Негативна ціна';
    END IF;

    IF product_price < new_price / 2 THEN
        raise exception 'Зниження ціни більше,ніж на 50%%';
    END IF;

    IF product_total_quantity < 10 THEN
        raise exception 'Знижка не потрібна';
    END IF;

    UPDATE product SET price = new_price where id = p_id;
END
$$;

SELECT sum(pi.quantity)
FROM product_instance pi
WHERE pi.product_id = 3;

select p.id, sum(pi.quantity) as total_quantity, p.name, p.price
from product p
         join product_instance pi on p.id = pi.product_id
group by p.id
order by id;

call set_product_price(5, 10);
