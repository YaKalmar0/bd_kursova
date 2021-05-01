USE Railway_Station;

DELIMITER $$

CREATE PROCEDURE get_trains_by_route(IN c1 TEXT, IN c2 TEXT)
BEGIN
	SELECT locomotive AS 'Locomotive ID', type AS 'Type', `from` AS 'From', `to` AS 'To'
    FROM Trips
    WHERE `from` = c1 AND `to` = c2;
    
	SELECT COUNT(DISTINCT(locomotive)) AS 'Number of Trains' FROM TRIPS WHERE `from` = c1 AND `to` = c2; 
END$$

CREATE PROCEDURE get_trains_by_trip_duration(IN t TIME)
BEGIN
	IF (t <= 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Time should be > 0';
	ELSE
		SELECT locomotive AS 'Locomotive ID', type AS 'Type', `from` AS 'From', `to` AS 'To', TIMEDIFF(arr, dep) AS 'Travel Time'
        FROM Trips
        WHERE TIMEDIFF(arr, dep) <= t;
        
        SELECT COUNT(1) AS 'Number of Trains' FROM TRIPS WHERE TIMEDIFF(arr, dep) <= t;
    END IF;
END$$

CREATE PROCEDURE get_trains_by_ticket_price(IN pr FLOAT)
BEGIN
	IF (pr <= 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price should be > 0';
	ELSE
		SELECT Trips.locomotive AS 'Locomotive ID', type AS 'Type', Trips.`from` AS 'From', Trips.`to` AS 'To', price as 'Price'
        FROM Tickets
        JOIN Trips ON Trips.id = Tickets.trip
        WHERE price <= pr;
        
        SELECT COUNT(1) AS 'Number of Trains' FROM TRIPS WHERE TIMEDIFF(arr, dep) <= t;
    END IF;
END$$

CREATE PROCEDURE get_trains_by_all_criterions(IN c1 TEXT, IN c2 TEXT, IN pr FLOAT, IN t TIME)
BEGIN
	IF (pr <= 0 OR t <= 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price and Time should be > 0';
	ELSE
		SELECT Trips.locomotive AS 'Locomotive ID', type AS 'Type', Trips.`from` AS 'From', Trips.`to` AS 'To', price as 'Price', TIMEDIFF(Trips.arr, Trips.dep) AS 'Travel Time'
        FROM Tickets
        JOIN Trips ON Trips.id = Tickets.trip
        WHERE Tickets.price <= pr AND Trips.`from` = c1 AND Trips.`to` = c2 AND TIMEDIFF(Trips.arr, Trips.dep) <= t;
        
        #SELECT COUNT(1) AS 'Number of Trains' FROM TRIPS WHERE price <= pr AND Trips.`from` = c1 AND Trips.`to` = c2 AND TIMEDIFF(Trips.arr, Trips.dep) <= t;
    END IF;
END$$

CREATE PROCEDURE get_cancelled_trips(IN reas TEXT, IN fr TEXT, IN t TEXT)
BEGIN
	IF (reas = '' AND t = '') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Destination point should be passed';
	ELSEIF (reas = '' AND fr = '') THEN
		SELECT id AS 'Trip ID', `type` AS 'Type', `from` AS 'From', `to` AS 'To', info AS 'Info'
        FROM Trips
        WHERE (`to` = t AND `status` = 'cancelled');
        
        SELECT COUNT(1) FROM Trips WHERE `to` = t AND status = 'cancelled';
	ELSEIF (reas = '') THEN
		SELECT id AS 'Trip ID', type AS 'Type', `from` AS 'From', `to` AS 'To', info AS 'Info'
        FROM Trips
        WHERE `to` = t AND `from` = fr AND status = 'cancelled';
        
        SELECT COUNT(1) FROM Trips WHERE `to` = t AND `from` = fr AND status = 'cancelled';
	ELSE
		SELECT id AS 'Trip ID', type AS 'Type', `from` AS 'From', `to` AS 'To', info AS 'Info'
        FROM Trips
        WHERE `to` = t AND `from` = fr AND info = reas AND status = 'cancelled';
        
        SELECT COUNT(1) FROM Trips WHERE `to` = t AND `from` = fr AND info = reas AND status = 'cancelled';
        
    END IF;
END$$

CREATE PROCEDURE get_delayed_trips(IN reas TEXT, IN fr TEXT, IN t TEXT)
BEGIN
	IF (fr = '' AND t = '') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Route should be passed';
	ELSEIF (reas = '') THEN
		SELECT Trips.id AS 'Trip ID', `type` AS 'Type', `from` AS 'From', `to` AS 'To', info AS 'Info', SUM(case when Tickets.returndate IS NOT NULL then 0 else 1 end) AS 'Returned Tickets'
		FROM Trips
		LEFT JOIN Tickets ON Trips.id = Tickets.trip
		WHERE (`from` = fr AND `to` = t AND `status` = 'delayed')
		GROUP BY trips.id;
	ELSE
		SELECT Trips.id AS 'Trip ID', `type` AS 'Type', `from` AS 'From', `to` AS 'To', info AS 'Info', SUM(case when Tickets.returndate IS NOT NULL then 0 else 1 end) AS 'Returned Tickets'
		FROM Trips
		LEFT JOIN Tickets ON Trips.id = Tickets.trip
		WHERE (`from` = fr AND `to` = t AND `status` = 'delayed' AND info = reas)
		GROUP BY trips.id;
    END IF;
END$$

CREATE PROCEDURE get_trips_by_type_dest(IN t TEXT, IN dest TEXT)
BEGIN
	IF (t != 'night' AND t != 'passengers' AND t != 'intercity') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Type should be night | passengers | intercity';
	ELSE
		SELECT Trips.id AS 'Trip ID', `type` AS 'Type', `from` AS 'From', `to` AS 'To', `status` as 'Status', info AS 'Info'
        FROM Trips
        WHERE `type` = t AND `to` = dest;
    END IF;
END$$

DELIMITER ;

call get_trains_by_route('Kyiv', 'Lviv');
call get_trains_by_trip_duration('08:30');
call get_trains_by_ticket_price(500);
call get_trains_by_all_criterions('Kyiv', 'Lviv', 1000, '10:00');
call get_cancelled_trips('', '', 'Lviv');
call get_delayed_trips('', 'Lviv', 'Kharkiv');
call get_trips_by_type_dest('night', 'Lviv');