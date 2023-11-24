TRUNCATE registry;
INSERT INTO registry (time, client, direction, trade, rate) VALUES
    ('2023-11-01 12:00 MSK', 'checkouter', 'SELL', (1000.00, 'CNY'), (11.00, 'CNY', 'RUR')),
    ('2023-11-02 12:00 MSK', 'checkouter', 'SELL', (500.00, 'CNY'), (12.00, 'CNY', 'RUR')),
    ('2023-11-03 12:00 MSK', 'checkouter', 'BUY',  (800.00, 'CNY'), (10.00, 'CNY', 'RUR')),
    ('2023-11-04 12:00 MSK', 'checkouter', 'BUY',  (800.00, 'CNY'), (10.50, 'CNY', 'RUR')),
    ('2023-11-05 12:00 MSK', 'checkouter', 'SELL', (500.00, 'USD'), (70.00, 'USD', 'RUR')),
    ('2023-11-06 12:00 MSK', 'checkouter', 'SELL', (250.00, 'USD'), (75.00, 'USD', 'RUR')),
    ('2023-11-07 12:00 MSK', 'checkouter', 'BUY',  (400.00, 'USD'), (65.00, 'USD', 'RUR')),
    ('2023-11-08 12:00 MSK', 'checkouter', 'BUY',  (400.00, 'USD'), (70.00, 'USD', 'RUR')),
    ('2023-11-09 12:00 MSK', 'checkouter', 'BUY',  (200.00, 'USD'), (99.00, 'USD', 'RUR')),
    ('2023-11-10 12:00 MSK', 'checkouter', 'BUY',  (1.00, 'IPH'), (1000.00, 'IPH', 'RUR')),
    ('2023-11-11 12:00 MSK', 'checkouter', 'BUY',  (1.00, 'IPH'), (1100.00, 'IPH', 'RUR')),
    ('2023-11-12 12:00 MSK', 'checkouter', 'BUY',  (1.00, 'IPH'), (1200.00, 'IPH', 'RUR')),
    ('2023-11-13 12:00 MSK', 'checkouter', 'BUY',  (3.00, 'IPH'), (900.00, 'IPH', 'RUR')),
    ('2023-11-14 12:00 MSK', 'checkouter', 'SELL', (10.00, 'IPH'), (900.00, 'IPH', 'RUR')),
    ('2023-11-15 12:00 MSK', 'checkouter', 'BUY',  (2.00, 'IPH'), (1000.00, 'IPH', 'RUR')),
    ('2023-11-16 12:00 MSK', 'checkouter', 'BUY',  (2.00, 'IPH'), (1000.00, 'IPH', 'RUR')),
    ('2023-11-17 12:00 MSK', 'checkouter', 'BUY',  (1.00, 'IPH'), (800.00, 'IPH', 'RUR')),
    ('2023-11-18 12:00 MSK', 'checkouter', 'SELL', (2.00, 'PSP'), (700.00, 'PSP', 'RUR')),
    ('2023-11-19 12:00 MSK', 'checkouter', 'BUY',  (1.00, 'PSP'), (600.00, 'PSP', 'RUR')),
    ('2023-11-20 12:00 MSK', 'checkouter', 'BUY',  (1.00, 'PSP'), (600.00, 'PSP', 'RUR'))
;

TRUNCATE limits;
INSERT INTO limits (time, client, direction, "limit") VALUES 
    ('2023-11-01 12:00 MSK', 'checkouter', 'BUY', (11.00, 'CNY', 'RUR')),
    ('2023-11-02 12:00 MSK', 'checkouter', 'SELL', (10.80, 'CNY', 'RUR')),
    ('2023-11-03 12:00 MSK', 'checkouter', 'BUY', (11.20, 'CNY', 'RUR')),
    ('2023-11-04 12:00 MSK', 'checkouter', 'SELL', (11.20, 'CNY', 'RUR')),
    ('2023-11-05 12:00 MSK', 'checkouter', 'BUY', (11.60, 'CNY', 'RUR')),
    ('2023-11-06 12:00 MSK', 'checkouter', 'SELL', (11.40, 'CNY', 'RUR'))
;

TRUNCATE quotes;
INSERT INTO quotes (time, direction, rate) VALUES
    ('2023-11-01 12:00 MSK', 'BUY', (10.00, 'CNY', 'RUR')),
    ('2023-11-02 12:00 MSK', 'BUY', (10.20, 'CNY', 'RUR')),
    ('2023-11-03 12:00 MSK', 'BUY', (10.40, 'CNY', 'RUR')),
    ('2023-11-04 12:00 MSK', 'BUY', (10.60, 'CNY', 'RUR')),
    ('2023-11-05 12:00 MSK', 'BUY', (10.80, 'CNY', 'RUR')),
    ('2023-11-06 12:00 MSK', 'BUY', (11.00, 'CNY', 'RUR')),
    ('2023-11-07 12:00 MSK', 'BUY', (11.20, 'CNY', 'RUR')),
    ('2023-11-08 12:00 MSK', 'BUY', (11.40, 'CNY', 'RUR')),
    ('2023-11-09 12:00 MSK', 'BUY', (11.60, 'CNY', 'RUR')),
    ('2023-11-10 12:00 MSK', 'BUY', (11.80, 'CNY', 'RUR')),
    ('2023-11-11 12:00 MSK', 'BUY', (12.00, 'CNY', 'RUR')),
    ('2023-11-12 12:00 MSK', 'BUY', (12.20, 'CNY', 'RUR')),
    ('2023-11-13 12:00 MSK', 'BUY', (12.40, 'CNY', 'RUR')),
    ('2023-11-14 12:00 MSK', 'BUY', (12.60, 'CNY', 'RUR')),
    ('2023-11-15 12:00 MSK', 'BUY', (12.80, 'CNY', 'RUR')),
    ('2023-11-16 12:00 MSK', 'BUY', (13.00, 'CNY', 'RUR')),
    ('2023-11-17 12:00 MSK', 'BUY', (13.20, 'CNY', 'RUR')),
    ('2023-11-18 12:00 MSK', 'BUY', (13.40, 'CNY', 'RUR')),
    ('2023-11-19 12:00 MSK', 'BUY', (13.60, 'CNY', 'RUR')),
    ('2023-11-20 12:00 MSK', 'BUY', (13.80, 'CNY', 'RUR')),
    ('2023-11-01 12:00 MSK', 'SELL', (9.80, 'CNY', 'RUR')),
    ('2023-11-02 12:00 MSK', 'SELL', (10.00, 'CNY', 'RUR')),
    ('2023-11-03 12:00 MSK', 'SELL', (10.20, 'CNY', 'RUR')),
    ('2023-11-04 12:00 MSK', 'SELL', (10.40, 'CNY', 'RUR')),
    ('2023-11-05 12:00 MSK', 'SELL', (10.60, 'CNY', 'RUR')),
    ('2023-11-06 12:00 MSK', 'SELL', (10.80, 'CNY', 'RUR')),
    ('2023-11-07 12:00 MSK', 'SELL', (11.00, 'CNY', 'RUR')),
    ('2023-11-08 12:00 MSK', 'SELL', (11.20, 'CNY', 'RUR')),
    ('2023-11-09 12:00 MSK', 'SELL', (11.40, 'CNY', 'RUR')),
    ('2023-11-10 12:00 MSK', 'SELL', (11.60, 'CNY', 'RUR')),
    ('2023-11-11 12:00 MSK', 'SELL', (11.80, 'CNY', 'RUR')),
    ('2023-11-12 12:00 MSK', 'SELL', (12.00, 'CNY', 'RUR')),
    ('2023-11-13 12:00 MSK', 'SELL', (12.20, 'CNY', 'RUR')),
    ('2023-11-14 12:00 MSK', 'SELL', (12.40, 'CNY', 'RUR')),
    ('2023-11-15 12:00 MSK', 'SELL', (12.60, 'CNY', 'RUR')),
    ('2023-11-16 12:00 MSK', 'SELL', (12.80, 'CNY', 'RUR')),
    ('2023-11-17 12:00 MSK', 'SELL', (13.00, 'CNY', 'RUR')),
    ('2023-11-18 12:00 MSK', 'SELL', (13.20, 'CNY', 'RUR')),
    ('2023-11-19 12:00 MSK', 'SELL', (13.40, 'CNY', 'RUR')),
    ('2023-11-20 12:00 MSK', 'SELL', (13.60, 'CNY', 'RUR'))
;
