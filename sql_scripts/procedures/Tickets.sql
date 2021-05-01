USE Railtay_Station;

DELIMITER $$

CREATE PROCEDURE get_sold_tickets(IN d1 DATE, IN d2 DATE)
BEGIN
	IF (d2 < d1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Second date parameter should be >= First date. parameter';
	ELSE
		SELECT id AS 'Ticket ID', trip AS 'Trip ID', buydate AS 'Sell Date', price AS 'Price'
        FROM Tickets
        WHERE (buydate <= d2 AND buydate >= d1);
        
        SELECT COUNT(1) / DATEDIFF(d2, d1) AS 'Day Avg Sold Tickets' FROM Tickets WHERE (buydate <= d2 AND buydate >= d1);
    END IF;
END$$ 

CREATE PROCEDURE get_sold_tickets_by_route(IN fr TEXT, IN t TEXT)
BEGIN
	SELECT tickets.id AS 'Ticket ID', trip AS 'Trip ID', buydate AS 'Sell Date', price AS 'Price'
    FROM Tickets
    JOIN Trips ON Tickets.trip = Trips.id
    WHERE Trips.`from` = fr AND Trips.`to` = t;
    
    SELECT COUNT(1) AS 'Number of Tickets Sold' FROM TICKETS JOIN Trips ON Tickets.trip = Trips.id WHERE Trips.`from` = fr AND Trips.`to` = t;
END$$

CREATE PROCEDURE get_sold_tickets_by_travel_time(IN t TIME)
BEGIN
	SELECT tickets.id AS 'Ticket ID', trip AS 'Trip ID', buydate AS 'Sell Date', price AS 'Price', TIMEDIFF(Trips.arr, Trips.dep) AS 'Travel Time'
    FROM Tickets
    JOIN Trips ON Tickets.trip = Trips.id
    WHERE TIMEDIFF(Trips.arr, Trips.dep) <= t;
    
    SELECT COUNT(1) AS 'Number of Tickets Sold' FROM TICKETS JOIN Trips ON Tickets.trip = Trips.id  WHERE TIMEDIFF(Trips.arr, Trips.dep) <= t;
END$$

CREATE PROCEDURE get_sold_tickets_by_price(IN pr FLOAT)
BEGIN
	SELECT id AS 'Ticket ID', trip AS 'Trip ID', buydate AS 'Sell Date', price AS 'Price'
    FROM Tickets
    WHERE price <= pr;
    
    SELECT COUNT(1) AS 'Number of Tickets Sold' FROM TICKETS WHERE price <= pr;
END$$

CREATE PROCEDURE get_unsold_tickets_by_trip(IN tr INT)
BEGIN
	IF (tr NOT IN (SELECT id FROM Trips)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is no such Trip ID in Database';
	ELSE
		SELECT tr AS 'Trip ID', Trips.tickets - COUNT(1) AS 'Unsold Tickets'
        FROM Tickets
        JOIN Trips ON Tickets.trip = Trips.id
        WHERE trip = tr
		GROUP BY Tickets.trip;
    END IF;
END$$

CREATE PROCEDURE get_unsold_tickets_by_route(IN fr TEXT, IN t TEXT)
BEGIN
	SELECT Tickets.trip AS 'Trip ID', fr AS 'From' , t AS 'To', Trips.tickets - COUNT(1) AS 'Unsold Tickets'
	FROM Tickets
	JOIN Trips ON Tickets.trip = Trips.id
	WHERE Trips.`From` = fr AND Trips.`To` = t
	GROUP BY Tickets.trip;
END$$

CREATE PROCEDURE get_unsold_tickets_by_date(IN d1 DATE, IN d2 DATE)
BEGIN
	IF (d2 < d1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Second date parameter should be >= First date parameter';
	ELSE
		SELECT Tickets.trip AS 'Trip ID', Trips.tickets - COUNT(1) AS 'Unsold Tickets', Trips.dep AS 'Departure'
		FROM Tickets
		JOIN Trips ON Tickets.trip = Trips.id
		WHERE DATE(Trips.dep) <= d2 AND DATE(Trips.dep) >= d1
		GROUP BY Tickets.trip;
	END IF;
END$$

CREATE PROCEDURE get_returned_tickets_by_trip(IN tr INT)
BEGIN
	IF (tr NOT IN (SELECT id FROM TRIPS)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bad Trip ID';
	ELSE
		SELECT COUNT(1) AS 'Returned Tickets', tr AS 'Trip ID'
        FROM Tickets
        WHERE trip = tr;
    END IF;
END$$

CREATE PROCEDURE get_returned_tickets_by_date(IN d DATE)
BEGIN
	SELECT COUNT(1) AS 'Returned Tickets', d AS 'Return Date'
	FROM Tickets
	WHERE returndate = d;
END$$

CREATE PROCEDURE get_returned_tickets_by_route(IN fr TEXT, IN t TEXT)
BEGIN
	SELECT COUNT(1) AS 'Returned Tickets', fr AS 'From', t AS 'To'
	FROM Tickets
    JOIN Trips ON Tickets.trip = Trips.id
	WHERE Trips.`from` = fr AND Trips.`to` = t;
END$$

DELIMITER ;

call get_sold_tickets('2021-02-01', '2021-03-31');
call get_sold_tickets_by_route('Kyiv', 'Lviv');
call get_sold_tickets_by_travel_time('10:00');
call get_sold_tickets_by_price(490);
call get_unsold_tickets_by_trip(2);
call get_unsold_tickets_by_route('Kharkiv', 'Lviv');
call get_unsold_tickets_by_date('2021-04-25', '2021-04-25');
call get_returned_tickets_by_trip(1);
call get_returned_tickets_by_date('2021-04-26');
call get_returned_tickets_by_route('Kyiv', 'Lviv');
