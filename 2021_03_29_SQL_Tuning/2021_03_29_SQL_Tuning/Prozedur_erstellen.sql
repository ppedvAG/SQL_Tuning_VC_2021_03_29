-- Lab 02: Erstellen einer Prozedur

-- Info: Die CustomerID aus der Customers-Tabelle besteht aus 5 Buchstaben (datatype: nchar(5))
-- Die Prozedur soll:
	-- Kunden finden bei Übergabe eines Such-Kriteriums:

		-- EXEC CustomerSearch 'ALFKI'  --> findet den Kunden mit der ID 'ALFKI'
		-- EXEC CustomerSearch 'A'		--> findet alle Kunden, deren ID mit A beginnt
		-- EXEC CustomerSearch NULL		--> nur Spaltenüberschriften, keine Ergebnisse
		-- EXEC CustomerSearch '%'		--> funktioniert, das '%' ist aber nicht notwendig
		-- EXEC CustomerSearch			--> gibt alle Kunden aus




-- Testen, ob die Prozedur funktioniert und die gewünschten Ergebnisse zurückgibt:

EXEC CustomerSearch 'A' 
EXEC CustomerSearch 'ALFKI' 
EXEC CustomerSearch



-- Hinweise und häufige Fehler:
-- Ideen, wie man zur Lösung kommen könnte:

-- erste Idee...:
CREATE PROCEDURE TestSearch @kdid nchar(5)
AS
SELECT * FROM KundenUmsatz WHERE CustomerID = @kdid
GO

-- damit bekommen wir mehrere Probleme:
	-- kein =, sondern ein LIKE im WHERE verwenden!

-- neue Idee:
ALTER PROCEDURE TestSearch @kdid nchar(5)
AS
SELECT * FROM KundenUmsatz WHERE CustomerID LIKE @kdid
GO

-- neues Problem:
	-- EXEC TestSearch 'A%' funktioniert nicht wegen zu kurzer Länge der Variablen
	-- NCHAR(5) = GENAU 5 Zeichen!


-- Die Variable muss nicht Datentypkonform sein - wir dürfen einen etwas größeren Datentyp verwenden! Läuft stabiler und besser: weniger Einschränkung.


-- neue Idee:
ALTER PROCEDURE TestSearch @kdid varchar(10)  -- ein bisschen mehr Platz als notwendig
AS
SELECT * FROM KundenUmsatz WHERE CustomerID LIKE @kdid
GO

EXEC TestSearch 'ALFKI'
EXEC TestSearch 'A%' -- In einem Eingabefeld möchte niemand ein Prozentzeichen schreiben!
EXEC TestSearch -- funktioniert nicht; erwartet die Übergabe eines Parameters
EXEC TestSearch '%' -- würde funktionieren, das macht aber keiner





-- LÖSUNG:

	-- wir verwenden einen größeren Datentyp, als in der DB
	-- wir verwenden ein LIKE im WHERE
	-- wir setzen den Initialwert der Variable auf '%', damit auch nach "allen" Kunden gesucht werden kann beim Ausführen der Prozedur

-- in der Demo-DB mit KundenUmsatz-Tabelle:
CREATE PROCEDURE CustomerSearch @kdid varchar(10) = '%'
AS
SELECT * FROM KundenUmsatz WHERE CustomerID LIKE @kdid + '%'
GO

-- in Northwind-DB mit Customers-Tabelle:
/*
CREATE PROCEDURE CustomerSearch @kdid varchar(10) = '%'
AS
SELECT * FROM Customers WHERE CustomerID LIKE @kdid + '%'
GO
*/



