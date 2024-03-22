 INSERT INTO dbo.DimCustomer ([GeographyKey],[CustomerAlternateKey],[Title],[FirstName],[MiddleName],[LastName],[NameStyle],[BirthDate],[MaritalStatus],
 [Suffix],[Gender],[EmailAddress],[YearlyIncome],[TotalChildren],[NumberChildrenAtHome],[EnglishEducation],[SpanishEducation],[FrenchEducation],
 [EnglishOccupation],[SpanishOccupation],[FrenchOccupation],[HouseOwnerFlag],[NumberCarsOwned],[AddressLine1],[AddressLine2],[Phone],
 [DateFirstPurchase],[CommuteDistance])
 SELECT *
 FROM dbo.StageCustomer AS stg
 WHERE NOT EXISTS
     (SELECT * FROM dbo.DimCustomer AS dim
     WHERE dim.CustomerAlternateKey = stg.CustomerAlternateKey);

 -- Type 1 updates (change name, email, or phone in place)
 UPDATE dbo.DimCustomer
 SET LastName = stg.LastName,
     EmailAddress = stg.EmailAddress,
     Phone = stg.Phone
 FROM DimCustomer dim inner join StageCustomer stg
 ON dim.CustomerAlternateKey = stg.CustomerAlternateKey
 WHERE dim.LastName <> stg.LastName OR dim.EmailAddress <> stg.EmailAddress OR dim.Phone <> stg.Phone

 -- Type 2 updates (address changes triggers new entry)
 INSERT INTO dbo.DimCustomer
 SELECT stg.GeographyKey,stg.CustomerAlternateKey,stg.Title,stg.FirstName,stg.MiddleName,stg.LastName,stg.NameStyle,stg.BirthDate,stg.MaritalStatus,
 stg.Suffix,stg.Gender,stg.EmailAddress,stg.YearlyIncome,stg.TotalChildren,stg.NumberChildrenAtHome,stg.EnglishEducation,stg.SpanishEducation,stg.FrenchEducation,
 stg.EnglishOccupation,stg.SpanishOccupation,stg.FrenchOccupation,stg.HouseOwnerFlag,stg.NumberCarsOwned,stg.AddressLine1,stg.AddressLine2,stg.Phone,
 stg.DateFirstPurchase,stg.CommuteDistance
 FROM dbo.StageCustomer AS stg
 JOIN dbo.DimCustomer AS dim
 ON stg.CustomerAlternateKey = dim.CustomerAlternateKey
 AND stg.AddressLine1 <> dim.AddressLine1;


-- Post Load Optimization
 -- alter index all on dbo.DimProduct rebuild; --uncomment after the UPSERT query above

 -- create statistics customergeo_stats on dbo.DimCustomer (GeographyKey); -- uncomment after the UPSERT query
