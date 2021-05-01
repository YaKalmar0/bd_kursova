USE Railway_Station;

DELIMITER $$

CREATE TRIGGER trips_trigger BEFORE INSERT ON Trips
FOR EACH ROW
BEGIN
	IF (new.status != 'OK' AND new.status != 'delayed' AND new.status != 'cancelled') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Status should be OK | delayed | cancelled';
	ELSEIF (new.type != 'night' AND new.type != 'passengers' AND new.type != 'intercity') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Type should be night | passengers | intercity';
	ELSEIF (new.locomotive NOT IN (SELECT id FROM Locomotives)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is no locomotive with such ID';
    END IF;
END$$


