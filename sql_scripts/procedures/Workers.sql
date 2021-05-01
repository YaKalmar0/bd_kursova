USE Railway_Station;

DROP PROCEDURE IF EXISTS get_workers;
DROP PROCEDURE IF EXISTS get_number_of_workers;


delimiter $$

CREATE PROCEDURE get_workers()
BEGIN
	SELECT name AS Name FROM WORKERS;
    SELECT COUNT(*) AS `Number of Workers` FROM WORKERS;
END$$

CREATE PROCEDURE get_number_of_workers()
BEGIN
	SELECT COUNT(*) AS `Number of Workers` FROM WORKERS;
END$$

CREATE PROCEDURE get_head_of_dept(IN department TEXT)
BEGIN
	IF (department = 'executive') THEN
		SELECT * FROM Workers
        WHERE (position = 'director' AND dept = department);
	ELSEIF (department = 'drivers' OR department = 'repair') THEN
		SELECT * FROM WORKERS
        WHERE (position = 'head' AND dept = department);
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Forbidden dept: only executive | drivers | repair';
	END IF;
END$$

CREATE PROCEDURE get_dept_workers(IN department TEXT)
BEGIN
	IF (department != 'executive' AND department != 'repair' AND department != 'drivers') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Forbidden dept: only executive | drivers | repair';
	ELSE
		SELECT name AS Name, brigade as Brigade, position as Position
		FROM WORKERS
        WHERE (dept = department);
	END IF;
END$$

CREATE PROCEDURE get_workers_by_exp(IN years INT)
BEGIN
	IF (years < 0 OR years > 85) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bad year specified';
	ELSE
		SELECT name AS Name, dept AS Department, position as Position, DATEDIFF(CURDATE(), hiredate) / 365.25 AS Experience, sex AS Sex
        FROM Workers
        WHERE DATEDIFF(CURDATE(), hiredate) / 365.25 <= years;
	END IF;
END$$

CREATE PROCEDURE get_workers_by_sex(IN gend TEXT)
BEGIN
	IF (gend != 'man' AND gend != 'woman') THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Forbidden sex: only man | woman';
	ELSE
		SELECT name AS Name, dept AS Department, position as Position
        FROM WORKERS
        WHERE sex = gend;
	END IF;
END$$

CREATE PROCEDURE get_workers_by_number_of_kids(IN num INT)
BEGIN
	IF (num < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bad number of kids';
	ELSE
		SELECT name AS Name, dept AS Department, position as Position, kids as `Number of kids`
        FROM WORKERS
        WHERE kids = num;
    END IF;
END$$

CREATE PROCEDURE get_workers_by_salary(IN sal INT)
BEGIN
	IF (sal <= 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bad salary entered';
	ELSE
		SELECT name AS Name, dept AS Department, position as Position,  salary AS Salary
        FROM WORKERS
        WHERE salary <= sal;
    END IF;
END$$

CREATE PROCEDURE get_workers_by_brig_and_dep(IN brig INT, IN dep TEXT)
BEGIN
	IF (brig < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bad brigade number or department name';
	ELSEIF (dep != 'executive' AND dep != 'repair' AND dep != 'drivers') THEN
		SELECT name AS Name, dept AS Department, position as Position
        FROM WORKERS
        WHERE brigade = brig;
	ELSE
		SELECT name AS Name, dept AS Department, position as Position
        FROM WORKERS
        WHERE (brigade = brig AND dept = dep);
    END IF;
    
    IF (brig < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bad brigade number or department name';
	ELSEIF (dep != 'executive' AND dep != 'repair' AND dep != 'drivers') THEN
		SELECT COUNT(1) FROM WORKERS WHERE brigade = brig;
	ELSE
		SELECT COUNT(1) FROM WORKERS WHERE (brigade = brig AND dept = dep);
	END IF;
END$$

CREATE PROCEDURE get_workers_by_locomotive(IN num INT)
BEGIN
	IF (num < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bad locomotive number';
	ELSE
		SELECT name AS Name, brigade AS Brigade, dept AS Department, position as Position
        FROM Workers
        WHERE brigade IN (
			SELECT brigade
            FROM Locomotives
            WHERE id = num
		);
	END IF;
END$$

CREATE PROCEDURE get_brigade_workers_younger_than(IN brig INT, IN years INT)
BEGIN
	IF (years < 0 OR brig < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bad year or brigade number';
	ELSE
		SELECT name AS Name, brigade AS Brigade, dept AS Department, position as Position,
			DATEDIFF(CURDATE(), birthdate) / 365.25 AS Age
        FROM Workers
        WHERE (DATEDIFF(CURDATE(), birthdate) / 365.25 <= years AND brigade = brig);
	END IF;
END$$

CREATE FUNCTION get_brigade_av_salary(brig INT) RETURNS FLOAT
BEGIN
	DECLARE avg_salary FLOAT;
    
	SELECT AVG(salary) INTO avg_salary
	FROM Workers
	WHERE brigade = brig;
    
    RETURN avg_salary;
END$$

delimiter ;

call get_workers;
call get_number_of_workers;
call get_head_of_dept('executive');
call get_dept_workers('repair');
call get_workers_by_exp(15);
call get_workers_by_sex('woman');
call get_workers_by_number_of_kids(1);
call get_workers_by_salary(10000);
call get_workers_by_brig_and_dep(0, 'all');
call get_workers_by_locomotive(4);
call get_brigade_workers_younger_than(1, 80);
select get_brigade_av_salary(1) AS `Average Salary in Brigade`;
