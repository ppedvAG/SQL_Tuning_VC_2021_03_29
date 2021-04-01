-- Lab 01: Eine gro�e Datenmenge zum Testen generieren

-- Um im Laufe des Kurses bestimmte Tests durchf�hren zu k�nnen, ben�tigen wir gr��ere Datenmengen. Wir generieren eine Tabelle mit ~ 1 Mio Datens�tzen aus den Daten in der Northwind-�bungsdatenbank.

-- Wir w�hlen die Spalten, mit denen wir sp�ter vielleicht weitere Testabfragen durchf�hren wollen, aus und schreiben diese Information mittels SELECT > INTO in eine neue Tabelle.
-- Wahlweise kann diese neue Tabelle in der Northwind-DB selbst oder in einer Demo-Datenbank erstellt werden.

-- mit Demo-DB:

-- Erstellen der Demo-DB:
CREATE DATABASE Demo
GO

-- Sicherstellen, dass die neue Demo-DB verwendet wird:
USE Demo

-- Informationen aus Northwind-DB holen und in neue Tabelle KundenUmsatz in Demo-DB schreiben:
SELECT    c.CustomerID
		, c.CompanyName
		, c.ContactName
		, c.ContactTitle
		, c.City
		, c.Country
		, o.EmployeeID
		, o.OrderDate
		, o.freight
		, o.shipcity
		, o.shipcountry
		, o.OrderID
		, od.ProductID
		, od.UnitPrice
		, od.Quantity
		, p.ProductName
		, e.LastName
		, e.FirstName
		, e.birthdate
into Demo.dbo.KundenUmsatz
FROM	Northwind.dbo.Customers AS c
		INNER JOIN Northwind.dbo.Orders AS o ON c.CustomerID = o.CustomerID
		INNER JOIN Northwind.dbo.Employees AS e ON o.EmployeeID = e.EmployeeID
		INNER JOIN Northwind.dbo.[Order Details] AS od ON o.orderid = od.orderid
		INNER JOIN Northwind.dbo.Products AS p ON od.productid = p.productid



-- ODER (nur Northwind-DB):
-- soll die Tabelle einfach in der Northwind-DB erstellt werden, dann k�nnen wir die DB-Angaben aus dem SELECT-INTO weglassen:
/*
USE Northwind

SELECT    c.CustomerID
		, c.CompanyName
		, c.ContactName
		, c.ContactTitle
		, c.City
		, c.Country
		, o.EmployeeID
		, o.OrderDate
		, o.freight
		, o.shipcity
		, o.shipcountry
		, od.OrderID
		, od.ProductID
		, od.UnitPrice
		, od.Quantity
		, p.ProductName
		, e.LastName
		, e.FirstName
		, e.birthdate
into KundenUmsatz
FROM	Customers AS c
		INNER JOIN Orders AS o ON c.CustomerID = o.CustomerID
		INNER JOIN Employees AS e ON o.EmployeeID = e.EmployeeID
		INNER JOIN [Order Details] AS od ON o.orderid = od.orderid
		INNER JOIN Products AS p ON od.productid = p.productid
*/


-- Nun haben wir eine Tabelle mit 2155 Datens�tzen, das ist uns noch viel zu wenig!
-- Da f�r unsere Tests nur die Menge, nicht die Daten selbst wichtig sind, verdoppeln wir die vorhandenen Daten so lange, bis wir die gew�nschte Datenmenge erreicht haben:

INSERT INTO dbo.KundenUmsatz
SELECT * FROM dbo.KundenUmsatz
GO 9								-- 9 Wiederholungen ergeben ~ 1.1Mio Datens�tze


