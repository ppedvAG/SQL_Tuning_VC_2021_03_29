-- ER-Diagramm


-- wir verwendet für DB-Planung
-- zur Kommunikation zwischen Kunde und Entwickler

-- mehrere Notationsformen (Chen, Min-Max, Crow's-Foot,...)

-- Entity wird zu Tabelle
-- Attribut wird zu Spalte

-- Beziehung wird aufgelöst (daraus kann auch eine Tabelle werden)






-- Normalformen

-- sollen Redundanz vermeiden
-- sollen auch Inkonsistenzen vermeiden
-- Kunde soll nicht weggelöscht werden, wenn wir eine Bestellung weglöschen (oder umgekehrt)


-- aber: NF können bewusst gebrochen werden, um die Abfrage schneller zu machen (weil dann weniger Datensätze angesehen werden müssen)


SELECT ContactName
FROM Customers



/*

	1 MIO Kunden  ... jeder im Durchschnitt 3 Bestellungen

	3 MIO Orders  ... 4 Rechnungsposten im Durchschnitt

	12 MIO Rechnungsposten (Order Details)


	1 ... JOIN 3 .... JOIN 12 ........ 16 MIO



	1 extra Spalte "Rechnungssumme" in Orders

	statt 16 MIO DS --> 4 Mio



*/




-- Ausführungsreihenfolge

/*

	... so schreiben wir die Abfrage:

		SELECT
		FROM 
		WHERE
		GROUP BY
		HAVING 
		ORDER BY


	... in dieser Reihenfolge wird ausgeführt:

		FROM (JOIN)
		WHERE
		GROUP BY
		HAVING
		SELECT
		ORDER BY


	-- WHERE schneller als HAVING, weil Datenmenge früher eingeschränkt wird
	-- wenn wir die Wahl haben, WHERE verwenden

	   	  
*/


/*

	-- Optimierer

	-- erstellt Plan

	-- wie soll die Abfrage ausgeführt werden?


	-- Pläne

	-- Abfrageplan lesen: von rechts nach links

	-- es gibt mehrere Pläne

	-- Trivialer Plan
	-- wenn nur ein Plan möglich ist
	-- z.B.  SELECT Spalte FROM Tabelle
	-- da kann der Plan nicht optimiert werden; es werden alle Einträge dieser Spalte ausgegeben


	-- anderes Beispiel für trivialen Plan (wo nur 1 Möglichkeit)
	-- SELECT Spalte X FROM Tabelle WHERE Spalte Y IS NULL
	-- wenn für Spalte Y NOT NULL im CHECK Constraint deklariert wurde, dann muss hier keine Überprüfung stattfinden, das Ergebnis wird immer leer sein (ohne, dass auf Tabellendaten zugegriffen werden muss)


	-- Optimierer kann auch OUTER JOIN durch INNER JOIN ersetzen, wenn das günstiger ist
	-- z.B. wenn in einer WHERE-Bedingung etwas weggekürzt wird, das erst durch den OUTER JOIN überhaupt erst im Ergebnis aufscheinen würde


	-- Kostenvergleich, wenn mehrere Möglichkeiten
	-- erster Plan, dessen Kosten < 0.2 wird ausgeführt
	-- wenn Kosten höher, wird weitergesucht; erster Plan, der < 1 Kosten verursacht, wird ausgeführt
	-- Ende der Optimierung: wenn alle möglichen Pläne untersucht wurden



	   	  
*/


-- NOT NULL: es ist nicht erlaubt, dieses Feld leer zu lassen
-- CREATE TABLE Test (		  
--						  id int identity, -- identity macht automatisch NOT NULL und UNIQUE
--						  testtext varchar(30) NOT NULL
--					)




SET STATISTICS IO, TIME ON



SELECT AVG(Freight), CustomerID
FROM Orders
WHERE ShipCountry = 'Germany'
GROUP BY CustomerID

/*

	-- Datentypen

	-- microsoft-documentation: https://docs.microsoft.com/en-us/sql/t-sql/data-types/data-types-transact-sql?view=sql-server-ver15


		-- String-Datentypen
			-- fixed width:
				char(5)

				nchar(5)

					-- es müssen 5 Zeichen verwendet werden, nicht genützer Platz wird mit Leerzeichen aufgefüllt

			-- variable width:
				varchar(30)

				nvarchar(30)
					-- es dürfen maximal 30 Zeichen verwendet werden

				





				FirstName-Spalte
				varchar(30)
					Leo

					Leo                           --> nard (auf anderer page ausgelagert)


				FirstName-Spalte
				char(30)
					Leo+nard (geht sich auf einer page aus, weil der Platz dafür freigehalten wurde)
				

			-- abhängig davon, wie oft Informationen in dieser Spalte geändert werden, macht char oder varchar mehr Sinn
				
				
			-- numerische Datentypen

				bit  - 0/1/NULL

				int
					(tinyint, smallint, bigint)
						-- wieviel Speicherplatz?
						-- welchen Bereich möchte ich abdecken?

				float
				decimal(10,2)


			-- Datumsdatentypen
				
				datetime - auf ~ 3-4 ms genau (8 byte)
				datetime2 - auf ~ 100 ns genau (6-8 byte)

				date
				time

			-- Überlegung: werden wir jemals die Zeit abspeichern?


			-- boolean/bool - true/false




*/


SELECT City
FROM Customers
WHERE Country = 'Germany'



SELECT HireDate
FROM Employees






