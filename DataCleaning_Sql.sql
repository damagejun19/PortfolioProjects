/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.NashbillHousing

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashbillHousing


Update NashbillHousing
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE NashbillHousing
Add SaleDateConverted Date;


Update NashbillHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashbillHousing
--where PropertyAddress is Null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashbillHousing a
JOIN PortfolioProject.dbo.NashbillHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashbillHousing a
JOIN PortfolioProject.dbo.NashbillHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashbillHousing
--where PropertyAddress is Null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashbillHousing


ALTER TABLE NashbillHousing
Add propertySplitAddress Nvarchar(255);


Update NashbillHousing
SET propertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashbillHousing
Add propertySplitCity Nvarchar(255);


Update NashbillHousing
SET propertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashbillHousing


Select OwnerAddress
From PortfolioProject.dbo.NashbillHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashbillHousing


ALTER TABLE NashbillHousing
Add OwnerSplitAddress Nvarchar(255);


Update NashbillHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashbillHousing
Add OwnerSplitCity Nvarchar(255);


Update NashbillHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashbillHousing
Add OwnerSplitState Nvarchar(255);


Update NashbillHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProject.dbo.NashbillHousing



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashbillHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'YES'
	   when SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashbillHousing


Update NashbillHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'YES'
	   when SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER by
					UniqueID
					) row_num
From PortfolioProject.dbo.NashbillHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress



Select *
From PortfolioProject.dbo.NashbillHousing





-- Delete Unused Columns
Select *
From PortfolioProject.dbo.NashbillHousing

ALTER TABLE PortfolioProject.dbo.NashbillHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashbillHousing
DROP COLUMN SaleDate

