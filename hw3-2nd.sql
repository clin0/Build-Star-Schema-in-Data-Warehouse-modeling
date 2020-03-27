-- create TIME_DIMENSION table
CREATE TABLE TIME_DIMENSION(
    Day_Key NUMBER,
    Actual_Date DATE,
    Day_Of_Month NUMBER(2),
    Month VARCHAR2(9),
    Quarter NUMBER(1),
    Year NUMBER(4),
CONSTRAINT Which_Quarter CHECK (Quarter in (1,2,3,4))
);



--use ALTER TABLE command to define the PK of TIME_DIMENSION
ALTER TABLE TIME_DIMENSION
ADD CONSTRAINT TIME_DIMENSION_PK PRIMARY KEY (Day_Key);



-- create EMPLOYEE_DIMENSION table
CREATE TABLE EMPLOYEE_DIMENSION(
 	emp_key number (6)
 	employee_id number(4),
    first_name varchar2(15),
 	middle_initial varchar2(1),
 	last_name varchar2(15),
 	sex char(1),
 	manager_id number(4),
 	hire_date date,
 	salary number(7,2),
 	commission number(7,2),
 	job_code number(2),
 	dob date
);



--use ALTER TABLE command to define the PK of EMPLOYEE_DIMENSION
ALTER TABLE EMPLOYEE_DIMENSION
ADD CONSTRAINT EMPLOYEE_DIMENSION_PK PRIMARY KEY (emp_key);



-- create CUSTOMER_DIMENSION table
CREATE TABLE CUSTOMER_DIMENSION(
 	cust_key number(6),
 	customer_id number(6),
 	name varchar2(45),
 	address varchar2(40),
 	city varchar2(30),
 	state varchar2(2),
 	zip_code varchar2(9),
 	area_code number(3),
 	phone_number number(7),
 	credit_limit number(9,2),
 	comments varchar2(256)
);



--use ALTER TABLE command to define the PK of CUSTOMER_DIMENSION
ALTER TABLE CUSTOMER_DIMENSION
ADD CONSTRAINT CUSTOMER_DIMENSION_PK PRIMARY KEY (emp_key);



-- create PRODUCT_DIMENSION table
CREATE TABLE product_dimension
(
  	prod_key number (6),
  	product_id number (6),
  	product_description varchar2(30),
  	product_code varchar2(4),
  	brand_name varchar2(10), -- the first string extracted from product_description
 	list_price number (8,2),
  	min_price number (8,2),
  	price_start_date date, -- starting date for the list price
  	price_end_date date, -- end date for the list price
  	current_flag varchar2(1) -- True if price_hist.end_date = NULL
);



-- use ALTER TABLE command to define the PK of PRODUCT_DIMENSION
ALTER TABLE product_dimension
ADD CONSTRAINT prod_dimension_PK PRIMARY KEY (prod_key);



-- create SALES_FACT table
CREATE TABLE sales_fact
(
  	orderdate_key number (6),
  	prod_key number (6),
  	cust_key number (6),
  	emp_key number (6),
  	sales_dollar_amount number (10,2),
  	quantity number (4)
)



-- use ALTER TABLE command to define the PK of SALES_FACT
ALTER TABLE sales_fact
ADD CONSTRAINT sales_fact_PK PRIMARY KEY (orderdate_key, prod_key, cust_key, emp_key);



-- use ALTER TABLE command to set each foreign key 
-- from dimension tables to the sales_fact table
ALTER TABLE sales_fact
    ADD CONSTRAINT sales_fact_FK1 FOREIGN KEY (orderdate_key) 
    REFERENCES time_dimension (day_key);

ALTER TABLE sales_fact
    ADD CONSTRAINT sales_fact_FK2 FOREIGN KEY (prod_key) 
REFERENCES product_dimension(prod_key);

ALTER TABLE sales_fact
ADD CONSTRAINT sales_fact_FK3 FOREIGN KEY (cust_key) 
REFERENCES Customer_dimension (cust_key)

ALTER TABLE sales_fact
     ADD CONSTRAINT sales_fact_FK4 FOREIGN KEY (emp_key)
     REFERENCES Employee_dimension (emp_key)





-------------- ALL TABLES WERE CREATED -------------------



-- create a sequence, seq_time, to start with 1 and increment by 1
CREATE SEQUENCE seq_ time START WITH 1 INCREMENT BY 1;



-- create a PL/SQL procedure that populates the data of TIME_DIMENSION
-- call the procedure populate_time_dimension (p_start_date,  p_end_date)
CREATE OR REPLACE PROCEDURE populate_time_dimension(p_start_date date, p_end_date date) AS
v_current_day DATE;

/*Declare local variable to determine quarter
v_quarter int;*/

BEGIN
v_current_day := p_start_date;
/*
loop through each date up until the end date;
purpose: to get the next SEQ_TIME value,
then break down the values of that date into the seperate columns
*/
LOOP 
IF v_current_day > p_end_date 
THEN EXIT;
END IF;

-- to determine which quarter
IF TO_NUMBER(TO_CHAR(v_current_day,'mm')) BETWEEN 1 and 3
THEN v_quarter := 1;
END IF;
IF TO_NUMBER(TO_CHAR(v_current_day,'mm')) BETWEEN 4 and 6
THEN v_quarter := 2;
END IF;
IF TO_NUMBER(TO_CHAR(v_current_day,'mm')) BETWEEN 7 and 9
THEN v_quarter := 3;
END IF;
IF TO_NUMBER(TO_CHAR(v_current_day,'mm')) BETWEEN 10 and 12
THEN v_quarter := 4;
END IF;

  INSERT INTO TIME_DIMENSION
  SELECT SEQ_TIME.nextval,
         v_current_day,
         TO_NUMBER(TO_CHAR(v_current_day,'dd')),
         TO_NUMBER(TO_CHAR(v_current_day,'mm')),
         v_quarter,
         TO_NUMBER(TO_CHAR(v_current_day,'yyyy'))
    FROM DUAL;
    /*
    Will Increment every date by 1 at the end of the updates 
    until the loop criteria is satisfied
    */
    v_current_day:=v_current_day+1;
  END LOOP;
  COMMIT;

  /*print out error message when an exception happen*/
  EXCEPTION WHEN OTHERS THEN 
  dbms_output.put_line('Error!');
END populate_time_dimension;
/



-- execute the procedure for TIME_DIMENSION  
BEGIN 
   populate_time_dimension('01-01-1999', '12-31-2001'); 
END;





-- create a sequence, seq_emp, to start with 1 and increment by 1
CREATE SEQUENCE seq_emp START WITH 1 INCREMENT BY 1;



-- create a PL/SQL procedure that populates the data of EMPLOYEE_DIMENSION
CREATE OR REPLACE PROCEDURE populate_employee_dimension AS
BEGIN
  -- populate the current date
  INSERT INTO EMPLOYEE_DIMENSION
  SELECT SEQ_EMP.nextval,
         e.EMPLOYEE_ID,
         e.FIRST_NAME,
         e.MIDDLE_INITIAL,
         e.LAST_NAME,
         e.SEX,
         e.MANAGER_ID,
         e.HIRE_DATE,
         e.SALARY,
         e.COMMISSION,
         e.JOB_CODE,
         e.DOB
    FROM EMP e
    WHERE e.EMPLOYEE_ID NOT IN (SELECT EMPLOYEE_ID FROM EMPLOYEE_DIMENSION);
  COMMIT;
  EXCEPTION WHEN OTHERS THEN
  BEGIN
    RAISE_APPLICATION_ERROR(-20100,' Error when populating to the employee dimension');
    ROLLBACK;
  END;
END populate_employee_dimension;
/



-- execute the procedure 
BEGIN 
populate_employee_dimension();
END;



-- Check the result from OLPT
select * from emp
order by EMPLOYEE_ID





-- create a sequence, seq_cust, to start with 1 and increment by 1
CREATE SEQUENCE seq_cust START WITH 1 INCREMENT BY 1;


-- create a PL/SQL procedure that populates the data of CUSTOMER_DIMENSION
CREATE OR REPLACE PROCEDURE populate_customer_dimension AS
BEGIN
  INSERT INTO CUSTOMER_DIMENSION
  SELECT SEQ_CUST.nextval,
        c.CUSTOMER_ID,
        c.NAME,
        c.ADDRESS,
        c.CITY,
        c.STATE,
        c.ZIP_CODE,
        c.AREA_CODE,
        c.PHONE_NUMBER,
        c.CREDIT_LIMIT,
        c.COMMENTS
    FROM CUSTOMER c
    WHERE c.CUSTOMER_ID NOT IN (SELECT CUSTOMER_ID FROM CUSTOMER_DIMENSION);
  COMMIT;
  EXCEPTION WHEN OTHERS THEN 
  BEGIN
    RAISE_APPLICATION_ERROR(-20100,' Error when populating to the customer dimension');
    ROLLBACK;
  END;  
END populate_customer_dimension;
/



-- execute the procedure for CUSTOMER_DIMENSION
BEGIN 
populate_customer_dimension();
END;





-- create a sequence, seq_prod, to start with 1 and increment by 1
CREATE SEQUENCE seq_prod START WITH 1 INCREMENT BY 1;



-- create a PL/SQL procedure that populates the data of PRODUCT_DIMENSION
CREATE OR REPLACE PROCEDURE populate_product_dimension AS
BEGIN
    INSERT INTO product_dimension
    SELECT seq_prod.nextval,
    p.PRODUCT_ID,
    p.DESCRIPTION,
    p.PRODUCT_CODE,
    substr(p.description, 1, instr(p.description,' ') - 1),
    h.LIST_PRICE,
    h.MIN_PRICE,
    h.START_DATE,
    h.END_DATE,
    CASE WHEN h.END_DATE IS NULL
        THEN 'T' else 'F'
        END
    FROM product p, price_hist h
    WHERE p.product_id = h.product_id;
 COMMIT;
 EXCEPTION WHEN OTHERS THEN
 BEGIN
 RAISE_APPLICATION_ERROR(-20100,' Error when populating to the product dimension');
 ROLLBACK;
 END;
END populate_product_dimension;



-- Execute the procedure for PRODUCT_DIMENSION
BEGIN 
    populate_product_dimension();
END;





-- create a PL/SQL procedure that populates the data of SALES_FACT table
CREATE OR REPLACE PROCEDURE populate_sales_fact AS
-- cursor which selects data to be loaded into the sales_fact table.

CURSOR c_sales IS
    SELECT s.order_id, s.customer_id, s.order_date, l.product_id, l.actual_price, l.quantity, c.salesperson_id
    FROM sales_order s, line_item l, customer c
    WHERE s.order_id = l.order_id
    AND s.customer_id = c.customer_id;

v_order_day_key NUMBER(6);
v_prod_key NUMBER(6);
v_cust_key NUMBER(6);
v_emp_key NUMBER(6);

BEGIN
	FOR v_sales IN c_sales LOOP
    /* Find the day_key of the order date*/
	SELECT DAY_KEY INTO V_ORDER_DAY_KEY 
	FROM TIME_DIMENSION 
  WHERE ACTUAL_DATE = V_sales.ORDER_DATE;

	  /* Find the emp key of the employee who is responsible for the sale */
	SELECT emp_key INTO v_emp_key
  FROM employee_dimension
  WHERE employee_id = v_sales.salesperson_id;

    /* Select the correct prod_key */
  SELECT prod_key INTO v_prod_key
  FROM product_dimension
  WHERE product_id = v_sales.product_id AND
  (((v_sales.order_date >= product_dimension.price_start_date) AND
   (v_sales.order_date <= product_dimension.price_end_date)) OR
   ((v_sales.order_date >= product_dimension.price_start_date) AND
   (product_dimension.price_end_date IS null)));

	SELECT cust_key INTO v_cust_key
  FROM customer_dimension
  WHERE customer_id = v_sales.customer_id;
	

	INSERT INTO sales_fact VALUES (v_order_day_key, v_prod_key, v_cust_key, v_emp_key,v_sales.actual_price, v_sales.quantity);
    
END LOOP

COMMIT;

-- exception handling

EXCEPTION

WHEN others THEN raise_application_error(-20263,'An error was encountered in sales_fact:'||SQLCODE||'Error:'||SQLERRM);

END;



-- Execute the procedure for SALES_FACT 
BEGIN 
    populate_sales_fact();
END;
