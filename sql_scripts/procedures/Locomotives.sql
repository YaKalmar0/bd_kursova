USE Railway_Station;

DELIMITER $$

CREATE PROCEDURE get_all_locomotives()
BEGIN
	SELECT * FROM Locomotives;
    SELECT COUNT(1) FROM Locomotives;
END$$

CREATE PROCEDURE get_free_locomotives_at(IN dt DATETIME)
BEGIN
	SELECT DISTINCT(locomotive) AS 'Locomotive ID'
    FROM Trips
    WHERE (status = 'cancelled') OR CASE
		WHEN `from` = 'Lviv' THEN
			dep > dt
		ELSE
			arr <= dt
		END;
END$$

CREATE PROCEDURE get_locomotive_by_arr(IN t TIME)
BEGIN
	SELECT DISTINCT(locomotive) as 'Locomotive ID'
    FROM Trips
    WHERE (`to` = 'Lviv') AND (status = 'cancelled' OR TIME(arr) = t);
END$$

CREATE PROCEDURE get_locomotives_by_trips(IN numb INT)
BEGIN
	SELECT id AS 'Locomotive ID', trips AS 'Trips'
    FROM Locomotives
    WHERE trips <= numb;
END$$

CREATE PROCEDURE get_inspected_locomotives(IN date1 DATE, IN date2 DATE)
BEGIN
	IF (date1 > date2) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Second date parameter should be >= First date parameter';
	ELSE
		SELECT id AS 'Locomotive ID', insp_date AS 'Inspection Date'
		FROM Locomotives
		WHERE (insp_date >= date1) AND (insp_date <= date2);
        
        SELECT COUNT(1) FROM Locomotives WHERE (insp_date >= date1) AND (insp_date <= date2);
	END IF;
END$$

CREATE PROCEDURE get_locomotives_inspections(IN numb INT)
BEGIN
	IF (numb < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Number of inspections should be >=0';
	ELSE
		SELECT id AS 'Locomotive ID', insp_number AS 'Number of Inspections'
        FROM Locomotives
        WHERE insp_number <= numb;
        
        SELECT COUNT(1) FROM Locomotives WHERE insp_number <= numb;
    END IF;
END$$

CREATE PROCEDURE get_locomotives_insp_trips(IN numb INT)
BEGIN
	IF (numb < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Number of trips should be >=0';
	ELSE
		SELECT id AS 'Locomotive ID', insp_trips AS 'Trips After Last Inspection'
        FROM Locomotives
        WHERE insp_trips <= numb;
        
        SELECT COUNT(1) FROM Locomotives WHERE insp_trips <= numb;
    END IF;
END$$

CREATE PROCEDURE get_locomotives_by_age(IN numb INT)
BEGIN
	IF (numb < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Age should be >=0';
	ELSE
		SELECT id AS 'Locomotive ID', age AS 'Age'
        FROM Locomotives
        WHERE age <= numb;
        
        SELECT COUNT(1) FROM Locomotives WHERE age <= numb;
    END IF;
END$$

CREATE PROCEDURE update_locomotive_inspection(IN id_loc INT)
BEGIN
	UPDATE Locomotives
    SET insp_date = CURDATE(), insp_number = insp_number + 1, insp_trips = 0
    WHERE id = id_loc;
END$$

DELIMITER ;

call get_all_locomotives();
call get_free_locomotives_at('2021-04-25 19:00:00');
call get_locomotive_by_arr('10:00:00');
call get_locomotives_by_trips(100);
call get_inspected_locomotives(DATE('2018-02-02'), DATE('2019-12-31'));
call get_locomotives_inspections(20);
call get_locomotives_insp_trips(100);
call get_locomotives_by_age(10);
call update_locomotive_inspection(1);
