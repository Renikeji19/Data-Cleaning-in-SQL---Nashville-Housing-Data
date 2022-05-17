-----CLEANING DATA IN SQL QUERIES

SELECT *
FROM NashvilleHousing




----STANDARDIZE SALE DATE

SELECT SaleDate
FROM NashvilleHousing

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHousing

Update NashvilleHousing
SET SaleDate=CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousing




----POPULATE PROPERTY ADDRESS DATA

SELECT PropertyAddress
FROM NashvilleHousing

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress is null

SELECT *
FROM NashvilleHousing
---WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT A.ParcelID, B.ParcelID, A.PropertyAddress, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress IS NULL

Update A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress IS NULL


-----BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM NashvilleHousing
---WHERE PropertyAddress is null
---ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT*
FROM NashvilleHousing

----or
SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) 

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT*
FROM NashvilleHousing



------CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT" FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END



---------REMOVE DUPLICATES

SELECT*,
      ROW_NUMBER() OVER (
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY 
				        UniqueID
						) row_num
FROM NashvilleHousing
ORDER BY ParcelID


WITH ROWNUMCTE AS(
SELECT*,
      ROW_NUMBER() OVER (
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY 
				        UniqueID
						) row_num
FROM NashvilleHousing
----ORDER BY ParcelID
)
SELECT*
FROM ROWNUMCTE
WHERE Row_num>1
ORDER BY PropertyAddress

----this highlights 104 duplicate rows, so we introduce DELETE to remove them

WITH ROWNUMCTE AS(
SELECT*,
      ROW_NUMBER() OVER (
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY 
				        UniqueID
						) row_num
FROM NashvilleHousing
----ORDER BY ParcelID
)
DELETE
FROM ROWNUMCTE
WHERE Row_num>1
---ORDER BY PropertyAddress




-----DELETE UNUSED COLUMNS

SELECT*
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict