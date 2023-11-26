# fxspinner
FX Spinner (MVP) - прототип валютной крутилки. Реализация на PostgreSQL.
## Валюта
валютный код согласно стандарту  ISO
### Пример
USD, EUR, RUR, CNY, TRY ...
### Ограничения
строго только три заглавные буквы 
## Валютная сумма
Пара 
* сумма (число)
* валюта (код валюты)
### Пример
1000 EUR, USD 15.50, 200 RUR
### Ограничения
Не можеть быть NULL в отдельных компонентах
### Операции
Опеределены только над суммами номинированными в одной валюте. Приоритета операций нет (задаем руками).
* "+" сложение (симметрично) ~ валютная сумма
* "-" вычитание (симметрично) ~ валютная сумма
* "*" умножение на число (слева) ~ валютная сумма
* "*" умножение на число (справа) ~ валютная сумма
* "<", ">", "=", "!=", ">=", "<=" сравнения ~ логическое значение
## Валютный курс
Строго положительное отношение двух сумм номинированных строго в разных валютах
Базовая валюта (base currency) - ту которую покупаем
Валюта цены (quote currency) - та, в которой выражена величина
1 единица базовой валюты = X единиц валюты цены
### Пример
* 95 USD/RUR
    * Курс (rate) - 95 RUR за 1 USD
    * Base - USD
    * Quote - RUR
* 0.01052632 USD/RUR
    * Курс (rate) - 0.01052632 USD за 1 RUR
    * Base - RUR
    * Quote - USD
### Операции
* Обратный курс - замена Base и Quote
    Пример: 95 USD/RUR = 0.01052632 RUR/USD
* Валютная сумма @ валютный курс - пересчет из одной валюты в другую ~ валютная сумма, в другой валюте
    Определена только если валюта в валютной сумме соответвует либо базовой валюте либо валюте цены
    Пример: 10000 RUR @ 95 USD/RUR = 95 USD, 10000 RUR @ 0.01052632 RUR/USD = 95 USD 
* валютный курс @ валютный курс  ~ валютный курс (кросс-курс)
    Определена только если базовые валюты и валюты цены обоих курсов пересекаются по одному значению
    Пример: USD/RUR @ RUR/CNY = USD/CNY, USD/RUR @ CNY/RUR = USD/CNY
* посчитать курс из двух валютных сумм
    Валютные суммы должы быть номинированы в разных валютах
    Пример: 95000 RUR / 1000 USD = 95 USD/RUR или 95000 RUR, 1000 USD / 95000 RUR = 0.01052632 RUR/USD (не коммутативно)
## Сделка
Состоит из
* направления сделки - покупки или продажи (строго 'BUY' или 'SELL')
* валютной суммы
* валютного курса
### Ограничения
* Не может быть NULL в отдельных компонентах
* Валютный курс должен содержать код из валютной суммы
### Операции
* Расчет оттока денежных средста
### Пример
* SELL 1000 USD @ 95 USD/RUR = 95000 RUR 
* BUY 1000 USD @ 0.01052632 RUR/USD = -95000 RUR