use project;
-- Q1. Total Revenue
select sum(revenue_realized) as 'Total Revenue'
from fact_bookings;

-- Q2. Occupancy %
SELECT ROUND(SUM(successful_bookings) * 100.0 / SUM(capacity),2) AS occupancy_percentage
FROM `fact_aggregated_bookings (1)`;

-- 	Q3. Cancellation rate
SELECT ROUND(COUNT(CASE WHEN booking_status = 'Cancelled' THEN 1 END) * 100.0/ COUNT(booking_id),2) AS cancellation_rate
FROM fact_bookings;

-- Q4. Total Booking
SELECT COUNT(booking_id) AS total_bookings
FROM fact_bookings;

-- Q5. Utilize Capacity
SELECT ROUND(SUM(successful_bookings) / SUM(capacity) * 100, 2) AS utilized_capacity_pct
FROM `fact_aggregated_bookings (1)`;

-- Q6.Trend Analysis
SELECT 
    d.`mmm yy` AS month_year,
    MIN(STR_TO_DATE(d.date, '%d-%b-%y')) AS month_date,
    SUM(f.revenue_realized) AS total_revenue
FROM fact_bookings f
JOIN dim_date d
    ON DATE(f.check_in_date) = STR_TO_DATE(d.date, '%d-%b-%y')
GROUP BY d.`mmm yy`
ORDER BY month_date;

-- Q7.Weekday & Weekend Revenue and Booking
SELECT 
    d.day_type,
    COUNT(f.booking_id) AS total_bookings,
    SUM(f.revenue_realized) AS total_revenue
FROM fact_bookings f
JOIN dim_date d
    ON DATE(f.check_in_date) = STR_TO_DATE(d.date, '%d-%b-%y')
GROUP BY d.day_type;

-- Q8. Revenue by city & Hotel
SELECT
    h.city,
    h.property_name,
    SUM(f.revenue_realized) AS total_revenue
FROM fact_bookings f
JOIN dim_hotels h
    ON f.property_id = h.property_id
GROUP BY h.city, h.property_name
ORDER BY total_revenue DESC;

-- Q9. Class wise revenue
SELECT
    r.room_class,
    SUM(f.revenue_realized) AS total_revenue
FROM fact_bookings f
JOIN dim_rooms r
    ON f.room_category = r.room_id
GROUP BY r.room_class
ORDER BY total_revenue DESC;


-- Q10. Checked-Out, Cancelled & No-Show
SELECT
    booking_status,
    COUNT(booking_id) AS booking_count
FROM fact_bookings
GROUP BY booking_status;
SELECT
    booking_status,
    COUNT(booking_id) AS booking_count,
    ROUND(
        COUNT(booking_id) * 100.0 /
        (SELECT COUNT(*) FROM fact_bookings),
        2
    ) AS booking_percentage
FROM fact_bookings
GROUP BY booking_status;

-- Q11.Weekly trend Key trend(Revenue,Total Booking,Occupancy)
SELECT
    d.`week no`,
    
    -- Revenue
    SUM(f.revenue_realized) AS total_revenue,
    
    -- Total Bookings
    COUNT(f.booking_id) AS total_bookings
FROM dim_date d

LEFT JOIN fact_bookings f
    ON DATE(f.check_in_date) = STR_TO_DATE(d.date, '%d-%b-%y')

LEFT JOIN `fact_aggregated_bookings (1)` a
    ON a.check_in_date = STR_TO_DATE(d.date, '%d-%b-%y')

GROUP BY d.`week no`
ORDER BY CAST(SUBSTRING(d.`week no`, 3) AS UNSIGNED);


-- 11 Weekly Occupancy percentage
WITH dim_date_conv AS (
    SELECT 
        `week no`,
        STR_TO_DATE(date, '%d-%b-%y') AS date_converted
    FROM dim_date
)
SELECT
    d.`week no`,
    
    -- Occupancy %
    ROUND(
        CASE
            WHEN SUM(IFNULL(a.capacity, 0)) = 0 THEN 0
            ELSE SUM(IFNULL(a.successful_bookings, 0)) * 100.0 / SUM(IFNULL(a.capacity, 0))
        END,
        2
    ) AS occupancy_percentage

FROM dim_date_conv d

LEFT JOIN `fact_aggregated_bookings (1)` a
    ON STR_TO_DATE(a.check_in_date, '%d-%b-%y') = d.date_converted

GROUP BY d.`week no`
ORDER BY CAST(SUBSTRING(d.`week no`, 3) AS UNSIGNED);                                

