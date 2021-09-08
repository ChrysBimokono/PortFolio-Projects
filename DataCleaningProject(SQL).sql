/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Cleaning].[dbo].[NashvilleHousing]

  --Cleaning Data in SQL by first standardizing Data Format

  SELECT SaleDate, SaleDateConverted,CONVERT(Date,SaleDate)
  FROM [dbo].[NashvilleHousing]

  UPDATE NashvilleHousing
  SET SaleDate=CONVERT(Date,SaleDate)
  
  --Creating a new column
  ALTER TABLE NashvilleHousing
  ADD SaleDateConverted DATE

  --populating the new column with converted value into date
  UPDATE NashvilleHousing
  SET SaleDateConverted=CONVERT(Date,SaleDate)

  --Populate Property Addres Data

SELECT *
FROM [dbo].[NashvilleHousing]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--We noticed that ParcelID correspond to a PropertyAddress
--two same ParcelID indicate same PropertyAddress

-- We therefore use that info to populate PropertyAddress where there is null
--Using the ISNULL Function to populate the missing values

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
on a.ParcelID= b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
on a.ParcelID= b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Separating Address into individual columns(Address, City, State)

SELECT PropertyAddress
FROM [dbo].[NashvilleHousing]

SELECT
PropertyAddress
,SUBSTRING(PropertyAddress,1,(CHARINDEX(',',PropertyAddress)-1)) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
--CHARINDEX(',',PropertyAddress))) as City

FROM [dbo].[NashvilleHousing]

--We then Create these two column

  ALTER TABLE NashvilleHousing
  ADD SplitAddress NVARCHAR(225)

   UPDATE NashvilleHousing
  SET SplitAddress=SUBSTRING(PropertyAddress,1,(CHARINDEX(',',PropertyAddress)-1))

  --New City Column
  ALTER TABLE NashvilleHousing
  ADD SplitCity NVARCHAR(225)

   UPDATE NashvilleHousing
  SET SplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM [dbo].[NashvilleHousing]

--Dealing with the OwnerAddress

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM [dbo].[NashvilleHousing]

-- Creating separate columns for address, city, state partaining to the OwnerAddress

ALTER TABLE NashvilleHousing
  ADD OwnerSplitAddress NVARCHAR(225)


   UPDATE NashvilleHousing
  SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

  --New City Column
  ALTER TABLE NashvilleHousing
  ADD OwnerSplitCity NVARCHAR(225)

   UPDATE NashvilleHousing
  SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

  --New city State
  ALTER TABLE NashvilleHousing
  ADD OwnerSplitState NVARCHAR(225)

   UPDATE NashvilleHousing
  SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

  SELECT *
FROM [dbo].[NashvilleHousing]

--Changing the y/n to YES/NO from SoldAs Vacant Column

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM [dbo].[NashvilleHousing]
GROUP BY SoldAsVacant

SELECT SoldAsVacant
  ,CASE WHEN SoldAsVacant= 'Y' THEN 'YES'
       WHEN SoldAsVacant= 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [dbo].[NashvilleHousing]

UPDATE NashvilleHousing
SET SoldAsVacant= CASE WHEN SoldAsVacant= 'Y' THEN 'YES'
       WHEN SoldAsVacant= 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- REMOVE DUPLICATES 
--we run our CTE with Windown function

WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
	             SalePrice,
	             SaleDate,
	             LegalReference
	             ORDER BY
	                 UniqueID) row_num
FROM [dbo].[NashvilleHousing]
--ORDER BY ParcelID
)
DELETE *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress


-- Delete unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict,SaleDate