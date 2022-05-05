SELECT *
FROM NashvilleHousing

-- Changing SaleDate datatype from 'datetime' to 'date', in order to change the format:

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE


-- Populating NULL PropertyAddresses with the PropertyAddress of the ones that have same ParcelID:

SELECT A.ParcelID, 
	   A.PropertyAddress, 
	   B.ParcelID, 
	   B.PropertyAddress,
	   ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A 
JOIN NashvilleHousing B ON A.ParcelID = B.ParcelID 
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL



UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A 
JOIN NashvilleHousing B ON A.ParcelID = B.ParcelID 
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


-- Breaking out PropertyAddress into individual columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
[Address] = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
[City] = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))
FROM NashvilleHousing	


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))


-- Breaking out OwnerAddress into individual columns (Address, City, State)

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Replacing 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant

SELECT SoldAsVacant,
	   CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	   END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE
					WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
				   END

--Checking if it worked:
SELECT DISTINCT(SoldAsVacant),
	   COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant



-- Removing duplicates:

WITH RowNumberCTE AS 
(
	SELECT *, ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueId
				 ) row_num
	FROM NashvilleHousing
)

DELETE 
FROM RowNumberCTE
WHERE row_num > 1



-- Deleting unused columns:

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
	        TaxDistrict,
			PropertyAddress,
			
ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate