-- FUNCTION AND PROCEDURE --
-- function: to add salesperson --
CREATE OR REPLACE FUNCTION add_salesperson(
    _first_name VARCHAR,
    _last_name VARCHAR,
    _phone_number VARCHAR,
    _email_address VARCHAR
) RETURNS INT AS $$
DECLARE
    _salesperson_id INT;
BEGIN
    -- check if the salesperson exists and get their ID
    SELECT Salesperson_ID INTO _salesperson_id FROM Salesperson WHERE Email_Address = _email_address;

    -- if not found, insert the new salesperson and get the new ID
    IF _salesperson_id IS NULL THEN
        INSERT INTO Salesperson (First_Name, Last_Name, Phone_Number, Email_Address)
        VALUES (_first_name, _last_name, _phone_number, _email_address)
        RETURNING Salesperson_ID INTO _salesperson_id;
    END IF;

    RETURN _salesperson_id;
END;
$$ LANGUAGE plpgsql;

-- function: to add mechanic -- 
CREATE OR REPLACE FUNCTION add_mechanic(
    _first_name VARCHAR,
    _last_name VARCHAR,
    _specialization VARCHAR
) RETURNS INT AS $$
DECLARE
    _mechanic_id INT;
BEGIN
    -- check if the mechanic exists and get their ID
    SELECT Mechanic_ID INTO _mechanic_id FROM Mechanic 
    WHERE First_Name = _first_name AND Last_Name = _last_name AND Specialization = _specialization;

    -- if not found, insert the new mechanic and get the new ID
    IF _mechanic_id IS NULL THEN
        INSERT INTO Mechanic (First_Name, Last_Name, Specialization)
        VALUES (_first_name, _last_name, _specialization)
        RETURNING Mechanic_ID INTO _mechanic_id;
    END IF;

    RETURN _mechanic_id;
END;
$$ LANGUAGE plpgsql;

-- function: to add customer --
CREATE OR REPLACE FUNCTION insert_or_get_customer(
    _first_name VARCHAR,
    _last_name VARCHAR,
    _phone_number VARCHAR,
    _address VARCHAR,
    _email_address VARCHAR
) RETURNS INT AS $$
DECLARE
    _customer_id INT;
BEGIN
    -- Check if customer exists and get their ID
    SELECT Customer_ID INTO _customer_id FROM Customer WHERE Email_Address = _email_address;

    -- If not found, insert the new customer and get the new ID
    IF _customer_id IS NULL THEN
        INSERT INTO Customer (First_Name, Last_Name, Phone_Number, Address, Email_Address)
        VALUES (_first_name, _last_name, _phone_number, _address, _email_address)
        RETURNING Customer_ID INTO _customer_id;
    END IF;
    
    RETURN _customer_id;
END;
$$ LANGUAGE plpgsql;

-- procedure: add new car sale --
CREATE OR REPLACE PROCEDURE add_car_sale(
    _serial_number VARCHAR,
    _make VARCHAR,
    _model VARCHAR,
    _color VARCHAR,
    _year INT,
    _price DECIMAL(10, 2),
    _new_or_used BOOLEAN,
    _first_name VARCHAR,
    _last_name VARCHAR,
    _phone_number VARCHAR,
    _address VARCHAR,
    _email_address VARCHAR,
    _salesperson_id INT,
    _sale_amount DECIMAL(10,2),
    _sale_date DATE
)
LANGUAGE plpgsql AS $$
DECLARE
    _customer_id INT;
    _car_id INT;
BEGIN
    -- Use function to obtain Customer_ID
    _customer_id := insert_or_get_customer(_first_name, _last_name, _phone_number, _address, _email_address);
    
    -- Insert into Car table
    INSERT INTO Car (Serial_Number, Make, Model, Color, Year, Price, New_or_Used) 
    VALUES (_serial_number, _make, _model, _color, _year, _price, _new_or_used) 
    RETURNING Car_ID INTO _car_id;
    
    -- Insert into Invoice table
    INSERT INTO Invoice (Date, Amount, Car_ID, Salesperson_ID, Customer_ID) 
    VALUES (_sale_date, _sale_amount, _car_id, _salesperson_id, _customer_id);
    
EXCEPTION WHEN OTHERS THEN
    -- Here you can handle errors, such as logging them or re-raising
    RAISE;
END;
$$;

-- function to insert car mechanic --
CREATE OR REPLACE FUNCTION insert_carmechanic(
    _car_id INT,
    _mechanic_id INT,
    _work_details TEXT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO CarMechanic (Car_ID, Mechanic_ID, Work_Details)
    VALUES (_car_id, _mechanic_id, _work_details);
END;
$$ LANGUAGE plpgsql;

-- function to insert parts --
CREATE OR REPLACE FUNCTION insert_part(
    _name VARCHAR,
    _price DECIMAL(10, 2)
) RETURNS VOID AS $$
BEGIN
    INSERT INTO Part (Name, Price)
    VALUES (_name, _price);
END;
$$ LANGUAGE plpgsql;

-- function to insert service history --
CREATE OR REPLACE FUNCTION insert_servicehistory(
    _car_id INT,
    _ticket_id INT,
    _service_details TEXT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO ServiceHistory (Car_ID, Ticket_ID, Service_Details)
    VALUES (_car_id, _ticket_id, _service_details);
END;
$$ LANGUAGE plpgsql;

-- function to insert service parts --
CREATE OR REPLACE FUNCTION insert_serviceparts(
    _ticket_id INT,
    _part_id INT,
    _quantity INT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO ServicePart (Ticket_ID, Part_ID, Quantity)
    VALUES (_ticket_id, _part_id, _quantity);
END;
$$ LANGUAGE plpgsql;

-- function to insert service tickets --
CREATE OR REPLACE FUNCTION insert_serviceticket(
    _date DATE,
    _description TEXT,
    _car_id INT,
    _customer_id INT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO ServiceTicket (Date, Description, Car_ID, Customer_ID)
    VALUES (_date, _description, _car_id, _customer_id);
END;
$$ LANGUAGE plpgsql;

-- DATA MANIULATION --
-- add a salesperson and get the ID
SELECT add_salesperson('Ryan', 'Rhodes', 'YES-POK-EMON', 'ryanr@codingtemple.com') AS NewSalespersonID;
SELECT add_salesperson('Alex', 'Swiggum', 'MYD-OGH-ENRI', 'alexs@codingtemple.com') AS NewSalespersonID;
SELECT add_salesperson('George', 'Washington', 'JUL-Y04-1776', 'iamamerica@america.com') AS NewSalespersonID;
SELECT add_salesperson('Abraham', 'Lincoln', '123-456-7890', 'tellnolies@america.com') AS NewSalespersonID;

select *
from salesperson;

-- add mechanic to the team
SELECT add_mechanic('Emmett', 'Brown', 'Flux Capacitor Repairs');
SELECT add_mechanic('Gordon', 'Ramsey', 'Engine Temperatures and Cooling Systems');
SELECT add_mechanic('Mario', 'Bro', 'Exhaust Systems and Pipe Cleaning');
SELECT add_mechanic('Hermes', 'Trismegistus', 'Alchemy and Transmutation of Vehicle Parts');
SELECT add_mechanic('Tony', 'Stark', 'Advanced Technology');
SELECT add_mechanic('Hermione', 'Granger', 'Enchantments');
SELECT add_mechanic('Rick', 'Sanchez', 'Interdimensional Tech');
SELECT add_mechanic('T''Challa', 'Black Panther', 'Vibranium Tech');


select *
from mechanic;

-- salesperson makes a car sale -- add new car sale and user
CALL add_car_sale(
    '1HGBH41JXMN109186', 'Subaru', 'Impreza', 'Silver', 2013, 24000.00, TRUE,
    'Alex', 'Huynh', '925-519-1234', '123 Main St', 'alex.va.huynh@gmail.com',
    1, 21000.00, '2024-01-21');
CALL add_car_sale(
    '1HGBH41JXMN109186', 'Subaru', 'Impreza', 'Silver', 2013, 24000.00, TRUE,
    'Alex', 'Huynh', '925-519-1234', '123 Main St', 'alex.va.huynh@gmail.com',
    1, 21000.00, '2024-01-21');
CALL add_car_sale(
    'OUTATIME', 'DeLorean', 'DMC-12', 'Stainless Steel', 1985, 88000.00, FALSE,
    'Emmett', 'Brown', '555-1885', '1640 Riverside Drive', 'docbrown@timetravel.com',
    1, 93000.00, '1955-11-05');
CALL add_car_sale(
    'JB007', 'Aston Martin', 'DB5', 'Silver', 1964, 450000.00, TRUE,
    'James', 'Bond', '007-007-0007', 'MI6 Headquarters', 'bond.james@mi6.gov.uk',
    1, 500000.00, '1964-10-05');
CALL add_car_sale(
    'FALCON123', 'Chevrolet', 'Impala', 'Black', 1967, 30000.00, TRUE,
    'Han', 'Solo', '555-4242', 'Corellia Sector', 'han.shot@first.galaxy',
    1, 32000.00, '2024-05-04');
CALL add_car_sale('FLY-CLOUD', 'Nimbus', '2000', 'Golden', 2020, 50000, TRUE, 
	'Goku', 'Son', '555-1234', 'Mount Paozu', 'goku@dbz.com', 
1, 55000, '2024-02-01');
CALL add_car_sale('PIRATE-SHIP', 'Thousand Sunny', 'Grand Line Edition', 'Yellow', 2022, 75000, TRUE, 
	'Monkey D.', 'Luffy', '555-2222', 'East Blue', 'luffy@onepiece.com', 
2, 80000, '2024-02-02');
CALL add_car_sale('MYSTIC-FOX', 'Kurama', 'Nine-Tails', 'Orange', 2021, 95000, TRUE, 
	'Naruto', 'Uzumaki', '555-3333', 'Hidden Leaf Village', 'naruto@naruto.com', 
3, 100000, '2024-02-03');
CALL add_car_sale('SPACE-STATION', 'Death Star', 'Imperial', 'Black', 2023, 1000000, TRUE, 
	'Darth', 'Vader', '555-4444', 'Galactic Empire', 'vader@empire.com', 
4, 1200000, '2024-02-04');


select *
from car;

select *
from customer;

select *
from invoice;

-- insert data into car mechanic table to show work done by mechanic
SELECT insert_carmechanic(4, 1, 'Flux capacitor diagnostics and hover conversion check.');
SELECT insert_carmechanic(6, 2, 'Hyperdrive lubrication and droid interface calibration.');
SELECT insert_carmechanic(5, 3, 'Restoration of ancient runes and enchantments for optimal stealth and speed.');
SELECT insert_carmechanic(2, 4, 'Overheating issue fix, and installing a state-of-the-art kitchen exhaust system.');

select *
from carmechanic;

-- insert data into parts table
SELECT insert_part('Rally-Ready Suspension Kit', 3200.00);
SELECT insert_part('Flux Capacitor Flux Enhancer', 8800.88);
SELECT insert_part('Ejector Seat Upgrade Kit', 7000.07);
SELECT insert_part('Hyperdrive Motivator', 15000.00);
SELECT insert_part('Vibranium Shield Plating', 15000);
SELECT insert_part('Arc Reactor', 25000);
SELECT insert_part('Portal Gun Adapter', 20000);
SELECT insert_part('Spell-Protected Windshield', 5000);


select *
from part;

-- insert data into service ticket table
INSERT INTO ServiceTicket (Date, Description, Car_ID, Customer_ID)
VALUES ('2024-01-10', 'Annual maintenance and rally readiness check.', 2, 2);
INSERT INTO ServiceTicket (Date, Description, Car_ID, Customer_ID)
VALUES ('2024-01-15', 'Flux capacitor tuning and general time circuit maintenance.', 4, 3);
INSERT INTO ServiceTicket (Date, Description, Car_ID, Customer_ID)
VALUES ('2024-01-20', 'Stealth mode enhancement and ejector seat servicing.', 5, 4);
INSERT INTO ServiceTicket (Date, Description, Car_ID, Customer_ID)
VALUES ('2024-01-25', 'Hyperdrive overhaul and Wookiee hair removal from the air filters.', 6, 5);
INSERT INTO ServiceTicket (Date, Description, Car_ID, Customer_ID)
VALUES 
('2024-02-05', 'Annual flying nimbus maintenance and speed enhancement.', 7, 6),
('2024-02-06', 'Waterproofing and hull reinforcement for ocean voyages.', 8, 7),
('2024-02-07', 'Chakra infusion for enhanced agility and power.', 9, 8),
('2024-02-08', 'Systems check and laser cannon calibration.', 10, 9);

select *
from serviceticket;


-- insert data into service tables
SELECT insert_serviceparts(1, 1, 1); -- Subaru gets suspension for off roading
SELECT insert_servicehistory(2, 1, 'Rally-ready suspension kit installed for improved off-road performance.');
SELECT insert_serviceparts(2, 2, 1); -- DeLorean's flux capacity enhanced for battle
SELECT insert_servicehistory(4, 2, 'Flux capacitor flux enhancer installed for smoother temporal transitions.');
SELECT insert_serviceparts(3, 3, 1); -- Bond's car gets the ejector seat upgrade
SELECT insert_servicehistory(5, 3, 'Ejector seat upgrade kit installed for... unwanted guests.');
SELECT insert_serviceparts(4, 4, 1); -- Falcon's hyperdrive motivator replaced
SELECT insert_servicehistory(6, 4, 'Hyperdrive motivator replaced for faster-than-light speed.');
SELECT insert_serviceparts(5, 5, 1); -- Goku's Nimbus gets a much needed boost
SELECT insert_servicehistory(7, 5, 'Enhanced Nimbus with speed enchantments.');
SELECT insert_serviceparts(6, 6, 2); -- Luffy is gearing up the Thousand Sunny for the final arc
SELECT insert_servicehistory(8, 6, 'Thousand Sunny reinforced for new adventures.');
SELECT insert_serviceparts(7, 7, 1); -- Naruto and Kurama training for the battle for Boruto
SELECT insert_servicehistory(9, 7, 'Kurama tuned for maximum performance.');
SELECT insert_serviceparts(8, 8, 4); -- The destruction is nearing tide
SELECT insert_servicehistory(10, 8, 'Death Star ready for galactic domination.');

select *
from servicehistory;

select *
from servicepart;


-- adding the is_serviced column --
ALTER TABLE Car
ADD COLUMN is_serviced BOOLEAN DEFAULT FALSE;

-- prcedure for is_serviced
CREATE OR REPLACE PROCEDURE update_car_serviced_status(_car_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    -- check if the car has not been serviced
    IF (SELECT is_serviced FROM Car WHERE Car_ID = _car_id) = FALSE THEN
        -- update the car's is_serviced status to TRUE
        UPDATE Car
        SET is_serviced = TRUE
        WHERE Car_ID = _car_id;
    END IF;
END;
$$;

-- check
CALL update_car_serviced_status(2);

select *
from car;
