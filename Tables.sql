/* Таблица со сделками. Каждый клиент вносит свои сделки
 */

DROP TABLE IF EXISTS registry;
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
DROP TABLE IF EXISTS limits;
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
DROP TABLE IF EXISTS quotes;
CREATE TABLE IF NOT EXISTS quotes (
    id         serial
    ,time      timestamp DEFAULT now()            -- время снятия данных
    ,direction trade_direction                    -- направление котировки (покупаем или продаем)
    ,rate      currency_rate                      -- котировка валютной пары
    ,"source"  varchar                            -- источник данных (пока varchar, потом подумаем)
    ,PRIMARY KEY (id, time)
);


/* Таблица с балансами. Считается функцией
 */
DROP TABLE IF EXISTS balance;
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
