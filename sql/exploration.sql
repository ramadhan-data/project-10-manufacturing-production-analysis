-- Project 10: Hybrid Manufacturing Job Analysis
-- SQL Exploration Phase

-- 1. Overall job status distribution
SELECT Job_Status, COUNT(*) AS job_count,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM production_jobs), 1) AS pct
FROM production_jobs
GROUP BY Job_Status
ORDER BY job_count DESC;

-- 2. Machine performance summary
SELECT Machine_ID,
       COUNT(*) AS total_jobs,
       SUM(CASE WHEN Job_Status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_count,
       SUM(CASE WHEN Job_Status = 'Failed' THEN 1 ELSE 0 END) AS failed_count,
       ROUND(100.0 * SUM(CASE WHEN Job_Status IN ('Delayed','Failed') THEN 1 ELSE 0 END) / COUNT(*), 1) AS problem_rate_pct,
       ROUND(AVG(Energy_Consumption), 2) AS avg_energy,
       ROUND(AVG(Machine_Availability), 1) AS avg_availability
FROM production_jobs
GROUP BY Machine_ID
ORDER BY problem_rate_pct DESC;

-- 3. Operation type performance summary
SELECT Operation_Type,
       COUNT(*) AS total_jobs,
       SUM(CASE WHEN Job_Status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_count,
       SUM(CASE WHEN Job_Status = 'Failed' THEN 1 ELSE 0 END) AS failed_count,
       ROUND(100.0 * SUM(CASE WHEN Job_Status IN ('Delayed','Failed') THEN 1 ELSE 0 END) / COUNT(*), 1) AS problem_rate_pct,
       ROUND(AVG(Energy_Consumption), 2) AS avg_energy,
       ROUND(AVG(Processing_Time), 1) AS avg_processing_time
FROM production_jobs
GROUP BY Operation_Type
ORDER BY problem_rate_pct DESC;

-- 4. Optimization_Category cross-check against actual Job_Status
-- (validates client's warning: category should NOT be trusted blindly)
SELECT Job_Status, Optimization_Category, COUNT(*) AS job_count
FROM production_jobs
GROUP BY Job_Status, Optimization_Category
ORDER BY Job_Status, job_count DESC;

-- 5. Energy efficiency by category (Completed jobs only, since all Delayed/Failed = "Low Efficiency" by default)
SELECT Optimization_Category,
       COUNT(*) AS job_count,
       ROUND(AVG(Energy_Consumption), 2) AS avg_energy,
       ROUND(AVG(Processing_Time), 1) AS avg_processing_time,
       ROUND(AVG(Energy_Consumption / Material_Used), 3) AS avg_energy_per_material
FROM production_jobs
WHERE Job_Status = 'Completed'
GROUP BY Optimization_Category
ORDER BY avg_energy DESC;

-- 6. Machine x Operation combination failure hotspots
SELECT Machine_ID, Operation_Type,
       COUNT(*) AS total_jobs,
       SUM(CASE WHEN Job_Status = 'Failed' THEN 1 ELSE 0 END) AS failed_jobs,
       ROUND(100.0 * SUM(CASE WHEN Job_Status = 'Failed' THEN 1 ELSE 0 END) / COUNT(*), 1) AS failure_rate_pct
FROM production_jobs
GROUP BY Machine_ID, Operation_Type
ORDER BY failure_rate_pct DESC
LIMIT 10;

-- 7. Machine availability distribution across job outcomes
SELECT Job_Status,
       MIN(Machine_Availability) AS min_avail,
       ROUND(AVG(Machine_Availability), 1) AS avg_avail,
       MAX(Machine_Availability) AS max_avail
FROM production_jobs
GROUP BY Job_Status;

-- 8. Top 10 most energy-intensive completed jobs (candidates for inefficiency investigation)
SELECT Job_ID, Machine_ID, Operation_Type, Energy_Consumption, Processing_Time, Optimization_Category
FROM production_jobs
WHERE Job_Status = 'Completed'
ORDER BY Energy_Consumption DESC
LIMIT 10;
