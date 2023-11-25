/* Тип для хранения кода валюты (3 заглавные буквы, непустой) чтобы не чекать по типам отдельно
 */
DROP DOMAIN IF EXISTS currency_code CASCADE;
CREATE DOMAIN currency_code AS varchar(3) CHECK (VALUE IS NOT NULL AND VALUE ~ '^[A-Z]{3}$');


/* Тип для хранения направления сделки (BUY - покупка, SELL - продажа)
 */
DROP DOMAIN IF EXISTS trade_direction CASCADE;
CREATE DOMAIN trade_direction AS varchar(4) CHECK (VALUE IN ('BUY', 'SELL'));

/* Типы для хранения валютных сумм
 * currency amount  - тип для хранения отдельной сделки - не может быть <= 0
 * currency balance - тип для хранения баланса - может быть отрицательным
 */
DROP TYPE IF EXISTS currency_amount_type CASCADE;
CREATE TYPE currency_amount_type AS (amount numeric, code currency_code);
DROP DOMAIN IF EXISTS currency_amount CASCADE;
CREATE DOMAIN currency_amount AS currency_amount_type CHECK ((VALUE).amount IS NOT NULL);


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

