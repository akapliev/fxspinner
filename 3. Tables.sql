/* Таблица с установленными порогами на операцию
 * чтобы каждому клиенту можно было сопоставить 
 *  - направление, 
 *  - пороговое значение,
 *  - валютную пару, для которой устанавливается порог
 * нужна чтобы верещать вовремя по своей логике для каждого клиента
 */
DROP TABLE IF EXISTS limits;
CREATE TABLE IF NOT EXISTS limits (
    id         serial
    ,time      timestamp DEFAULT now()            -- время установления лимита
    ,client    varchar NOT NULL                   -- клиент
    ,"limit"   trade_limit_type
    ,PRIMARY KEY (id, time)                       -- -- лимит установленный для данного клиента по сделком в даннном направлении
);


--SELECT * FROM limits;
--SELECT *, (("limit").rate).rate FROM limits;


/* Информационная таблица с котировками из разных источников*/
DROP TABLE IF EXISTS quotes;
CREATE TABLE IF NOT EXISTS quotes (
    id         serial
    ,time      timestamptz DEFAULT now()            -- время снятия данных
    ,direction direction_type NOT NULL                    -- направление котировки (покупаем или продаем)
    ,rate      currency_rate                      -- котировка валютной пары
    ,"source"  varchar                            -- источник данных (пока varchar, потом подумаем)
    ,PRIMARY KEY (id, time)
);

--SELECT * FROM quotes;

/* Таблица со сделками. Каждый клиент вносит свои сделки*/
DROP TABLE IF EXISTS registry;
CREATE TABLE IF NOT EXISTS registry(
    id           serial
    ,time        timestamptz DEFAULT now()           -- время сделки
    ,client      varchar NOT NULL                    -- клент
    ,trade       trade_type NOT NULL
           CHECK (((trade).amount).amount >= 0                   -- не должен быть отрицательным
                 AND (((trade).amount).code IN (((trade).rate).base, ((trade).rate)."quote") -- валюта сделки и котировка друг другу релевантны
                 AND ((trade).amount).code != 'RUR')             -- проверяем что не по покупке рубля за рубль    
                 AND ('RUR' IN (((trade).rate).base, ((trade).rate)."quote")))
    ,payload      JSONB                              -- тут пэйлоад схема-специфичный для каждого клиента
    ,deleted      boolean DEFAULT FALSE             -- пометка о сторнировании операции
    ,PRIMARY KEY (id, time)
);

SELECT * FROM registry;

/* таблица обогащенная данными о баланс строится процедуркой каждый раз с нуля */
DROP TABLE IF EXISTS balance;
CREATE TABLE IF NOT EXISTS balance(
    id             bigint
    ,time          timestamptz DEFAULT now()
    ,client        varchar NOT NULL
    ,trade         trade_type NOT NULL
    ,payload       JSONB
    ,balance       currency_amount     CHECK (((trade).amount).code = (balance).code)
    ,balance_price currency_rate       CHECK (ARRAY[(balance_price)."quote", (balance_price)."base"] @> ARRAY[((trade).rate).base, ((trade).rate)."quote"] 
                                              AND  
                                              ARRAY[(balance_price)."quote", (balance_price)."base"] <@ ARRAY[((trade).rate).base, ((trade).rate)."quote"])
    ,pl           currency_amount      CHECK  ((pl).code = 'RUR')

    ,PRIMARY KEY (id, time)
);

