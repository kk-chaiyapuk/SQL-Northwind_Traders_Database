# SQL-Northwind_Traders_Database

This project is based on a database from Northwind Traders, a company that imports and exports food globally. The database captures all the sales transactions between the company i.e. Northwind traders and its customers and the purchase transactions between Northwind and its suppliers.

<img width="510" alt="image" src="https://github.com/kk-chaiyapuk/SQL-Northwind_Traders_Database/assets/82194433/581f2af1-df64-4b75-87b6-7bb1d2b9b199">

## The number of orders each manager has processed is different

Northwind’s HR team is performing an analysis of managers at Northwind, to see if there are wide disparities between the responsibilities of different managers.

List each manager at Northwind, along with the number of employees they manage, the number of regions and territories they oversee, the number of orders their reports have processed, and the number of customers associated with these orders.

```sql
SELECT	re.firstname || ' ' || re.lastname AS manager_name,
	COUNT(DISTINCT t.regionid) AS regions,
	COUNT(DISTINCT e.employeeid) AS employees,
	COUNT(DISTINCT t.territoryid) AS territories,
	COUNT(DISTINCT o.orderid) AS orders,
	COUNT(DISTINCT o.customerid) AS customers
FROM employees AS e
JOIN employees AS re
	ON re.employeeid = e.reportsto
JOIN employeeterritories AS et
	ON et.employeeid = e.employeeid
JOIN territories AS t
	ON t.territoryid = et.territoryid
JOIN region AS r
	ON r.regionid = t.regionid
JOIN orders AS o
	ON o.employeeid = e.employeeid
GROUP BY 1
LIMIT 2;
```

manager_name  | regions | employees | territories | orders | customers
------------- | ------------- | ------------- | ------------- | ------------- | -------------
Andrew Fuller | 3 | 5 | 20 | **552** | 89
Steven Buchanan | 2 | 3 | 22 | **182** | 74

## aaaa

For orders by German customers, list in chronoogical order their order IDs, order dates, order totals (quantity x unitprice with discount applied), running order total, and average order total. Sort by average order total in descending order.

```sql
SELECT	orders_calculated.*,
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
	GROUP BY o.orderid, o.orderdate) AS orders_calculated

ORDER BY average_order_total desc
LIMIT 3;
```
orderid  | orderdate | order_total | running_total | average_order_total
------------- | ------------- | ------------- | ------------- | -------------
10267 |	1996-07-29 |	3536.60 |	6904.65 |	2301.55
10273 |	1996-08-05 |	2037.28 |	8941.93 |	2235.48
10277 |	1996-08-09 |	1200.80 |	10142.73 |	2028.55

## afaf

List out each employee, the number of orders they have processed, the percentage of total order volume that employee has contributed to, and also the difference between their order number and the average orders per employee.

Categorize employees with under 50 orders as Associates, 51-100 orders as Senior Associates, and 101+ as Principals. Order by the number of orders processed per employee in descending order.

```sql
SELECT	*,
	num_order - (AVG(num_order) OVER ()) AS difference,
	(CASE	WHEN num_order < 50 THEN 'Associates'
		WHEN num_order <= 100 THEN 'Senior Associates'
		ELSE 'Principals' END) AS job_level

FROM	(SELECT DISTINCT	e.employeeid,
				CONCAT(e.firstname, ' ', e.lastname) AS fullname,
				COUNT(o.orderid) OVER (PARTITION BY e.employeeid) AS num_order,
				(COUNT(o.orderid) OVER (PARTITION BY e.employeeid))::NUMERIC / (COUNT(o.orderid) OVER ()) AS percentage_order
	FROM employees AS e
	LEFT JOIN orders AS o
		USING (employeeid)) AS employee_aggregated

ORDER BY num_order DESC
LIMIT 5;
```

employeeid | fullname | num_order | percentage_order | difference | job_level
------------- | ------------- | ------------- | ------------- | ------------- | -------------
4 | Margaret Peacock | 156 | 0.1880 | 63.78 | Principals
3 | Janet Leverling | 127 | 0.1530 | 34.78 | Principals
1 | Nancy Davolio | 123 | 0.1482 | 30.78 | Principals
8 | Laura Callahan | 104 | 0.1253 | 11.78 | Principals
2 | Andrew Fuller | 96 | 0.1157 | 3.78 | Senior Associates
