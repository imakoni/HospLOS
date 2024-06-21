.issions this period
SELECT
COUNT(PatientMRN) as TotalPatients
FROM
dbo.Patients;

--Number of Patients Discharged from the hospital 
SELECT
COUNT(PatientID) as DischargedPatients
FROM dbo.Discharges;

-- Calculate the difference between LOS and expected LOS per primary diagnosis
SELECT 
PrimaryDiagnosis,
ExpectedLOS,
AdmissionDate,
DischargeDate,
DATEDIFF(DAY,AdmissionDate,DischargeDate) AS LengthofStayInDays,
ExpectedLOS - DATEDIFF(DAY,AdmissionDate,DischargeDate) AS DIFF
FROM
dbo.Discharges 
GROUP BY PrimaryDiagnosis, ExpectedLOS, AdmissionDate,DischargeDate
ORDER BY LengthofStayInDays DESC;

--Determine the primary diagnoses with the highest LOS
SELECT 
PrimaryDiagnosis,
ExpectedLOS,
AdmissionDate,
DischargeDate,
DATEDIFF(DAY,AdmissionDate,DischargeDate) AS LengthofStayInDays
FROM
dbo.Discharges 
GROUP BY PrimaryDiagnosis, ExpectedLOS, AdmissionDate,DischargeDate
ORDER BY LengthofStayInDays DESC;

-- Determine Average LOS by Gender
SELECT
Gender,
AVG(DATEDIFF(DAY, AdmissionDate,DischargeDate)) AS AvgLengthOfStay, COUNT(*) AS TotalPatients,
CAST(Avg(ExpectedLOS) AS FLOAT) /(SELECT AVG(ExpectedLOS) FROM Discharges) * 100 AS PERCENTAGEOFAvgLengthOfStay
FROM
Discharges
JOIN Patients p ON PatientMRN = p.PatientMRN
WHERE Gender IS NOT NULL
GROUP BY Gender;

--To obtain the Average Length of Stay according to race
SELECT
p.Race,
AVG(DATEDIFF(DAY, d.AdmissionDate,d.DischargeDate)) AS AvgLengthOfStay
FROM
Discharges d
JOIN Patients p ON d.AdmissionID = p.PatientMRN
WHERE Race IS NOT NULL
GROUP BY p.Race;

--To determine the demographic that spent the highest higher number of days in the hospital
SELECT
AdmissionID,
Race,
AVG(DATEDIFF(DAY, AdmissionDate,DischargeDate)) AS AvgLengthOfStay,
  SUM(AVG(DATEDIFF(DAY, AdmissionDate, DischargeDate))) 
OVER(PARTITION BY Race) AS TotalLengthOFStay
FROM Discharges d
JOIN Patients p ON d.AdmissionID = p.PatientMRN
WHERE Race IS NOT NULL
Group by d.AdmissionID, p.Race;

--CTE to calculate Length of Stay for each patient
WITH LOS_CTE AS (
	SELECT
	AdmissionID,
	AdmissionDate,
	DischargeDate,
	DATEDIFF(DAY, AdmissionDate, DischargeDate) AS LOS
FROM 
dbo.Discharges
)
SELECT
	AdmissionID,
	Race,
	LOS
   
FROM 
	LOS_CTE
JOIN 
Patients ON AdmissionID = PatientMRN;



--DischargeDisposition by Average LOS
SELECT
DischargeDisposition,
 AVG(DATEDIFF(DAY, AdmissionDate,DischargeDate)) AS AvgLengthOfStay
FROM 
dbo.Discharges
GROUP BY DischargeDisposition
ORDER BY DischargeDisposition DESC;

-- AVG LOS according to Primary Diagnosis
SELECT 
d.PrimaryDiagnosis,
AVG(DATEDIFF(DAY, AdmissionDate,DischargeDate)) AS AvgLengthOfStay
FROM
dbo.Discharges d
JOIN
Patients p ON d.PatientID = p.PatientMRN
GROUP BY d.PrimaryDiagnosis
HAVING
COUNT (PrimaryDiagnosis) > 10
ORDER BY  AvgLengthOfStay DESC;

--Discharge disposition by Number of Patients
SELECT 
DischargeDisposition,
COUNT(*) AS NumberofPatients
FROM
	(SELECT
	CASE 
	    WHEN DischargeDisposition = 'Transfer' THEN 'Transfer'
		WHEN DischargeDisposition  = 'Expired' THEN 'Death'
		WHEN DischargeDisposition  = 'Home' THEN 'Home'
		ELSE 'Other'
		END AS DischargeDisposition
		FROM dbo.Discharges) as DischargeCategories
		GROUP BY  DischargeDisposition
		ORDER BY NumberofPatients DESC;

--DischargeDisposition by Average LOS
SELECT
DischargeDisposition,
 AVG(DATEDIFF(DAY, AdmissionDate,DischargeDate)) AS AvgLengthOfStay
FROM 
dbo.Discharges
GROUP BY  DischargeDisposition
ORDER BY DischargeDisposition DESC;


