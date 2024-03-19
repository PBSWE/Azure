-- Querying data warehouse tables (star and snowflake examples)

-- Example of snowflake dimension and aggregate for yearly regional sales by product category:
select d.CalendarYear as Year,
       pc.EnglishProductCategoryName as ProductCategory,
       g.EnglishCountryRegionName as Region,
    sum(i.SalesAmount) as InternetSalesAmount
from FactInternetSales i
join DimDate d on i.OrderDateKey = d.DateKey
join DimCustomer c on i.CustomerKey = c.CustomerKey
join DimGeography g on c.GeographyKey = g.GeographyKey
join DimProduct p on i.ProductKey = p.ProductKey
join DimProductSubcategory ps on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
join DimProductCategory pc on ps.ProductCategoryKey = pc.ProductCategoryKey
group by d.CalendarYear, pc.EnglishProductCategoryName, g.EnglishCountryRegionName
order by Year, ProductCategory, Region;


-- Sales values for 2022 over partitions based on Region name
select g.EnglishCountryRegionName as Region,
    ROW_NUMBER() over(PARTITION by g.EnglishCountryRegionName
                        order by i.SalesAmount asc) as RowNumber,
    i.SalesOrderNumber as OrderNo,
    i.SalesOrderLineNumber as LineItem,
    i.SalesAmount as SalesAmount,
    sum(i.SalesAmount) over(PARTITION by g.EnglishCountryRegionName) as RegionTotal,
    avg(i.SalesAmount) over(PARTITION by g.EnglishCountryRegionName) as RegionAverage
from FactInternetSales i
join DimDate d on i.OrderDateKey = d.DateKey
join DimCustomer c on i.CustomerKey = c.CustomerKey
join DimGeography g on c.GeographyKey = g.GeographyKey
where d.CalendarYear = 2022
order by Region;


-- Rank the Cities in each Region based on total sales amount
select g.EnglishCountryRegionName as Region,
       g.City,
       sum(i.SalesAmount) as CityTotal,
       sum(sum(i.SalesAmount)) over(PARTITION by g.EnglishCountryRegionName) as RegionTotal,
       rank() over(PARTITION by g.EnglishCountryRegionName
            order by sum(i.SalesAmount) desc) as RegionalRank
from FactInternetSales i
join DimDate d on i.OrderDateKey = d.DateKey
join DimCustomer c on i.CustomerKey = c.CustomerKey
join DimGeography g on c.GeographyKey = g.GeographyKey
group by g.EnglishCountryRegionName, g.City
order by Region;


-- Retrieving Approximate Count for lesser time and resources at runtime
--- Example 1: execution time of +/- 00:00:08.818
select d.CalendarYear as CalendarYear,
    count(distinct i.SalesOrderNumber) as Orders
from FactInternetSales i
join DimDate d on i.OrderDateKey = d.DateKey
group by d.CalendarYear
order by CalendarYear;

--- Example 2: execution time of +/- 00:00:03.619
--- Results should be within 2% of the actual counts
select d.CalendarYear as CalendarYear,
    APPROX_COUNT_DISTINCT(i.SalesOrderNumber) as Orders
from FactInternetSales i
join DimDate d on i.OrderDateKey = d.DateKey
group by d.CalendarYear
order by CalendarYear;