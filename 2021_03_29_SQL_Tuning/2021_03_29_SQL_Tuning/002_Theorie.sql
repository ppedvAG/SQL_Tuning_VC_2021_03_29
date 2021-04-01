-- ER-Diagramm


-- wir verwendet f�r DB-Planung
-- zur Kommunikation zwischen Kunde und Entwickler

-- mehrere Notationsformen (Chen, Min-Max, Crow's-Foot,...)

-- Entity wird zu Tabelle
-- Attribut wird zu Spalte

-- Beziehung wird aufgel�st (daraus kann auch eine Tabelle werden)






-- Normalformen

-- sollen Redundanz vermeiden
-- sollen auch Inkonsistenzen vermeiden
-- Kunde soll nicht weggel�scht werden, wenn wir eine Bestellung wegl�schen (oder umgekehrt)


-- aber: NF k�nnen bewusst gebrochen werden, um die Abfrage schneller zu machen (weil dann weniger Datens�tze angesehen werden m�ssen)


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




-- Ausf�hrungsreihenfolge

/*

	... so schreiben wir die Abfrage:

		SELECT
		FROM 
		WHERE
		GROUP BY
		HAVING 
		ORDER BY


	... in dieser Reihenfolge wird ausgef�hrt:

		FROM (JOIN)
		WHERE
		GROUP BY
		HAVING
		SELECT
		ORDER BY


	-- WHERE schneller als HAVING, weil Datenmenge fr�her eingeschr�nkt wird
	-- wenn wir die Wahl haben, WHERE verwenden

	   	  
*/


/*

	-- Optimierer

	-- erstellt Plan

	-- wie soll die Abfrage ausgef�hrt werden?


	-- Pl�ne

	-- Abfrageplan lesen: von rechts nach links

	-- es gibt mehrere Pl�ne

	-- Trivialer Plan
	-- wenn nur ein Plan m�glich ist
	-- z.B.  SELECT Spalte FROM Tabelle
	-- da kann der Plan nicht optimiert werden; es werden alle Eintr�ge dieser Spalte ausgegeben


	-- anderes Beispiel f�r trivialen Plan (wo nur 1 M�glichkeit)
	-- SELECT Spalte X FROM Tabelle WHERE Spalte Y IS NULL
	-- wenn f�r Spalte Y NOT NULL im CHECK Constraint deklariert wurde, dann muss hier keine �berpr�fung stattfinden, das Ergebnis wird immer leer sein (ohne, dass auf Tabellendaten zugegriffen werden muss)


	-- Optimierer kann auch OUTER JOIN durch INNER JOIN ersetzen, wenn das g�nstiger ist
	-- z.B. wenn in einer WHERE-Bedingung etwas weggek�rzt wird, das erst durch den OUTER JOIN �berhaupt erst im Ergebnis aufscheinen w�rde


	-- Kostenvergleich, wenn mehrere M�glichkeiten
	-- erster Plan, dessen Kosten < 0.2 wird ausgef�hrt
	-- wenn Kosten h�her, wird weitergesucht; erster Plan, der < 1 Kosten verursacht, wird ausgef�hrt
	-- Ende der Optimierung: wenn alle m�glichen Pl�ne untersucht wurden



	   	  
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

					-- es m�ssen 5 Zeichen verwendet werden, nicht gen�tzer Platz wird mit Leerzeichen aufgef�llt

			-- variable width:
				varchar(30)

				nvarchar(30)
					-- es d�rfen maximal 30 Zeichen verwendet werden

				





				FirstName-Spalte
				varchar(30)
					Leo

					Leo                           --> nard (auf anderer page ausgelagert)


				FirstName-Spalte
				char(30)
					Leo+nard (geht sich auf einer page aus, weil der Platz daf�r freigehalten wurde)
				

			-- abh�ngig davon, wie oft Informationen in dieser Spalte ge�ndert werden, macht char oder varchar mehr Sinn
				
				
			-- numerische Datentypen

				bit  - 0/1/NULL

				int
					(tinyint, smallint, bigint)
						-- wieviel Speicherplatz?
						-- welchen Bereich m�chte ich abdecken?

				float
				decimal(10,2)


			-- Datumsdatentypen
				
				datetime - auf ~ 3-4 ms genau (8 byte)
				datetime2 - auf ~ 100 ns genau (6-8 byte)

				date
				time

			-- �berlegung: werden wir jemals die Zeit abspeichern?


			-- boolean/bool - true/false




*/


SELECT City
FROM Customers
WHERE Country = 'Germany'



SELECT HireDate
FROM Employees






