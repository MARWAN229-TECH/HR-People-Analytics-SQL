 
 with department_atttrition_summary as (
 select
 Department,
 count(*) as total_emp,
 round(avg(MonthlyIncome),1) as avg_MonthlyIncome,
 sum(case when Attrition='Yes' then 1 end ) as attrition_count,
  round(sum(case when Attrition='Yes' then 1 end )*100/count(*),2) as attrition_rate,
 round(avg(case when Attrition ='Yes' then JobSatisfaction end),1) as avg_satisfaction_attrited
 from employees 
 group by Department
),

job_role_attrition as (
select
 JobRole,
 Department,
 count(*) as emp_count,
 sum(case when Attrition='Yes' then 1 end ) as attrition_count,
 round(sum(case when Attrition='Yes' then 1 end )*100/count(*),2) as attrition_rate,
 round(avg(MonthlyIncome),1) as avg_MonthlyIncome
 from employees
 group by JobRole, Department
  having count(*)>5),
 satisfaction_overime_analysis as (
 select
Attrition,
 count(*) as emp_count,
sum(case when Overtime='Yes' then 1 end ) as Overtime_count,
 round(sum(case when Overtime='Yes' then 1 end )*100/count(*),2) as Overtime_rate,
 round(avg(WorkLifeBalance),1) as avg_WorkLifeBalance,
 round(avg(EnvironmentSatisfaction),1) as avg_EnvironmentSatisfaction,
 ROUND(AVG(JobSatisfaction), 1) AS avg_JobSatisfaction
 from employees
 group by Attrition),

Tenure_promotion_analysis as (
select
Attrition,
round(avg(TotalWorkingYears),0) as avg_TotalWorkingYears,
round(avg(YearsAtCompany),0) as avg_YearsAtCompany,
round(avg(YearsInCurrentRole),0) as avg_YearsInCurrentRole,
ROUND(AVG(YearsSinceLastPromotion), 0) AS avg_years_since_promo
from employees
 group by Attrition),

At_risk_employees as (
select
EmployeeNumber,
JobRole,
Department,
MonthlyIncome,
JobSatisfaction,
Overtime
 from employees 
 where 
 OverTime = 'Yes' and 
 JobSatisfaction < 3 and
 WorkLifeBalance < 3 and 
 Attrition = 'No')
 select*from At_risk_employees;
 
 
 
 with Income_by_experience as(
 select 

 CASE 
  WHEN TotalWorkingYears<=5 THEN 'Entry'
  WHEN TotalWorkingYears<=10 THEN 'Intermediate'
WHEN TotalWorkingYears<=15 THEN 'Senior'
ELSE 'Veteran' END AS experience_tier,
 round(avg(MonthlyIncome),0) as avg_Monthly_income,
 count(*) as emp_count
from employees 
group by experience_tier),

Income_by_JobLevel as (
select
JobLevel,
count(*) as emp_count,
round(avg(MonthlyIncome),0) as avg_Monthly_income
from employees 
group by JobLevel),

Income_By_Department as (
select 
Department,
JobRole,
count(*) as emp_count,
round(avg(MonthlyIncome),0) as avg_Monthly_income
from employees 
group by Department,JobRole),
Income_by_PerformanceRating as(
select
PerformanceRating,
count(*) as emp_count,
round(avg(MonthlyIncome),0) as avg_Monthly_income
from employees 
group by PerformanceRating),

Income_by_Overtime as (
select
 Department,
Overtime,
count(*) as emp_count,
round(avg(MonthlyIncome),0) as avg_Monthly_income
from employees
GROUP BY Department, Overtime)
select* from Income_by_experience;




with promotion_pattern as (
select
 CASE 
            WHEN YearsSinceLastPromotion = 0 THEN 'Recently Promoted'
            WHEN YearsSinceLastPromotion <= 3 THEN 'Review Period'
            ELSE 'Overdue for Promotion' 
        END AS promotion_timing,
SUM(CASE WHEN Attrition = 'Yes' THEN 1 END) AS attrition_count,
ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*), 2) AS attrition_rate,
count(*) as emp_count
 from employees
 group by promotion_timing),

promotion_ready as (
select
case 
 when YearsSinceLastPromotion>=2 and
 PerformanceRating>3 and
 YearsAtCompany>4 and
 JobLevel<5 then 'Due Promotion'
 else 'Stay In Role' end as Promotion_category,
count(*) as emp_count
from employees
group by Promotion_category),

Promotion_Department AS (
    SELECT
        Department,
        CASE 
            WHEN YearsSinceLastPromotion >= 2 
                AND PerformanceRating > 3 
                AND YearsAtCompany > 4 
                AND JobLevel < 5 
            THEN 'Due Promotion'
            ELSE 'Stay In Role' 
        END AS Promotion_category,
        COUNT(*) AS emp_count,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 END) AS attrition_count,
        ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*), 2) AS attrition_rate
    FROM employees
    GROUP BY Department, Promotion_category
),

Promotion_Ready_Detail AS (
SELECT
EmployeeNumber,
Department,
JobRole, 
JobLevel, 
PerformanceRating, 
YearsSinceLastPromotion, 
YearsAtCompany
FROM employees 
where YearsSinceLastPromotion >= 2 
        AND PerformanceRating > 3 
        AND YearsAtCompany > 4 
        AND JobLevel < 5
        AND Attrition = 'No'),
        
       Promotion_Impact_Analysis AS (
    SELECT
        CASE 
            WHEN YearsSinceLastPromotion = 0 THEN 'Recently Promoted'
            WHEN YearsSinceLastPromotion >= 2 
                AND PerformanceRating > 3 
                AND YearsAtCompany > 4 
                AND JobLevel < 5 
            THEN 'Due Promotion'
            ELSE 'Other'
        END AS promotion_status,
        COUNT(*) AS emp_count,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 END) AS attrition_count,
        ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*), 2) AS attrition_rate
    FROM employees
    GROUP BY promotion_status
)

select*from Promotion_Impact_Analysis;