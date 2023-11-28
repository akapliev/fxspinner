
SELECT *, (trade).amount FROM registry;


CALL update_balance();

WITH tmp1 AS (SELECT id 
                     ,client 
                     ,trade 
                     ,closest_quote((trade).direction, ((trade).rate)."base", ((trade).rate)."quote", time) AS ref_rate
                     ,latest_limit(client, (trade).direction, ((trade).rate)."base", ((trade).rate)."quote", time) AS ref_limit
                     ,balance 
                     ,balance_price
                     ,pl AS overall_pl
                FROM balance
               --WHERE ((trade).amount).code != 'EUR'
               ORDER BY time ASC, id ASC),
    tmp2 AS  (SELECT * 
                     ,(CASE (trade).direction WHEN 'SELL' THEN 1 ELSE -1 END ) * (((trade).amount @ ((trade).rate)) - ((trade).amount @ ref_rate))::currency_amount_type as tr_cost
                FROM tmp1)
SELECT id
       ,client
       ,trade
       ,ref_rate
       ,ref_limit
       ,(trade).rate > ref_limit AS overlimit
       ,balance
       ,balance_price
       ,overall_pl
       ,tr_cost
       ,-round(100 * tr_cost % ((trade).amount @ (trade).rate), 2) AS loss_perc
       ,overall_pl - tr_cost AS gain
  FROM tmp2;