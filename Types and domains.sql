/* Тип для хранения кода валюты (3 заглавные буквы, непустой) чтобы не чекать по типам отдельно
 */
DROP DOMAIN IF EXISTS currency_code CASCADE;
CREATE DOMAIN currency_code AS varchar(3) CHECK (VALUE IS NOT NULL AND VALUE ~ '^[A-Z]{3}$');

/* Тип для хранения направления сделки (BUY - покупка, SELL - продажа)
 */
-- DROP DOMAIN IF EXISTS trade_direction CASCADE;
DROP TYPE IF EXISTS direction_type CASCADE;
CREATE TYPE direction_type AS ENUM ('BUY', 'SELL');

-- SELECT 'SELL'::direction_type;
-- SELECT NULL::direction_type;


/* Типы для хранения валютных сумм
 * currency amount  - тип для хранения отдельной сделки - не может быть <= 0
 * currency balance - тип для хранения баланса - может быть отрицательным
 */
DROP TYPE IF EXISTS currency_amount_type CASCADE;
CREATE TYPE currency_amount_type AS (amount NUMERIC, code currency_code);

-- SELECT NULL::currency_amount_type;
-- SELECT (95, 'RUR')::currency_amount_type;
-- SELECT (95, NULL)::currency_amount_type;
-- SELECT (NULL, 'RUR')::currency_amount_type;


DROP DOMAIN IF EXISTS currency_amount CASCADE;
CREATE DOMAIN currency_amount AS currency_amount_type CHECK ((VALUE).amount IS NOT NULL );

-- SELECT NULL::currency_amount; --нельзя
-- SELECT (10, NULL)::currency_amount; --нельзя

/* тип для хранения сделок
 * - направления
 * - валютная сумма */
DROP TYPE IF EXISTS trade_type CASCADE;
CREATE TYPE trade_type AS (direction direction_type, amount currency_amount, rate currency_rate);

-- SELECT ('BUY', (1000, 'RUR'))::trade_type;
-- SELECT NULL::trade_type; --можно

/* Тип в котором можно хранить котировку..
 * rate - отношение|цена
 * base  - валюта которую покупаем
 * quote - валюта в которой расчитываемся
 * Пример: 90 USD/RUR = доллары ЗА рубли = 90 рублей за 1 доллар
 * #TODO ссыль на стандарт, почему именно так принято делать
 */
DROP TYPE IF EXISTS currency_rate_type CASCADE;
CREATE TYPE currency_rate_type AS (
    rate     NUMERIC
    ,"base"  currency_code
    ,"quote" currency_code
);


-- SELECT (95, 'USD', 'RUR')::currency_rate_type;
 -- SELECT NULL::currency_rate_type;

DROP DOMAIN IF EXISTS currency_rate CASCADE;
CREATE DOMAIN currency_rate AS currency_rate_type 
        CHECK (((VALUE).rate IS NOT NULL AND (VALUE).rate > 0) AND (VALUE).base != (VALUE).quote);

-- SELECT (95, 'USD', 'RUR')::currency_rate;
-- SELECT NULL::currency_rate;

    
DROP TYPE IF EXISTS trade_limit_type CASCADE;
CREATE TYPE trade_limit_type AS (
    direction     direction_type
    ,rate         currency_rate
);

-- SELECT ('SELL', (90, 'USD', 'RUR'))::trade_limit_type;
-- SELECT NULL::trade_limit_type;

