/*
 * Тут все дропы в правильном порядке
 */
DROP PROCEDURE update_balance CASCADE;
DROP FUNCTION latestLimit CASCADE;
DROP FUNCTION closestQuote CASCADE;
DROP TABLE balance CASCADE;
DROP TABLE limits CASCADE;
DROP TABLE quotes CASCADE;
DROP TABLE registry CASCADE;
DROP OPERATOR @ (currency_amount, currency_rate) CASCADE;
DROP OPERATOR / (currency_amount, currency_amount) CASCADE;
DROP FUNCTION crossrate CASCADE;
DROP FUNCTION rate(currency_amount, currency_amount) CASCADE;
DROP OPERATOR @ (currency_amount, currency_rate) CASCADE;
DROP FUNCTION convert(currency_amount, currency_rate) CASCADE;
DROP DOMAIN currency_rate CASCADE;
DROP TYPE currency_rate_type CASCADE;
DROP OPERATOR + (currency_amount, currency_amount) CASCADE;
DROP OPERATOR - (currency_amount, currency_amount) CASCADE;
DROP FUNCTION addCurrencies CASCADE;
DROP FUNCTION subtractCurrencies CASCADE;
DROP FUNCTION abs(currency_amount) CASCADE;
DROP OPERATOR = (currency_amount, currency_amount) CASCADE;
DROP OPERATOR != (currency_amount, currency_amount) CASCADE;
DROP OPERATOR > (currency_amount, currency_amount) CASCADE;
DROP OPERATOR < (currency_amount, currency_amount) CASCADE;
DROP OPERATOR >= (currency_amount, currency_amount) CASCADE;
DROP OPERATOR <= (currency_amount, currency_amount) CASCADE;
DROP FUNCTION equal(currency_amount, currency_amount) CASCADE;
DROP FUNCTION not_equal(currency_amount, currency_amount) CASCADE;
DROP FUNCTION less_then(currency_amount, currency_amount) CASCADE;
DROP FUNCTION greater_then(currency_amount, currency_amount) CASCADE;
DROP FUNCTION less_or_equal_then(currency_amount, currency_amount) CASCADE;
DROP FUNCTION greater_or_equal_then(currency_amount, currency_amount) CASCADE;
DROP DOMAIN currency_amount CASCADE;
DROP TYPE currency_amount_type CASCADE;
DROP DOMAIN trade_direction CASCADE;
DROP DOMAIN currency_code CASCADE;


/* Тип для хранения кода валюты (3 заглавные буквы, непустой) чтобы не чекать по типам отдельно
 */
CREATE DOMAIN currency_code AS varchar(3) CHECK (VALUE IS NOT NULL AND VALUE ~ '^[A-Z]{3}$');


/* Тип для хранения направления сделки (BUY - покупка, SELL - продажа)
 */
CREATE DOMAIN trade_direction AS varchar(4) CHECK (VALUE IN ('BUY', 'SELL'));


/* Типы для хранения валютных сумм
 * currency amount  - тип для хранения отдельной сделки - не может быть <= 0
 * currency balance - тип для хранения баланса - может быть отрицательным
 */
CREATE TYPE currency_amount_type AS (amount numeric, code currency_code);
CREATE DOMAIN currency_amount AS currency_amount_type CHECK ((VALUE).amount IS NOT NULL);


/* ABS 
 */
CREATE OR REPLACE FUNCTION abs(amount currency_amount)
RETURNS currency_amount
AS
$$
SELECT (abs((amount).amount), (amount).code)::currency_amount;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Функция сложения двух величин в одной валюте 
 */
CREATE OR REPLACE FUNCTION addCurrencies(amount1 currency_amount, amount2 currency_amount)
RETURNS currency_amount_type
AS
$$
SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::currency_amount
            ELSE ((amount1).amount + (amount2).amount, (amount1).code)::currency_amount
       END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Функция вычитания двух величин в одной валюте 
 */
CREATE OR REPLACE FUNCTION subtractCurrencies(amount1 currency_amount, amount2 currency_amount)
RETURNS currency_amount_type
AS
$$
SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::currency_amount
            ELSE ((amount1).amount - (amount2).amount, (amount1).code)::currency_amount
       END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Операторы сложения и вычитания сумм для удобства 
 */
CREATE OPERATOR + (
    FUNCTION = addCurrencies,
    LEFTARG = currency_amount,
    RIGHTARG = currency_amount
);

CREATE OPERATOR - (
    FUNCTION = subtractCurrencies,
    LEFTARG = currency_amount,
    RIGHTARG = currency_amount
);

/* currency amount comparison operators */
CREATE OR REPLACE FUNCTION equal(amount1 currency_amount, amount2 currency_amount)
RETURNS boolean
AS
$$
SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::boolean
            ELSE (amount1).amount = (amount2).amount
       END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OPERATOR = (
    FUNCTION = equal,
    LEFTARG = currency_amount,
    RIGHTARG = currency_amount
);


CREATE OR REPLACE FUNCTION not_equal(amount1 currency_amount, amount2 currency_amount)
RETURNS boolean
AS
$$
SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::boolean
            ELSE (amount1).amount != (amount2).amount
       END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OPERATOR != (
    FUNCTION = not_equal,
    LEFTARG = currency_amount,
    RIGHTARG = currency_amount
);


CREATE OR REPLACE FUNCTION less_then(amount1 currency_amount, amount2 currency_amount)
RETURNS boolean
AS
$$
SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::boolean
            ELSE (amount1).amount < (amount2).amount
       END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OPERATOR < (
    FUNCTION = less_then,
    LEFTARG = currency_amount,
    RIGHTARG = currency_amount
);


CREATE OR REPLACE FUNCTION greater_then(amount1 currency_amount, amount2 currency_amount)
RETURNS boolean
AS
$$
SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::boolean
            ELSE (amount1).amount > (amount2).amount
       END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OPERATOR > (
    FUNCTION = greater_then,
    LEFTARG = currency_amount,
    RIGHTARG = currency_amount
);

CREATE OR REPLACE FUNCTION less_or_equal_then(amount1 currency_amount, amount2 currency_amount)
RETURNS boolean
AS
$$
SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::boolean
            ELSE (amount1).amount <= (amount2).amount
       END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OPERATOR <= (
    FUNCTION = less_or_equal_then,
    LEFTARG = currency_amount,
    RIGHTARG = currency_amount
);

CREATE OR REPLACE FUNCTION greater_or_equal_then(amount1 currency_amount, amount2 currency_amount)
RETURNS boolean
AS
$$
SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::boolean
            ELSE (amount1).amount >= (amount2).amount
       END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OPERATOR >= (
    FUNCTION = greater_or_equal_then,
    LEFTARG = currency_amount,
    RIGHTARG = currency_amount
);

/* currency amount comparison operators */



/* Тип в котором можно хранить котировку..
 * rate - отношение|цена
 * base  - валюта которую покупаем
 * quote - валюта в которой расчитываемся
 * Пример: 90 USD/RUR = доллары ЗА рубли = 90 рублей за 1 доллар
 * #TODO ссыль на стандарт, почему именно так принято делать
 */
CREATE TYPE currency_rate_type AS (
    rate     NUMERIC
    ,"base"  currency_code
    ,"quote" currency_code
);

CREATE DOMAIN currency_rate AS currency_rate_type 
        CHECK (((VALUE).rate IS NOT NULL AND (VALUE).rate > 0) AND (VALUE).base != (VALUE).quote);


/* Функция конверсии заданной суммы в валюте по курсу в другую валюту
 */
CREATE OR REPLACE FUNCTION convert(amount currency_amount, rate currency_rate)
RETURNS currency_amount
AS 
$$
SELECT CASE WHEN (amount).code NOT IN (rate.base, rate."quote") THEN NULL::currency_amount
            WHEN (amount).code = (rate)."quote"                 THEN (amount.amount / rate.rate, rate.base)::currency_amount
            WHEN (amount).code = (rate).base                    THEN (amount.amount * rate.rate, rate."quote")::currency_amount
            ELSE NULL::currency_amount
        END;
$$ LANGUAGE SQL IMMUTABLE STRICT;


/* Оператор конверсии для удобства написания: amount @ rate =  amount
 */
CREATE OPERATOR @ (
    FUNCTION = CONVERT,
    LEFTARG = currency_amount,
    RIGHTARG = currency_rate
);


/* Функция из двух сумм получает соответствующую им котировку
 */
CREATE OR REPLACE FUNCTION rate(one currency_amount, two currency_amount)
RETURNS currency_rate
AS 
$$
SELECT CASE WHEN (one).code != (one).code THEN NULL::currency_rate
            ELSE (abs(one.amount/two.amount), two.code, one.code)::currency_rate
        END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Оператор деления двух сумм который должен давать курс
 */
CREATE OPERATOR / (
    FUNCTION = rate,
    LEFTARG = currency_amount,
    RIGHTARG = currency_amount
);


/* Функция берет две котировки и получает результирующую (кросс-курс)
 */
CREATE OR REPLACE FUNCTION crossrate(rate1 currency_rate, rate2 currency_rate)
RETURNS currency_rate
AS
$$
SELECT CASE WHEN (NOT (ARRAY[rate1."base", rate1."quote"] && ARRAY[rate2."base", rate2."quote"])) THEN NULL::currency_rate-- IF rates ARE NOT overlapping
            WHEN ((ARRAY[rate1."base", rate1."quote"] <@ ARRAY[rate2."base", rate2."quote"]) 
                      AND 
                     (ARRAY[rate1."base", rate1."quote"] @> ARRAY[rate2."base", rate2."quote"])) -- IF it IS same rate stated twice
                 THEN NULL::currency_rate
            WHEN rate1."quote" = rate2."quote" THEN (rate1.rate / rate2.rate, rate1."base", rate2."base")::currency_rate
            WHEN rate1."quote" = rate2."base"  THEN (rate1.rate * rate2.rate, rate1."base", rate2."quote")::currency_rate
            WHEN rate1."base"  = rate2."quote" THEN (1 / (rate1.rate * rate2.rate), rate1."quote", rate2."base")::currency_rate
            WHEN rate1."base"  = rate2."base"  THEN (rate2.rate / rate1.rate, rate1."quote", rate2."quote")::currency_rate
            ELSE NULL::currency_rate
        END;
$$ LANGUAGE SQL IMMUTABLE STRICT;


/* Оператор чтобы было курсы друг на друга помножать удобненько и единообразно с оператором конверсии
 * rate @ rate = rate
 */
CREATE OPERATOR @ (
    FUNCTION = crossrate,
    LEFTARG = currency_rate,
    RIGHTARG = currency_rate
);


/* Таблица со сделками. Каждый клиент вносит свои сделки
 */
CREATE TABLE IF NOT EXISTS registry(
	id           serial
	,time        timestamptz DEFAULT now()           -- время сделки
	,client      varchar NOT NULL                    -- клент
	,direction   trade_direction                     -- направление сделки (купить или продать)
	,trade       currency_amount                     -- объем сделки (включая валюту)
	       CHECK ((trade).amount >= 0                  -- не должен быть отрицательным
	             AND ((trade).code IN ((rate).base, (rate)."quote") -- валюта сделки и котировка друг другу релевантны
	             AND (trade).code != 'RUR'))             -- проверяем что не по покупке рубля за рубль
    ,rate        currency_rate                       -- цена сделки
           CHECK ('RUR' IN ((rate).base, (rate)."quote")) -- проверяем что рейт относительно рубля а не какой нибудь
	,payload      JSONB                              -- тут пэйлоад схема-специфичный для каждого клиента
	,deleted_flag boolean DEFAULT FALSE             -- пометка о сторнировании операции
	,PRIMARY KEY (id, time)
);


/* Таблица с установленными порогами на операцию
 * чтобы каждому клиенту можно было сопоставить 
 *  - направление, 
 *  - пороговое значение,
 *  - валютную пару, для которой устанавливается порог
 * нужна чтобы верещать вовремя по своей логике для каждого клиента
 */
CREATE TABLE IF NOT EXISTS limits (
    id         serial
    ,time      timestamp DEFAULT now()            -- время установления лимита
    ,client    varchar NOT NULL                   -- клиент
    ,direction trade_direction                    -- направление котировки (покупаем или продаем)
    ,"limit"   currency_rate                      -- лимит установленный для данного клиента по сделком в даннном направлении
    ,PRIMARY KEY (id, time)
);


/* Информационная таблица с котировками из разных источников
 */
CREATE TABLE IF NOT EXISTS quotes (
    id         serial
    ,time      timestamp DEFAULT now()            -- время снятия данных
    ,direction trade_direction                    -- направление котировки (покупаем или продаем)
    ,rate      currency_rate                      -- котировка валютной пары
    ,"source"  varchar                            -- источник данных (пока varchar, потом подумаем)
    ,PRIMARY KEY (id, time)
);


/* Поиск ближайшего подходящего значения которое не позже чем сделка
 *  - timest - время ближайшее к которому надо найти
 *  - quote_direction - направление котировки
 *  - curr1 и curr2 - валютная пара в произвольном порядке
 */
CREATE OR REPLACE FUNCTION closestQuote(quote_direction trade_direction, curr1 currency_code, curr2 currency_code, timest timestamptz DEFAULT now())
RETURNS currency_rate
AS
$$
SELECT rate
  FROM quotes
 WHERE direction = quote_direction                                  -- только в нужном направлении
       AND (timest - time) >= INTERVAL '0 sec'                      -- только из тех, что были ДО заданного времени
       AND ARRAY[(rate)."quote", (rate)."base"] <@ ARRAY[curr1, curr2]
       AND ARRAY[(rate)."quote", (rate)."base"] @> ARRAY[curr1, curr2] -- только релевантные валютные пары
 ORDER BY (timest - time)
 LIMIT 1
$$ LANGUAGE SQL;


/* Поиск последнего порога
 *  - client - клиента для которого ищется лимит
 *  - timest - время ближайшее к которому надо найти
 *  - quote_direction - направление котировки
 *  - curr1 и curr2 - валютная пара в произвольном порядке
 */
CREATE OR REPLACE FUNCTION latestLimit(client_name varchar, quote_direction trade_direction, curr1 currency_code, curr2 currency_code, timest timestamptz DEFAULT now())
RETURNS currency_rate
AS
$$
SELECT "limit"
  FROM limits
 WHERE client = client_name
       AND direction = quote_direction                                  -- только в нужном направлении
       AND (timest - time) >= INTERVAL '0 sec'                          -- только из тех, что были ДО заданного времени
       AND ARRAY[("limit")."quote", ("limit")."base"] <@ ARRAY[curr1, curr2]
       AND ARRAY[("limit")."quote", ("limit")."base"] @> ARRAY[curr1, curr2]  -- только релевантные валютные пары
 ORDER BY (timest - time)
 LIMIT 1
$$ LANGUAGE SQL


/* Таблица с балансами. Считается функцией
 */
CREATE TABLE IF NOT EXISTS balance (
    id            bigint
    ,time         timestamptz                         -- время сделки
    ,client       varchar NOT NULL                    -- клент
    ,direction    trade_direction                     -- направление сделки (купить или продать)
    ,trade        currency_amount                     -- объем сделки (включая валюту)
           CHECK ((trade).amount >= 0                   -- не должен быть отрицательным
                 AND ((trade).code IN ((rate).base, (rate)."quote") -- валюта сделки и котировка друг другу релевантны
                 AND (trade).code != 'RUR'))             -- проверяем что не по покупке рубля за рубль
    ,rate         currency_rate                       -- цена сделки
           CHECK ('RUR' IN ((rate).base, (rate)."quote")) -- проверяем что рейт относительно рубля а не какой нибудь
    ,payload      JSONB                              -- тут пэйлоад схема-специфичный для каждого клиента
    ,balance      currency_amount
           CHECK ((trade).code = (balance).code)     -- проверим что сделка и баланс совпадают по валюте,
    ,balance_price currency_rate
           CHECK (ARRAY[(balance_price)."quote", (balance_price)."base"] @> ARRAY[(rate).base, (rate)."quote"] 
                  AND 
                  ARRAY[(balance_price)."quote", (balance_price)."base"] <@ ARRAY[(rate).base, (rate)."quote"])
    , pl          currency_amount
           CHECK  ((pl).code = 'RUR')
    ,PRIMARY KEY (id, time)
);


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
                IF iter.trade > abs(counter.balance) THEN
                    counter.crossing_zero := TRUE;
                ELSEIF iter.trade <= abs(counter.balance) THEN
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
               counter.rate := iter.rate;  -- меняем цену
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

