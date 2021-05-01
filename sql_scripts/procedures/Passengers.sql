USE Railway_Station;

DELIMITER $$

CREATE PROCEDURE get_passengers_by_trip(IN tr INT)
BEGIN
	IF (tr NOT IN (SELECT id FROM Trips)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is no Trip with such ID';
	ELSE
		SELECT `Name` AS 'Name', birthdate AS 'Birthdate', sex AS 'Sex', Tickets.trip AS 'Trip ID'
        FROM Passengers
        JOIN Tickets ON Passengers.ticket = Tickets.id
        WHERE Tickets.trip = tr;
        
        SELECT COUNT(1) AS 'Passengers Number' FROM Passengers JOIN Tickets ON Passengers.ticket = Tickets.id WHERE Tickets.trip = tr;
    END IF;
END$$

CREATE PROCEDURE get_passengers_by_date(IN d DATE, IN abr BOOLEAN)
BEGIN
	SELECT `Name` AS 'Name', birthdate AS 'Birthdate', sex AS 'Sex', Tickets.trip AS 'Trip ID'
	FROM Passengers
	JOIN Tickets ON Passengers.ticket = Tickets.id
	JOIN Trips ON Tickets.trip = Trips.id
	WHERE DATE(Trips.dep) = d AND Trips.abroad = abr;
	
	SELECT COUNT(1) AS 'Passengers Number' FROM Passengers JOIN Tickets ON Passengers.ticket = Tickets.id JOIN Trips ON Tickets.trip = Trips.id WHERE DATE(Trips.dep) = d AND Trips.abroad = abr;
END$$

CREATE PROCEDURE get_passengers_sex_age_lug(IN s TEXT, IN ag INT, IN lug BOOLEAN)
BEGIN
	IF (s != 'man' AND s != 'woman') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sex should be man | woman';
	ELSEIF (ag <=0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Age should be > 0';
	ELSE
		SELECT `Name` AS 'Name', birthdate AS 'Birthdate', sex AS 'Sex', luggage AS 'Luggage', Tickets.trip AS 'Trip ID'
        FROM Passengers
		JOIN Tickets ON Passengers.ticket = Tickets.id
        WHERE sex = s AND DATEDIFF(CURDATE(), birthdate) / 365.25 <= ag AND luggage = lug;
        
        SELECT COUNT(1) 'Passengers Number' FROM Passengers JOIN Tickets ON Passengers.ticket = Tickets.id WHERE sex = s AND DATEDIFF(CURDATE(), birthdate) / 365.25 <= ag AND luggage = lug;
    END IF;
	
END$$

DELIMITER ;

call get_passengers_by_trip(2);
call get_passengers_by_date('2021-04-26', 0);
call get_passengers_sex_age_lug('man', 30, 1);