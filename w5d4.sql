--EXTRA CREDIT: Create a procedure that adds a late fee to any customer who returned their rental after 7 days.
--Use the payment and rental tables. Create a stored function that you call inside your procedure. The function will calculate the late fee amount based on how many days late they returned their rental. (Hint* You can subtract  two dates from each other and use Intervals to compare those dates, linked below).


CREATE OR REPLACE FUNCTION late_fee(turn_in_date timestamp, last_date timestamp)
RETURNS numeric AS $$
DECLARE
    past_days integer;
    fee decimal;
BEGIN
    past_days := EXTRACT(DAY FROM turn_in_date - last_date);
    fee := past_days * 2.5;

    RETURN fee;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_fee()
AS $$
DECLARE
    fee numeric;
BEGIN
    UPDATE payment
    SET amount = amount + late_fee(rental.turn_in_date, rental.last_date)
    FROM rental
    WHERE payment.rental_id = rental.rental_id
        AND rental.turn_in_date > rental.last_date + INTERVAL '3 days';
END;
$$ LANGUAGE plpgsql;




--Add a new column in the customer table for Platinum Member. This can be a boolean.
--Platinum Members are any customers who have spent over $200. 
--Create a procedure that updates the Platinum Member column to True for any customer who has spent over $200 and False for any customer who has spent less than $200.
--Use the payment and customer table.

ALTER TABLE customer
ADD COLUMN platinum_member BOOLEAN DEFAULT FALSE;


CREATE OR REPLACE PROCEDURE update_platinum_member()
AS $$
BEGIN
    UPDATE customer
    SET platinum_member = TRUE
    WHERE customer_id IN (
        SELECT customer_id
        FROM payment
        GROUP BY customer_id
        HAVING SUM(amount) > 200
    );

    UPDATE customer
    SET platinum_member = FALSE
    WHERE customer_id NOT IN (
        SELECT customer_id
        FROM payment
        GROUP BY customer_id
        HAVING SUM(amount) > 200
    );
END;
$$ LANGUAGE plpgsql;
