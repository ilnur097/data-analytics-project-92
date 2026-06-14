-- Этот запрос считает общее количество покупателей
SELECT --выбор столбца в финальной таблице
COUNT(customer_id) AS customers_count --подсчет количества покупателей
FROM customers; --основная таблица, откуда берется стобец

--Подготовьте в файл top_10_total_income.csv отчет с продавцами у которых наибольшая выручка
SELECT --выбор столбцов в финальной таблице
CONCAT(employees.first_name, ' ', employees.last_name) AS seller, --склеивание двух столбцов в один  
COUNT(*) as operations, --подсчет общего количества строк(в данном случае кол-во сделок)
FLOOR(SUM(price*quantity)) as income --подсчет выручки продавца с округлением в меньшую сторону
FROM employees --основная таблица
INNER JOIN sales on employee_id = sales_person_id --добавляем таблицу sales с помощью общего столбца 
INNER JOIN products on products.product_id = sales.product_id --добавляем таблицу products с помощью общего столбца
group BY CONCAT(employees.first_name, ' ', employees.last_name) --группируем данные по продавцу, чтобы были уникальные значения
order BY income desc --сортируем по убыванию выручки
LIMIT 10; --отображаем 10 строк

--Подготовьте в файл lowest_average_income.csv отчет с продавцами, чья выручка ниже средней выручки всех продавцов
SELECT --выбор столбцов в финальной таблице
CONCAT(e.first_name, ' ', e.last_name) AS seller, --объединение двух столбцов в один
FLOOR(AVG(p.price*s.quantity)) as average_income --подсчет средней выручки по продавцам, округлив до меньшего
FROM employees e --основная таблица
INNER JOIN sales s on employee_id = sales_person_id --добавляем таблицу sales с помощью общего столбца
INNER JOIN products p on p.product_id = s.product_id --добавляем таблицу products с помощью общего столбца
group BY CONCAT(e.first_name, ' ', e.last_name) --группируем данные по продавцам
having AVG(p.price*s.quantity) < ( --условие что, среднее по продавцам будет меньше , чем среднее по общей выручки с внутренним запросом
select --выбор столбца с внутренним запросом
AVG (p2.price*s2.quantity) --среднее по общей выручки
from sales s2 --основная таблица во внутреннем запросе
inner join products p2 on p2.product_id = s2.product_id --добавляем таблицу products с помощью общего столбца
)
order by average_income; --сортируем по возрастанию средней выручки по продавцам



--Подготовьте в файл day_of_the_week_income.csv отчет с данными по выручке по каждому продавцу и дню недели
SELECT --выбор столбцов в финальной таблице
CONCAT(e.first_name, ' ', e.last_name) AS seller, --объединение двух столбцов в один
TO_CHAR(sale_date, 'FMday') as day_of_week, --преобразование даты в день недели
FLOOR(SUM(p.price*s.quantity)) as income --подсчет средней выручки по продавцам, округлив до меньшего
FROM employees e  --основная таблица
INNER JOIN sales s on employee_id = sales_person_id --добавляем таблицу sales с помощью общего столбца
INNER JOIN products p on p.product_id = s.product_id --добавляем таблицу products с помощью общего столбца
group BY CONCAT(e.first_name, ' ', e.last_name), TO_CHAR(sale_date, 'FMday'), TO_CHAR(sale_date, 'ID') --группируем данные по продавцам и по дням недели
order by seller, TO_CHAR(sale_date, 'ID') ; --сортируем по продавцам по алфавиту и по дням недели по идентификатору ID(напр:1=monday)
