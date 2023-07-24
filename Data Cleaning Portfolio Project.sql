
SELECT *
FROM PortfolioProyect..NashvilleHousing

--------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProyect..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted= CONVERT(Date, SaleDate)


--------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProyect..NashvilleHousing
-- WHERE PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProyect..NashvilleHousing a
JOIN PortfolioProyect..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProyect..NashvilleHousing a
JOIN PortfolioProyect..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--------------------------------------------------------------------------------------

--  Breaking out Address into individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProyect..NashvilleHousing
-- WHERE PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)) as Address
FROM PortfolioProyect..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress))


SELECT OwnerAddress
FROM PortfolioProyect..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3), 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
FROM PortfolioProyect..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)



--------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProyect..NashvilleHousing
Group by SoldAsVacant
Order by 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant= 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProyect..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant= 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS (
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, 
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
				UniqueID
				) row_num
			 
FROM PortfolioProyect..NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



--------------------------------------------------------------------------------------

-- Delete Unused Columns 


ALTER TABLE PortfolioProyect..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


