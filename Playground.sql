
SELECT *, (trade).amount FROM registry;


CALL update_balance();

WITH tmp1 AS (SELECT id 
                     ,client 
                     ,trade 
                     ,closest_quote((trade).direction, ((trade).rate)."base", ((trade).rate)."quote", time) AS reference_rate
                     ,balance 
                     ,balance_price
                     ,pl
                FROM balance
               WHERE ((trade).amount).code = 'EUR'
               ORDER BY time ASC, id ASC),
    tmp2 AS  (SELECT * 
                     ,(CASE (trade).direction WHEN 'SELL' THEN 1 ELSE -1 END ) * (((trade).amount @ ((trade).rate)) - ((trade).amount @ reference_rate)) as pl_transaction
                FROM tmp1)
SELECT *,
       pl - pl_transaction AS pl_time
  FROM tmp2;

  
-- надо обработать NULLS в операторах