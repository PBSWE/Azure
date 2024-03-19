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
