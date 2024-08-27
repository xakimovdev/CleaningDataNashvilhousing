/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM dbo.NashvilleHousing

-- Standardize Date Format

SELECT SaleDateConverted, CAST(SaleDate as date)
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CAST(SaleDate as date)

------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

----------------------------------------------------------------

-- Breaking out Address into individual Columns (Address, City, State)

SELECT PropertyAddress
FROM dbo.NashvilleHousing

SELECT PropertyAddress 
          ,SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
	  ,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing


SELECT OwnerAddress
         ,SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress)-1)
	  --,REVERSE(OwnerAddress)
	  --,CHARINDEX(',', REVERSE(OwnerAddress))
	  --,SUBSTRING(REVERSE(OwnerAddress), 1, CHARINDEX(',', REVERSE(OwnerAddress))-2)
	  ,SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+2, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress)+1)-CHARINDEX(',', OwnerAddress)-2)
	  ,REVERSE(SUBSTRING(REVERSE(OwnerAddress), 1, CHARINDEX(',', REVERSE(OwnerAddress))-2))
	  --,CHARINDEX(',', OwnerAddress)
	  --,CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress)+1)
FROM NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
      ,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
      ,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousing


---------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
	  ,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END


----------------------------------------------------------------

-- Remove Duplicates

SELECT *
FROM NashvilleHousing

SELECT * 
      ,ROW_NUMBER() OVER (PARTITION BY ParcelId, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) as row_num
FROM NashvilleHousing



;WITH cte AS(
	      SELECT * 
		     ,ROW_NUMBER() OVER (PARTITION BY ParcelId, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) as row_num
	      FROM NashvilleHousing
	    )
DELETE 
FROM cte
WHERE row_num > 1



;WITH cte AS(
	      SELECT * 
		    ,DENSE_RANK() OVER (PARTITION BY ParcelId, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) as row_num
	      FROM NashvilleHousing
	    )
SELECT * FROM cte
WHERE row_num > 1

