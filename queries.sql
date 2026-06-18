-- Этот запрос считает общее количество покупателей
SELECT --выбор столбца в финальной таблице
COUNT(customer_id) AS customers_count --подсчет количества покупателей
FROM customers; --основная таблица, откуда берется стобец

--Подготовьте в файл top_10_total_income.csv отчет с продавцами у которых наибольшая выручка
SELECT --выбор столбцов в финальной таблице
CONCAT(employees.first_name, ' ', employees.last_name) AS seller, --склеивание двух столбцов в один  
COUNT(*) as operations, --подсчет общего количества строк(в данном случае кол-во сделок)
FLOOR(SUM(price*quantity)) as income --подсчет выручки продавца с округлением в меньшую сторону
FROM sales --основная таблица
INNER JOIN employees on employee_id = sales_person_id --добавляем таблицу employees с помощью общего столбца 
INNER JOIN products on products.product_id = sales.product_id --добавляем таблицу products с помощью общего столбца
group BY CONCAT(employees.first_name, ' ', employees.last_name) --группируем данные по продавцу, чтобы были уникальные значения
order BY income desc --сортируем по убыванию выручки
LIMIT 10; --отображаем 10 строк

--Подготовьте в файл lowest_average_income.csv отчет с продавцами, чья выручка ниже средней выручки всех продавцов
SELECT --выбор столбцов в финальной таблице
CONCAT(e.first_name, ' ', e.last_name) AS seller, --объединение двух столбцов в один
FLOOR(AVG(p.price*s.quantity)) as average_income --подсчет средней выручки по продавцам, округлив до меньшего
FROM sales s --основная таблица
INNER JOIN employees e employee_id = sales_person_id --добавляем таблицу employees с помощью общего столбца
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
FROM sales s  --основная таблица
INNER JOIN employees e on employee_id = sales_person_id --добавляем таблицу employees с помощью общего столбца
INNER JOIN products p on p.product_id = s.product_id --добавляем таблицу products с помощью общего столбца
group BY CONCAT(e.first_name, ' ', e.last_name), TO_CHAR(sale_date, 'FMday'), TO_CHAR(sale_date, 'ID') --группируем данные по продавцам и по дням недели
order by seller, TO_CHAR(sale_date, 'ID') ; --сортируем по продавцам по алфавиту и по дням недели по идентификатору ID(напр:1=monday)


--Подготовьте в файл age_groups.csv с возрастными группами покупателей
SELECT --выбор столбцов в финальной таблице
CASE  --условная конструкция
WHEN age>=16 and age<=25 then '16-25' --1 условие
WHEN  age>=26 and age<=40 THEN '26-40' --2 условия
ELSE '40+' --все остальное
END AS age_category, --завершение и название столбца
count(age) as age_count --кол-во человек в возрастной категории
from customers --основная таблица
group by CASE -- группируем по возрастной категории
WHEN age>=16 and age<=25 then '16-25'
WHEN  age>=26 and age<=40 THEN '26-40'
ELSE '40+'
END
order by age_category; --сортируем по возр категории от меньшего к большему 


--Подготовьте в файл customers_by_month.csv с количеством покупателей и выручкой по месяцам
SELECT --выбор столбцов в финальной таблице
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,  --изменение формата даты год-месяц
    COUNT(DISTINCT s.customer_id) AS total_customers, --подсчет общего кол-ва уникальных клиентов
    FLOOR(SUM(p.price * s.quantity)) AS income       --общая выручка         
FROM sales s --основная таблица
INNER JOIN products p ON s.product_id = p.product_id --присоединяем таблицу products по общему полю
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')           -- группиируем по дате    
ORDER BY selling_month; --сортируем по возрастанию даты



--Подготовьте в файл special_offer.csv с покупателями первая покупка которых пришлась на время проведения специальных акций
WITH ranked_sales AS ( --создаем виртуальную таблицу
    SELECT --выбор столбцов в виртуальной таблице
        CONCAT(c.first_name, ' ', c.last_name) AS customer, --объединение 2 столбцов в 1
        s.sale_date, 
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        p.price,
        c.customer_id,
        ROW_NUMBER() OVER ( --используем оконную функцию
            PARTITION BY s.customer_id --группируем по покупателю
            ORDER BY s.sale_date --сортировка по дате
        ) AS rn
    FROM sales s
    INNER JOIN customers c ON c.customer_id = s.customer_id  --присоединяем таблицу с общими столбцами
    INNER JOIN employees e ON e.employee_id = s.sales_person_id --присоединяем таблицу с общими столбцами
    INNER JOIN products p ON s.product_id = p.product_id --присоединяем таблицу с общими столбцами
)
SELECT --выбор столбцов в финальной таблице
    customer, 
    sale_date, 
    seller
FROM ranked_sales --основная виртуальная таблица
WHERE rn = 1     --условие , что покупка первая и цена 0     
  AND price = 0       
ORDER BY customer_id; --сортируем по ид покупателя
