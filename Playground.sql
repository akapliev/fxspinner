CALL update_balance();

SELECT 
    (trade).direction
    ,((trade).amount).code || ' ' ||  round(((trade).amount).amount, 2)::varchar  AS trade
    ,round(((trade).rate).rate, 2)::varchar || ' ' || ((trade).rate).base || '/' || ((trade).rate).quote AS trade_price
    ,round((ref_rate).rate, 2)::varchar || ' ' || (ref_rate).base || '/' || (ref_rate).quote AS market_price
    ,(balance).code || ' ' ||  round((balance).amount, 2)::varchar  AS balance
    ,round((ref_limit).rate, 2)::varchar || ' ' || (ref_limit).base || '/' || (ref_limit).quote AS "limit"
    ,overlimit
FROM extended_balance();