-- Lab 02: Erstellen einer Prozedur

-- Info: Die CustomerID aus der Customers-Tabelle besteht aus 5 Buchstaben (datatype: nchar(5))
-- Die Prozedur soll:
	-- Kunden finden bei �bergabe eines Such-Kriteriums:

		-- EXEC CustomerSearch 'ALFKI'  --> findet den Kunden mit der ID 'ALFKI'
		-- EXEC CustomerSearch 'A'		--> findet alle Kunden, deren ID mit A beginnt
		-- EXEC CustomerSearch NULL		--> nur Spalten�berschriften, keine Ergebnisse
		-- EXEC CustomerSearch '%'		--> funktioniert, das '%' ist aber nicht notwendig
		-- EXEC CustomerSearch			--> gibt alle Kunden aus




-- Testen, ob die Prozedur funktioniert und die gew�nschten Ergebnisse zur�ckgibt:

EXEC CustomerSearch 'A' 
EXEC CustomerSearch 'ALFKI' 
EXEC CustomerSearch



-- Hinweise und h�ufige Fehler:
-- Ideen, wie man zur L�sung kommen k�nnte:

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
	-- EXEC TestSearch 'A%' funktioniert nicht wegen zu kurzer L�nge der Variablen
	-- NCHAR(5) = GENAU 5 Zeichen!


-- Die Variable muss nicht Datentypkonform sein - wir d�rfen einen etwas gr��eren Datentyp verwenden! L�uft stabiler und besser: weniger Einschr�nkung.


-- neue Idee:
ALTER PROCEDURE TestSearch @kdid varchar(10)  -- ein bisschen mehr Platz als notwendig
AS
SELECT * FROM KundenUmsatz WHERE CustomerID LIKE @kdid
GO

EXEC TestSearch 'ALFKI'
EXEC TestSearch 'A%' -- In einem Eingabefeld m�chte niemand ein Prozentzeichen schreiben!
EXEC TestSearch -- funktioniert nicht; erwartet die �bergabe eines Parameters
EXEC TestSearch '%' -- w�rde funktionieren, das macht aber keiner





-- L�SUNG:

	-- wir verwenden einen gr��eren Datentyp, als in der DB
	-- wir verwenden ein LIKE im WHERE
	-- wir setzen den Initialwert der Variable auf '%', damit auch nach "allen" Kunden gesucht werden kann beim Ausf�hren der Prozedur

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



