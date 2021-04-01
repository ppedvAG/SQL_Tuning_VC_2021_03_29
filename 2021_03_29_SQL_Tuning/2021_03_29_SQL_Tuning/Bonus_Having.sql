-- Having



-- Having brauchen wir immer dann, wenn wir mit etwas vergleichen möchten, das erst durch eine Aggregatfunktion berechnet wird

-- Wir wollen alle Bestellungen ausgeben, bei denen die Rechnungssumme größer ist als ein bestimmter Wert.

-- Wie bekommen wir die Rechnungssumme?

SELECT	  o.OrderID
		, CAST(SUM(od.UnitPrice*od.Quantity*(1-od.Discount))+Freight AS money) AS [Rechnungssumme]
FROM [Order Details] od INNER JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY o.OrderID, Freight



-- Wir wollen alle Bestellungen ausgeben, bei denen die Rechnungssumme größer ist als ein bestimmter Wert. (z.B. 500)

SELECT	  o.OrderID
		, CAST(SUM(od.UnitPrice*od.Quantity*(1-od.Discount))+Freight AS money) AS [Rechnungssumme]
FROM [Order Details] od INNER JOIN Orders o ON od.OrderID = o.OrderID
-- WHERE CAST(SUM(od.UnitPrice*od.Quantity*(1-od.Discount))+Freight AS money) > 500
-- hier können wir nicht mit WHERE arbeiten!
GROUP BY o.OrderID, Freight
HAVING CAST(SUM(od.UnitPrice*od.Quantity*(1-od.Discount))+Freight AS money) > 500
ORDER BY Rechnungssumme




-- Wieviele Kunden gibts pro Land?
-- Nur die ausgeben, wo mehr als 5 Kunden in einem Land ansässig sind
-- meiste Kunden zuerst

SELECT	  Country
		, COUNT(CustomerID) AS Anzahl
FROM Customers
GROUP BY Country
HAVING COUNT(CustomerID) > 5
ORDER BY Anzahl DESC



