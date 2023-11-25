/* Поиск ближайшего подходящего значения которое не позже чем сделка
 *  - p_time - время ближайшее к которому надо найти
 *  - quote_direction - направление котировки
 *  - curr1 и curr2 - валютная пара в произвольном порядке
 */
DROP FUNCTION IF EXISTS closest_quote(trade_direction, currency_code, currency_code) CASCADE;
CREATE OR REPLACE FUNCTION closest_quote(quote_direction trade_direction, curr1 currency_code, curr2 currency_code, p_time timestamptz DEFAULT now())
RETURNS currency_rate
AS
$$
SELECT rate
  FROM quotes
 WHERE direction = quote_direction                                  -- только в нужном направлении
       AND (p_time - time) >= INTERVAL '0 sec'                      -- только из тех, что были ДО заданного времени
       AND ARRAY[(rate)."quote", (rate)."base"] <@ ARRAY[curr1, curr2]
       AND ARRAY[(rate)."quote", (rate)."base"] @> ARRAY[curr1, curr2] -- только релевантные валютные пары
 ORDER BY (timest - time)
 LIMIT 1
$$ LANGUAGE SQL;


/* Поиск последнего порога отсечения
 *  - client - клиента для которого ищется лимит
 *  - p_time - время ближайшее к которому надо найти
 *  - quote_direction - направление котировки
 *  - curr1 и curr2 - валютная пара в произвольном порядке
 */
DROP FUNCTION IF EXISTS latest_limit(varchar, trade_direction, currency_code, currency_code) CASCADE;
CREATE OR REPLACE FUNCTION latest_limit(client_name varchar, quote_direction trade_direction, curr1 currency_code, curr2 currency_code, p_time timestamptz DEFAULT now())
RETURNS currency_rate
AS
$$
SELECT "limit"
  FROM limits
 WHERE client = client_name
       AND direction = quote_direction                                        -- только в нужном направлении
       AND (p_time - time) >= INTERVAL '0 sec'                                -- только из тех, что были ДО заданного времени
       AND ARRAY[("limit")."quote", ("limit")."base"] <@ ARRAY[curr1, curr2]
       AND ARRAY[("limit")."quote", ("limit")."base"] @> ARRAY[curr1, curr2]  -- только релевантные валютные пары
 ORDER BY (p_time - time)
 LIMIT 1
$$ LANGUAGE SQL;


/* Чистит и обновляет таблицу balance*/
DROP PROCEDURE IF EXISTS update_balance() CASCADE;
CREATE OR REPLACE PROCEDURE update_balance() AS
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
       SELECT (0, currency.code)::currency_amount       AS balance        -- счетчик старого баланса (инициализируем нулем)
              ,(1, currency.code, 'RUR')::currency_rate AS rate           -- счетчик курса (инициализирум похер чем)
              ,(0, 'RUR')::currency_amount              AS pl             -- счетчик Profit / Loss от операции
              ,TRUE                                     AS same_direction -- флаг направленности сделки (первая сделка всегда от нуля)
              ,FALSE                                    AS crossing_zero  -- флаг пересечения сделкой нулевого баланса (первая сделка никогда ноль не пересекает)
         INTO counter;
       <<balance>>
       FOR iter IN SELECT * -- #TODO явно поименовать
                     FROM registry 
                    WHERE (trade).code     = currency.code
                          AND deleted_flag = FALSE
                    ORDER BY time ASC, id ASC
       LOOP
           -- поймем направление сделки
           IF (iter.direction ='BUY' AND (counter.balance).amount >= 0) OR (iter.direction ='SELL' AND (counter.balance).amount <= 0) THEN 
                counter.same_direction := TRUE;
                counter.crossing_zero  := FALSE;
           ELSEIF (iter.direction ='BUY' AND (counter.balance).amount < 0) OR (iter.direction ='SELL' AND (counter.balance).amount > 0) THEN 
                counter.same_direction := FALSE;
                IF iter.trade > abs(counter.balance) THEN
                    counter.crossing_zero := TRUE;
                ELSEIF iter.trade <= abs(counter.balance) THEN
                    counter.crossing_zero := FALSE;
                END IF;

           END IF;

           -- посчитаем PL
           IF counter.same_direction = FALSE THEN
               IF counter.crossing_zero = TRUE THEN
                   counter.pl = (CASE iter.direction WHEN 'SELL' THEN 1 ELSE -1 END) * ((abs(counter.balance) @ iter.rate) - (abs(counter.balance) @ counter.rate)); 
               ELSEIF counter.crossing_zero = FALSE THEN
                   counter.pl = (CASE iter.direction WHEN 'SELL' THEN 1 ELSE -1 END) * ((iter.trade @ iter.rate) - (iter.trade @ counter.rate));
               END IF;
           ELSE 
               counter.pl = (0, 'RUR' )::currency_amount;
           END IF;
           

           -- обновим цену
           IF counter.same_direction = TRUE THEN
               counter.rate := ((iter.trade @ iter.rate) + (abs(counter.balance) @ counter.rate)) / (iter.trade + abs(counter.balance));  -- копим сделку
           ELSEIF ((counter.same_direction = FALSE) AND (counter.crossing_zero = TRUE)) THEN
               counter.rate := iter.rate;  -- меняем цену на новую 
--           ELSEIF ((counter.same_direction = FALSE) AND (counter.crossing_zero = FALSE)) THEN
--              counter.rate := counter.rate;  -- оставляем старую цену
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