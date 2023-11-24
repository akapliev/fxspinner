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
SELECT closestQuote('SELL', 'RUR', 'CNY', '2023-11-19 10:00 MSK');
SELECT closestQuote('SELL', 'RUR', 'CNY', '2023-10-19 10:00 MSK') IS NULL;
SELECT *, closestQuote(time, direction, 'RUR', trade.code) FROM registry;
SELECT latestLimit('checkouter', 'SELL', 'RUR', 'CNY', '2023-11-19 10:00 MSK');
SELECT latestLimit('checkouter', 'BUY', 'RUR', 'CNY');
SELECT substractCurrencies((1000, 'USD'), (2000, 'USD'));
SELECT addCurrencies((1000, 'USD'), (2000, 'USD'));
SELECT (1000, 'USD')::currency_amount + (2000, 'USD')::currency_amount_type;
SELECT (1000, 'USD')::currency_amount - (2000, 'CNY')::currency_amount_type;
SELECT (95, 'RUR')::currency_amount / (1, 'USD')::currency_amount_type;
SELECT (96, 'CNY')::currency_amount != (95, 'RUR')::currency_amount;


SELECT * FROM registry;
SELECT * FROM quotes;
SELECT * FROM limits;




CALL update_balance();
SELECT id, client, direction, trade, rate, balance, balance_price, pl FROM balance ORDER BY time ASC, id ASC;


