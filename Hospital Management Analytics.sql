
				     -- Project Title: "Hospital Management Analytics: Patient & Doctor Insights"
                     
 -- Objective: To design and analyze a database for a hospital that tracks patient records, doctor schedules, appointments, and billing. 
 -- The goal is to generate actionable insights for hospital management, such as identifying peak hours, common ailments, and doctor 
 -- workload.


create database Hospital_Management_Analytics;

-- creation of patients table

create table Patients (
    PatientID int primary key auto_increment,
    Patient_Name varchar(100) not null,
    Age int not null,
    Gender enum('Male', 'Female', 'Other') not null,
    Address varchar(200),
    PhoneNumber varchar(50),
    Date_of_registration date not null
);

-- Created stored procedure for Insertion of random values in Patients table

DELIMITER $$
CREATE PROCEDURE PopulatePatients()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 200 DO
        INSERT INTO Patients (Patient_Name, Age, Gender, Address, PhoneNumber, Date_of_registration)
        VALUES (
            CONCAT('Patient_', i),
            FLOOR(18 + (RAND() * 70)), -- Random age between 18 and 87
            IF(i % 2 = 0, 'Male', 'Female'),
            CONCAT('Address_', i),
            CONCAT('98765', LPAD(i, 5, '0')), -- Generates unique phone numbers
            CURDATE() - INTERVAL FLOOR(RAND() * 365) DAY
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

call PopulatePatients();

select * from Patients;

-- creation of Doctors table

create table Doctors (
DoctorID int primary key auto_increment,
Doctor_Name varchar(100) not null,
Specialty Varchar(100) not null,
Experience int not null,
PhoneNumber varchar(15) unique
);

-- Created stored procedure for Insertion of random values in Doctors table

DELIMITER $$
CREATE PROCEDURE PopulateDoctors()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE specialties VARCHAR(255);
    SET specialties = 'Cardiologist,Dermatologist,Orthopedic,Neurologist,Pediatrician';
    
    WHILE i <= 30 DO
        INSERT INTO Doctors (Doctor_Name, Specialty, Experience, PhoneNumber)
        VALUES (
            CONCAT('Doctor_', i),
            ELT(FLOOR(1 + (RAND() * 5)), 'Cardiologist', 'Dermatologist', 'Orthopedic', 'Neurologist', 'Pediatrician'),
            FLOOR(5 + (RAND() * 30)), -- Random experience between 5 and 34 years
            CONCAT('98760', LPAD(i, 5, '0')) -- Generates unique phone numbers
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

call PopulateDoctors();

select * from Doctors;

-- creation of Appointments table

create table Appointments(
AppointmentID int primary key auto_increment ,
PatientID int ,
foreign key (PatientID) references Patients(PatientID),
DoctorID int ,
foreign key(DoctorID) references Doctors(DoctorID),
Appointment_date date,
Appointment_time time,
Appointment_status enum('Completed', 'Cancelled') default 'Completed'
);

-- Created stored procedure for Insertion of random values in Appointments table

DELIMITER $$
CREATE PROCEDURE PopulateAppointments()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 200 DO
        INSERT INTO Appointments (PatientID, DoctorID, Appointment_date, Appointment_time, Appointment_status)
        VALUES (
            FLOOR(1 + (RAND() * 200)), -- Random PatientID
            FLOOR(1 + (RAND() * 30)), -- Random DoctorID
            CURDATE() - INTERVAL FLOOR(RAND() * 180) DAY, -- Random date in the past 6 months
            TIME(FROM_UNIXTIME(FLOOR(RAND() * 86400))), -- Random time
            IF(RAND() < 0.8, 'Completed', 'Cancelled') -- 80% chance for "Completed"
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

call PopulateAppointments;

select * from Appointments;

-- creation of Treatments table

create table Treatments(
TreatmentID int Primary Key auto_increment,
PatientID int ,
foreign key (PatientID) references Patients(PatientID),
DoctorID int ,
foreign key(DoctorID) references Doctors(DoctorID),
Diagnosis text,
Prescription text,
Treatment_date date not null
);

-- Created stored procedure for Insertion of random values in Treatments table

DELIMITER $$
CREATE PROCEDURE PopulateTreatments()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 200 DO
        INSERT INTO Treatments (PatientID, DoctorID, Diagnosis, Prescription, Treatment_date)
        VALUES (
            FLOOR(1 + (RAND() * 200)), -- Random PatientID
            FLOOR(1 + (RAND() * 30)), -- Random DoctorID
            CONCAT('Diagnosis_', FLOOR(RAND() * 100)),
            CONCAT('Prescription_', FLOOR(RAND() * 100)),
            CURDATE() - INTERVAL FLOOR(RAND() * 180) DAY
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

CALL PopulateTreatments();

select * from Treatments;

-- creation of Billing table

create table Billing(
BillID int Primary Key auto_increment,
PatientID int ,
foreign key (PatientID) references Patients(PatientID),
TreatmentID int,
foreign key (TreatmentID) references Treatments(TreatmentID),
Amount decimal(10,2) not null,
PaymentStatus enum('Paid', 'Pending') default 'Pending',
PaymentDate date
);

-- Created stored procedure for Insertion of random values in Billing table

DELIMITER $$
CREATE PROCEDURE PopulateBilling()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 200 DO
        INSERT INTO Billing (PatientID, TreatmentID, Amount, PaymentStatus, PaymentDate)
        VALUES (
            FLOOR(1 + (RAND() * 200)), -- Random PatientID
            FLOOR(1 + (RAND() * 200)), -- Random TreatmentID
            ROUND(RAND() * 950 + 50, 2), -- Random amount between 50 and 1000
            IF(RAND() < 0.7, 'Paid', 'Pending'), -- 70% chance for "Paid"
            IF(RAND() < 0.7, CURDATE() - INTERVAL FLOOR(RAND() * 180) DAY, NULL)
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

CALL PopulateBilling();

select * from Billing;

-- Basic Queries: 
-- a.Fetch all patient details who registered in the last 30 days.

SELECT 
    *
FROM
    Patients
WHERE
    Date_of_registration >= (CURDATE() - INTERVAL 30 DAY)
ORDER BY Date_of_registration DESC;

-- b.List all appointments for a specific doctor in a given date range.

SELECT 
    a.AppointmentID,
    a.PatientID,
    a.Appointment_date,
    a.Appointment_status,
    a.DoctorID,
    d.Doctor_Name
FROM
    Appointments a
        JOIN
    Doctors d ON a.DoctorID = d.DoctorID
WHERE
    d.Doctor_Name = 'Doctor_7'
        AND a.Appointment_date BETWEEN '2024-08-01' AND '2024-11-30'
ORDER BY a.Appointment_date;

-- Intermediate Queries:
-- a.Identify the doctor with the most appointments in the last month.

SELECT 
    a.DoctorID,
    d.Doctor_Name,
    COUNT(AppointmentID) AS No_of_appointments
FROM
    Appointments a
        JOIN
    Doctors d ON a.DoctorID = d.DoctorID
WHERE
    MONTH(Appointment_date) = MONTH(CURDATE() - INTERVAL 1 MONTH)
GROUP BY DoctorID
ORDER BY No_of_appointments DESC
LIMIT 1;

-- b.Calculate the total revenue generated by the hospital in the last quarter.

SELECT 
    SUM(Amount) AS lastquarter_revenue
FROM
    Billing
WHERE
    PaymentStatus = 'paid'
        AND QUARTER(PaymentDate) = QUARTER(CURDATE() - INTERVAL 1 QUARTER);

 -- c.Find patients who have missed or canceled more than 3 appointments.
 
 select a.patientID,p.Patient_Name,count(Appointment_status) as no_of_appointments from Appointments a join Patients p
 on a.PatientID = p.PatientID where Appointment_status = 'cancelled'
 group by PatientID having no_of_appointments > 3;
 
 -- Here in dataset as i don't have patients who cancelled their appointments more than 3 
 -- so i took more than 1 in below query to show the output.
 
  SELECT 
    a.patientID,
    p.Patient_Name,
    COUNT(Appointment_status) AS no_of_appointments
FROM
    Appointments a
        JOIN
    Patients p ON a.PatientID = p.PatientID
WHERE
    Appointment_status = 'cancelled'
GROUP BY PatientID
HAVING no_of_appointments > 1;
 
-- Advanced Queries:

-- a.Determine the most common diagnosis provided by each doctor.
SELECT 
    t.DoctorID,
    d.Doctor_Name,
    t.Diagnosis,
    COUNT(t.Diagnosis) AS Diagnosiscount
FROM
    treatments t
        JOIN
    doctors d ON t.DoctorID = d.DoctorID
GROUP BY t.DoctorID , t.Diagnosis
HAVING COUNT(t.diagnosis) = (SELECT 
        MAX(Diagnosiscount)
    FROM
        (SELECT 
            t.DoctorID, COUNT(t.Diagnosis) AS Diagnosiscount
        FROM
            treatments t
        GROUP BY t.DoctorID , t.Diagnosis) AS MaxDiagnosis
    WHERE
        MaxDiagnosis.DoctorID = t.DoctorID);

-- or
-- Query using Views

create view Diagnosis_counts as select t.DoctorID,d.Doctor_Name,t.Diagnosis, count(Diagnosis) as Diagnosiscount 
from treatments t join doctors d 
on t.DoctorID=d.DoctorID group by t.DoctorID,t.Diagnosis;
select * from Diagnosis_counts;

create view Maxcounts as select Doctor_Name,max(Diagnosiscount) as Maxcount from Diagnosis_counts group by Doctor_Name;
select * from Maxcounts;

select d.Doctor_Name, d.Diagnosis,d.Diagnosiscount
from Diagnosis_counts d join Maxcounts m
on d.Doctor_Name = m.Doctor_Name and d.Diagnosiscount = m.Maxcount;

 -- b.Analyze peak hours for appointments and suggest time slots for more efficient scheduling. 
 
SELECT 
    HOUR(Appointment_time) AS hour,
    COUNT(AppointmentID) AS appointments_count
FROM
    appointments
GROUP BY hour
ORDER BY appointments_count DESC;

-- By seeing below output we can observe that peak hours are at 3 am, 11 pm, 5 pm, 12 am, 2 am ,5 am ,8 am ,1 pm
-- so we observe most of the peak hours in early morning time and late nights so if we have more staff in this peak hours 
-- it will be helpful for the patients. And it's better to take appointments in after noon time as the appointments are less in that time

-- c.Generate a monthly revenue breakdown by doctor specialty.

SELECT 
    d.Specialty,
    YEAR(b.PaymentDate) AS Year,
    MONTH(b.PaymentDate) AS Month,
    SUM(b.Amount) AS Monthly_Revenue
FROM
    Billing b
        JOIN
    Treatments t ON b.TreatmentID = t.TreatmentID
        JOIN
    Doctors d ON t.DoctorID = d.DoctorID
WHERE
    b.PaymentStatus = 'paid'
GROUP BY d.Specialty , Month , Year
ORDER BY Month DESC , Year DESC , d.specialty;


-- INSIGHTS :

-- 1. We observed that 18 patients got registered in the last 30 days.
-- 2. The doctor with the most appointments in the last month is 'Doctor_11' with '5 appointments' who is specialised in 'Pediatrician'.
-- 3. The total revenue generated by the hospital in the last quarter is '₹ 25,108.09'
-- 4. The patients who have missed or cancelled more than 1 appointment are very less.
--    In 2024 we observed that only 2 patients have cancelled their appointments.
-- 5. The most common diagnosis provided by Doctor_4 is Diagnosis_64 , Doctor_19 is Diagnosis_59, Doctor_24 is Diagnosis_17 
--    along with other diagnosis, But the remaining docotors are treating multiple diagnosis they don't have any common diagnosis.
-- 6. we observed most of the peak hours are in early morning time and late nights so if we have more staff in this peak hours 
--    it will be helpful for the patients. And it's better to take appointments in after noon time as the appointments are less 
--    in that time.
-- 7. Monthly revenue by doctor speciality: 
--    'Pediatrician' and 'Cardiologist's' monthly revenue is 'high' where as 'Neurologist' monthly revenue is medium that is 
--    better than  'Dermatologist' and 'Orthopedic' whose monthly revenue is very less compared to other specialities.
