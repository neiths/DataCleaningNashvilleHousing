select *
from PortfolioProject..NashvilleHousing

-- Standardize Date Format

-- In a column Date is not like I want 
select SaleDate, convert(date,SaleDate)
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing 
SET SaleDate = convert(date,SaleDate)
--apply this line above is not changing data

-- add a new column
Alter Table PortfolioProject..NashvilleHousing
add SaleDateConverted Date;

-- update data for a new column
Update PortfolioProject..NashvilleHousing 
SET SaleDateConverted = convert(date,SaleDate)

-- a new column appears next a last column
select *
from PortfolioProject..NashvilleHousing

-- Populate property address Data

-- check NULLs
select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

select *
from PortfolioProject..NashvilleHousing
order by ParcelID
-- if the same ParcelID has the same PropertyAddress

-- function lets you return an alternative value when an expression is NULL
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
, ISNULL(a.PropertyAddress, b.PropertyAddress) -- a new column if a.property null copy b.property
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- all null cells are removed
select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null

-- breaking out into individual columns (address, city, State)
  
select PropertyAddress
from PortfolioProject..NashvilleHousing
-- 142  COBBLESTONE PLACE DR, GOODLETTSVILLE
-- this string is seperated by comma
-- now split it into 2 substrings

select
SUBSTRING(PropertyAddress, 1, ( CHARINDEX(',', PropertyAddress)) - 1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

-- add new columns

Alter Table PortfolioProject..NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Alter Table PortfolioProject..NashvilleHousing
add PropertySplitCity Nvarchar(255);

-- update data for the new columns
Update PortfolioProject..NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, ( CHARINDEX(',', PropertyAddress)) - 1 )

Update PortfolioProject..NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



select *
from PortfolioProject..NashvilleHousing

select OwnerAddress
from PortfolioProject..NashvilleHousing
where OwnerAddress is not null

-- PARSENAME(OwnerAddress, index column) works with period and backwards order
select
PARSENAME(replace(OwnerAddress,',','.'), 3),
PARSENAME(replace(OwnerAddress,',','.'), 2),
PARSENAME(replace(OwnerAddress,',','.'), 1)
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Alter Table PortfolioProject..NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Alter Table PortfolioProject..NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'), 3)

Update PortfolioProject..NashvilleHousing 
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'), 2)

Update PortfolioProject..NashvilleHousing 
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'), 1)

select *
from PortfolioProject..NashvilleHousing


--  change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant) as Count
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..NashvilleHousing
where SoldAsVacant = 'Y' or SoldAsVacant = 'N'

update PortfolioProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end



-- Remove Duplicates

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--DELETE
--From RowNumCTE
--Where row_num > 1


--- Delete Unused columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate