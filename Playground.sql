SELECT 'RUR'::currency_code;
SELECT 'BUY'::trade_direction;
SELECT (1291928, NULL)::currency_amount;
SELECT (15, 'RUR', 'RUR')::currency_ratio;
SELECT convert((1000, 'USD'), (95, 'USD', 'RUR'));
SELECT ratio((9500, 'RUR')::currency_amount, (100, 'USD')::currency_amount);
SELECT (1000, 'USD')::currency_amount @ (95, 'RUR', 'USD')::currency_ratio;
SELECT crossrate((90, 'USD', 'RUR'), (14, 'CNY', 'RUR'));
SELECT crossrate((90, 'USD', 'RUR'), (1/14::numeric, 'RUR', 'CNY'));
SELECT crossrate((1/90::numeric, 'RUR', 'USD'), (14, 'CNY', 'RUR'));
SELECT crossrate((1/90::numeric, 'RUR', 'USD'), (1/14::numeric, 'RUR', 'CNY'));
SELECT (1/90::numeric, 'RUR', 'USD')::currency_ratio @ (1/14::numeric, 'RUR', 'CNY')::currency_ratio;
SELECT (100, 'USD')::currency_amount @ (1/90::numeric, 'RUR', 'USD')::currency_ratio @ (1/14::numeric, 'RUR', 'CNY')::currency_ratio;
SELECT closest_quote('SELL', 'RUR', 'CNY', '2023-11-19 10:00 MSK');
SELECT closest_quote('SELL', 'RUR', 'CNY', '2023-10-19 10:00 MSK') IS NULL;
SELECT *, closest_quote(time, direction, 'RUR', trade.code) FROM registry;
SELECT latest_limit('checkouter', 'SELL', 'RUR', 'CNY', '2023-11-19 10:00 MSK');
SELECT latest_limit('checkouter', 'BUY', 'RUR', 'CNY');
SELECT substract_currencies((1000, 'USD'), (2000, 'USD'));
SELECT add_currencies((1000, 'USD'), (2000, 'USD'));
SELECT (1000, 'USD')::currency_amount + (2000, 'USD')::currency_amount_type;
SELECT (1000, 'USD')::currency_amount - (2000, 'CNY')::currency_amount_type;
SELECT (95, 'RUR')::currency_amount / (1, 'USD')::currency_amount_type;
SELECT (96, 'CNY')::currency_amount != (95, 'RUR')::currency_amount;


SELECT * FROM registry;
SELECT * FROM quotes;
SELECT * FROM limits;

CALL update_balance();

WITH tmp1 AS (SELECT id 
                     ,client 
                     ,direction 
                     ,trade 
                     ,rate 
                     ,closest_quote(direction, (rate)."base", (rate)."quote", time) AS reference_rate
                     ,balance 
                     ,balance_price
                     ,pl AS gain_loss
                FROM balance
               WHERE (trade).code != 'EUR'
               ORDER BY time ASC, id ASC),
    tmp2 AS  (SELECT * 
                     ,(CASE direction WHEN 'SELL' THEN 1 ELSE -1 END ) * ((trade @ rate) - (trade @ reference_rate)) as transaction_loss
                FROM tmp1)
SELECT *,
       gain_loss + transaction_loss AS total
  FROM tmp2;
