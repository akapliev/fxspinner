/* Операторы над типами */

/* Absolute value */
DROP FUNCTION IF EXISTS abs(currency_amount) CASCADE;
CREATE OR REPLACE FUNCTION abs(amount currency_amount)
RETURNS currency_amount
AS
$$
    SELECT (abs((amount).amount), (amount).code)::currency_amount;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Функция сложения двух величин в одной валюте */
DROP FUNCTION IF EXISTS add_currencies(currency_amount currency_amount) CASCADE;
CREATE OR REPLACE FUNCTION add_currencies(amount1 currency_amount, amount2 currency_amount)
RETURNS currency_amount_type
AS
$$
    SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::currency_amount
                ELSE ((amount1).amount + (amount2).amount, (amount1).code)::currency_amount
           END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Оператор сложения */
DROP OPERATOR IF EXISTS + (currency_amount, currency_amount) CASCADE;
CREATE OPERATOR + (FUNCTION = add_currencies, LEFTARG = currency_amount, RIGHTARG = currency_amount)
);

/* Функция вычитания двух величин в одной валюте 
 */
DROP FUNCTION IF EXISTS subtract_currencies(currency_amount, currency_amount) CASCADE;
CREATE OR REPLACE FUNCTION subtract_currencies(amount1 currency_amount, amount2 currency_amount)
RETURNS currency_amount_type
AS
$$
    SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::currency_amount
                ELSE ((amount1).amount - (amount2).amount, (amount1).code)::currency_amount
           END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Оператор вычитания */
DROP OPERATOR IF EXISTS - (currency_amount, currency_amount) CASCADE;
CREATE OPERATOR - (FUNCTION = subtract_currencies, LEFTARG = currency_amount, RIGHTARG = currency_amount);

/* Функции и операторы сравнения */
/* Функция равенства */
DROP FUNCTION IF EXISTS equal(amount1 currency_amount, amount2 currency_amount) CASCADE;
CREATE OR REPLACE FUNCTION equal(amount1 currency_amount, amount2 currency_amount)
RETURNS boolean
AS
$$
    SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::boolean
                ELSE (amount1).amount = (amount2).amount
           END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* оператор равенства */
DROP OPERATOR IF EXISTS = (currency_amount, currency_amount) CASCADE;
CREATE OPERATOR = (FUNCTION = equal, LEFTARG = currency_amount, RIGHTARG = currency_amount));

/* функция неравенства */
DROP FUNCTION IF EXISTS not_equal(amount1 currency_amount, amount2 currency_amount) CASCADE;
CREATE OR REPLACE FUNCTION not_equal(amount1 currency_amount, amount2 currency_amount)
RETURNS boolean
AS
$$
    SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::boolean
                ELSE (amount1).amount != (amount2).amount
            END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* оператор неравенства */
DROP OPERATOR IF EXISTS != (currency_amount, currency_amount) CASCADE;
CREATE OPERATOR != (FUNCTION = not_equal, LEFTARG = currency_amount, RIGHTARG = currency_amount);

/* функция строго меньше */
DROP FUNCTION IF EXISTS less_then(currency_amount, currency_amount) CASCADE;
CREATE OR REPLACE FUNCTION less_then(amount1 currency_amount, amount2 currency_amount)
RETURNS boolean
AS
$$
    SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::boolean
                ELSE (amount1).amount < (amount2).amount
        END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Оператор строго меньше */
DROP OPERATOR IF EXISTS < (currency_amount, currency_amount) CASCADE;
CREATE OPERATOR < (FUNCTION = less_then, LEFTARG = currency_amount, RIGHTARG = currency_amount);

/* Функция строго больше */
DROP FUNCTION IF EXISTS greater_then(currency_amount, currency_amount) CASCADE;
CREATE OR REPLACE FUNCTION greater_then(amount1 currency_amount, amount2 currency_amount)
RETURNS boolean
AS
$$
    SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::boolean
                ELSE (amount1).amount > (amount2).amount
            END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Оператор строго больше */
DROP OPERATOR IF EXISTS > (currency_amount, currency_amount) CASCADE;
CREATE OPERATOR > (FUNCTION = greater_then, LEFTARG = currency_amount, RIGHTARG = currency_amount);

/* Функция меньше или равно */
DROP FUNCTION IF EXISTS less_or_equal_then(currency_amount, currency_amount) CASCADE;
CREATE OR REPLACE FUNCTION less_or_equal_then(amount1 currency_amount, amount2 currency_amount)
RETURNS boolean
AS
$$
    SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::boolean
                ELSE (amount1).amount <= (amount2).amount
            END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Оператор меньше или равно */
DROP OPERATOR IF EXISTS <= (currency_amount, currency_amount) CASCADE;
CREATE OPERATOR <= (FUNCTION = less_or_equal_then, LEFTARG = currency_amount, RIGHTARG = currency_amount);

/* Функция больше или равно */
DROP FUNCTION IF EXISTS greater_or_equal_then(currency_amount, currency_amount) CASCADE;
CREATE OR REPLACE FUNCTION greater_or_equal_then(amount1 currency_amount, amount2 currency_amount)
RETURNS boolean
AS
$$
    SELECT CASE WHEN (amount1).code != (amount2).code THEN NULL::boolean
                ELSE (amount1).amount >= (amount2).amount
           END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Оператор больше или равно*/
DROP OPERATOR IF EXISTS >= (currency_amount, currency_amount) CASCADE;
CREATE OPERATOR >= (FUNCTION = greater_or_equal_then, LEFTARG = currency_amount, RIGHTARG = currency_amount);

/* Функция левого умножения */
DROP FUNCTION IF EXISTS multiply(numeric, currency_amount) CASCADE;
CREATE OR REPLACE FUNCTION multiply(coef numeric, amount currency_amount)
RETURNS currency_amount
AS
$$
    SELECT (coef * (amount).amount, (amount)."code");
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Оператор левого умножения */
DROP OPERATOR IF EXISTS * (numeric, currency_amount) CASCADE;
CREATE OPERATOR * (FUNCTION = multiply, LEFTARG = numeric, RIGHTARG = currency_amount);

/* Функция правого умножения */
DROP FUNCTION IF EXISTS multiply(currency_amount, numeric) CASCADE;
CREATE OR REPLACE FUNCTION multiply(amount currency_amount, coef numeric)
RETURNS currency_amount
AS
$$
    SELECT (coef * (amount).amount, (amount)."code");
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Оператор правого умножения */
DROP OPERATOR IF EXISTS * (currency_amount, numeric) CASCADE;
CREATE OPERATOR * (FUNCTION = multiply, LEFTARG = currency_amount, RIGHTARG = numeric);

/* Функция получения обратного курса */
DROP FUNCTION IF EXISTS inv(currency_rate) CASCADE;
CREATE OR REPLACE FUNCTION inv(rate currency_rate)
RETURNS currency_rate
AS
$$
    SELECT (1/(rate).rate::numeric, (rate)."quote", (rate)."base")::currency_rate;
$$ LANGUAGE SQL IMMUTABLE STRICT;


/* Функция конверсии заданной суммы в валюте по курсу в другую валюту */
DROP FUNCTION IF EXISTS convert(currency_amount, currency_rate) CASCADE;
CREATE OR REPLACE FUNCTION convert(amount currency_amount, rate currency_rate)
RETURNS currency_amount
AS 
$$
    SELECT CASE WHEN (amount).code = (rate)."quote" THEN (amount.amount / rate.rate, rate.base)::currency_amount
                WHEN (amount).code = (rate).base    THEN (amount.amount * rate.rate, rate."quote")::currency_amount
                ELSE NULL::currency_amount
            END;
$$ LANGUAGE SQL IMMUTABLE STRICT;


/* Оператор конверсии для удобства написания: amount @ rate =  amount */
DROP OPERATOR IF EXISTS * (currency_amount, currency_rate) CASCADE;
CREATE OPERATOR @ (FUNCTION = convert, LEFTARG = currency_amount, RIGHTARG = currency_rate);

/* Функция из двух сумм получает соответствующую им котировку  */
DROP FUNCTION IF EXISTS rate(currency_amount, currency_amount) CASCADE;
CREATE OR REPLACE FUNCTION rate(one currency_amount, two currency_amount)
RETURNS currency_rate
AS 
$$
    SELECT CASE WHEN (one).code != (one).code THEN NULL::currency_rate
                ELSE (abs(one.amount/two.amount), two.code, one.code)::currency_rate
            END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Оператор деления двух сумм который должен давать курс */
DROP OPERATOR IF EXISTS / (currency_amount, currency_amount) CASCADE;
CREATE OPERATOR / (FUNCTION = rate, LEFTARG = currency_amount, RIGHTARG = currency_amount);

/* Функция берет две котировки и получает результирующую (кросс-курс) */
DROP FUNCTION IF EXISTS crossrate(currency_rate, currency_rate) CASCADE;
CREATE OR REPLACE FUNCTION crossrate(rate1 currency_rate, rate2 currency_rate)
RETURNS currency_rate
AS
$$
SELECT CASE WHEN rate1."quote" = rate2."quote" THEN (rate1.rate / rate2.rate, rate1."base", rate2."base")::currency_rate
            WHEN rate1."quote" = rate2."base"  THEN (rate1.rate * rate2.rate, rate1."base", rate2."quote")::currency_rate
            WHEN rate1."base"  = rate2."quote" THEN (1 / (rate1.rate * rate2.rate), rate1."quote", rate2."base")::currency_rate
            WHEN rate1."base"  = rate2."base"  THEN (rate2.rate / rate1.rate, rate1."quote", rate2."quote")::currency_rate
            ELSE NULL::currency_rate
        END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

/* Оператор чтобы было курсы друг на друга помножать удобненько и единообразно rate @ rate = rate) */
DROP OPERATOR IF EXISTS @ (currency_rate, currency_rate) CASCADE;
CREATE OPERATOR @ (FUNCTION = crossrate, LEFTARG = currency_rate, RIGHTARG = currency_rate);


