-- 1. Northwind’s HR team is performing an analysis of managers at Northwind,
-- to see if there are wide disparities between the responsibilities of different managers.
-- List each manager at Northwind, along with the number of employees they manage,
-- the number of regions and territories they oversee,
-- the number of orders their reports have processed,
-- and the number of customers associated with these orders.

SELECT	re.firstname || ' ' || re.lastname AS manager_name,
		COUNT(DISTINCT t.regionid) AS regions,
		COUNT(DISTINCT e.employeeid) AS employees,
		COUNT(DISTINCT t.territoryid) AS territories,
		COUNT(DISTINCT o.orderid) AS orders,
		COUNT(DISTINCT o.customerid) AS customers
FROM employees e
JOIN employees re
	ON re.employeeid = e.reportsto
JOIN employeeterritories et
	ON et.employeeid = e.employeeid
JOIN territories t
	ON t.territoryid = et.territoryid
JOIN region r
	ON r.regionid = t.regionid
JOIN orders o
	ON o.employeeid = e.employeeid
GROUP BY 1;

-- 2. For orders by German customers, list in chronoogical order their order IDs, order dates,
-- order totals (quantity x unitprice with discount applied), running order total, and average
-- order total. Sort by average order total in descending order.

SELECT	abc.*,
		SUM(order_total) OVER (ORDER BY orderdate, orderid) AS running_total,
		AVG(order_total) OVER (ORDER BY orderdate, orderid) AS average_order_total
FROM	(SELECT	o.orderid,
				o.orderdate,
				SUM(od.unitprice * od.quantity * (1-od.discount)) AS order_total
		FROM orders AS o
		JOIN orderdetails AS od
			USING(orderid)
		JOIN customers AS c
			USING(customerid)
		WHERE c.country = 'Germany'
		GROUP BY o.orderid, o.orderdate) AS abc
-- ORDER BY orderdate, orderid
order by average_order_total desc
LIMIT 10;

-- 3. List out each employee, the number of orders they have processed, the percentage of total
-- order volume that employee has contributed to, and also the difference between their order
-- number and the average orders per employee. Categorize employees with under 50 orders
-- as Associates, 51-100 orders as Senior Associates, and 101+ as Principals. Order by the
-- number of orders processed per employee in descending order.

SELECT	*,
		num_order - (AVG(num_order) OVER ()) AS difference,
		(CASE	WHEN num_order < 50 THEN 'Associates'
		 		WHEN num_order <= 100 THEN 'Senior Associates'
				ELSE 'Principals' END)

FROM	(SELECT	DISTINCT	e.employeeid,
		 					CONCAT(e.firstname, ' ', e.lastname) AS fullname,
							COUNT(o.orderid) OVER (PARTITION BY e.employeeid) AS num_order,
							(COUNT(o.orderid) OVER (PARTITION BY e.employeeid))::NUMERIC / (COUNT(o.orderid) OVER ()) AS percentage_order
		FROM employees AS e
		LEFT JOIN orders AS o
			USING (employeeid)) AS abc

ORDER BY num_order DESC;

-- SELECT	*,
-- 		ROUND(orders / (SELECT SUM(orders) FROM (SELECT e.employeeid,
-- 												 		e.firstname || ’ ’ || e.lastname fullname,
-- 														COUNT(DISTINCT o.orderid) AS orders
-- 												FROM employe`es e
-- 												JOIN orders o
-- 												on e.employeeid = o.employeeid
-- 												GROUP BY 1, 2) as t2)::NUMERIC, 2) AS pct_of_order,`
-- 		ROUND(orders - (SELECT AVG(orders) FROM (SELECT e.employeeid,
-- 														e.firstname || ’ ’ || e.lastname fullname,
-- 														COUNT(DISTINCT o.orderid) AS orders
-- 														FROM employees e
-- 														JOIN orders o
-- 														on e.employeeid = o.employeeid
-- 														GROUP BY 1, 2) as t3)::NUMERIC, 2) AS order_differential,
-- 		CASE	WHEN orders >= 101 THEN ’Principal’
-- 				WHEN orders >= 51 THEN ’Senior Associate’
-- 				ELSE ’Associate’ END AS title
-- FROM	(SELECT e.employeeid, e.firstname || ’ ’ || e.lastname fullname,
-- 				COUNT(DISTINCT o.orderid) AS orders
-- 		FROM employees e
-- 		JOIN orders o
-- 		on e.employeeid = o.employeeid
-- 		GROUP BY 1, 2) as t1
-- ORDER BY 3 DESC
