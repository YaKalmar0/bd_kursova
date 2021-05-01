use Railway_Station;

DROP TRIGGER IF EXISTS workers_insert_check;

DELIMITER $$

CREATE TRIGGER workers_insert_check BEFORE INSERT ON Workers
	FOR EACH ROW
    BEGIN
		IF (new.dept != 'executive' AND new.dept != 'drivers' AND new.dept != 'repair') THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Forbidden dept: only executive | drivers | repair';
		END IF;
        
		IF (new.sex != 'man' AND new.sex != 'woman')
		THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Forbidden sex: only man | woman';
		END IF;
        
        IF (SELECT CURDATE() - new.birthdate < 18) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Workers age is below 18 years';
        END IF;
	END$$

DELIMITER ;