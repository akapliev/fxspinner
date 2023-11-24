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
SELECT * FROM registry;
SELECT * FROM quotes;
SELECT * FROM limits;
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


SELECT time, id
       ,direction  
       ,trade
       ,rate
       lag(new_balance, 1)
       trade + lag(new_balance, 1) AS new_balance
       
       
       ,(0, (trade).code)::currency_balance AS initial_old_stock
       ,(0, (trade).code)::currency_balance AS initial_new_stock
  FROM registry
 ORDER BY time ASC, id ASC;




DO 
$$
DECLARE
   currency record;
   iter record;
   counter record;
BEGIN
   TRUNCATE balance; --почистим табличку
   <<currency>>
   -- побежали по валютам
   FOR currency IN SELECT DISTINCT (trade).code AS code 
                     FROM registry 
   LOOP
       -- проинициализируем счетчики
       SELECT (0, currency.code)::currency_amount       AS balance
              ,(1, currency.code, 'RUR')::currency_rate AS rate
              ,(0, 'RUR')::currency_amount              AS pl
              ,TRUE AS same_direction
              ,FALSE AS crossing_zero
         INTO counter;
       <<balance>>
       FOR iter IN SELECT * -- #TODO явно поименовать
                     FROM registry 
                    WHERE (trade).code = currency.code
                          AND deleted_flag = FALSE
                    ORDER BY time ASC, id ASC
       LOOP
           -- поймем направление сделки
           IF (iter.direction ='BUY' AND (counter.balance).amount >= 0) OR (iter.direction ='SELL' AND (counter.balance).amount <= 0) THEN 
                counter.same_direction := TRUE;
                counter.crossing_zero := FALSE;
           ELSEIF (iter.direction ='BUY' AND (counter.balance).amount < 0) OR (iter.direction ='SELL' AND (counter.balance).amount > 0) THEN 
                counter.same_direction := FALSE;
                -- #TODO добавить операторы сравнения
                IF (iter.trade).amount > (counter.balance).amount  THEN
                    counter.crossing_zero := TRUE;
                ELSEIF (iter.trade).amount <= (counter.balance).amount THEN
                    counter.crossing_zero := FALSE;
                END IF;
           END IF;

           -- посчитаем PL
           IF counter.same_direction = FALSE THEN
               IF counter.crossing_zero = TRUE THEN
                   counter.pl = (abs(counter.balance) @ iter.rate) - (abs(counter.balance) @ counter.rate); 
               ELSEIF counter.crossing_zero = FALSE THEN
                   counter.pl = (iter.trade @ iter.rate) - (iter.trade @ counter.rate);
               END IF;
           ELSE 
               counter.pl = (0, 'RUR' )::currency_amount;
           END IF;
           

           -- обновим цену
           IF counter.same_direction = TRUE THEN
               counter.rate := ((iter.trade @ iter.rate) + (abs(counter.balance) @ counter.rate)) / (iter.trade + abs(counter.balance));  -- копим сделку
           ELSEIF ((counter.same_direction = FALSE) AND (counter.crossing_zero = TRUE)) THEN
               counter.rate := iter.rate;  -- меняем цена
           -- этот кусок не отрабатывает
           ELSEIF ((counter.same_direction = FALSE) AND (counter.crossing_zero = FALSE)) THEN
               counter.rate := counter.rate;  -- оставляем цену
           END IF;

           -- обновим баланс
           IF iter.direction = 'BUY' THEN
               counter.balance := counter.balance + iter.trade;
           ELSEIF iter.direction = 'SELL' THEN
               counter.balance := counter.balance - iter.trade;
           END IF;

           -- добавим запись в таблицу
           INSERT INTO balance(id, time, client, direction, trade, rate, payload, balance, balance_price, pl) 
                  VALUES (iter.id, iter.time, iter.client, iter.direction, iter.trade, iter.rate, iter.payload, counter.balance, counter.rate, counter.pl);
       END LOOP balance;
   END LOOP currency;
END;
$$ LANGUAGE plpgsql;


SELECT id, client, direction, trade, rate, balance, balance_price, pl FROM balance ORDER BY time ASC, id ASC;

SELECT * FROM registry;

