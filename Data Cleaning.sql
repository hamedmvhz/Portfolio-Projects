-- We used Nashville Housing Data for Data Cleaning.xlsx file 
-- Standardizing Date Format: Usually just converting and uodating the table solves the issue.

Select CONVERT(Date, SaleDate) SaleDate
FROM NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate) 

-- Now, we check the table to see if the update worked

SELECT * 
FROM NashvilleHousing

-- It did not work, so we decide to create a new column

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate) 

-- Now, we check the table again. We have a new column named SaleDateConverted

-- Let's modify the property Address data

-- See null Address
SELECT PropertyAddress 
FROM NashvilleHousing
WHERE PropertyAddress is NULL

-- See all Null cells
SELECT * 
FROM NashvilleHousing
WHERE PropertyAddress is NULL

-- We notice that similar ParcellIDD have the same Property Adress. So we can use self join to get help
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Then, we update the table

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)
-- Let's first check the column PropertyAddress

SELECT PropertyAddress
FROM NashvilleHousing

-- We can see that the delimiter here is ','. So we want to devide it by this delimiter using SUBSTRING and  CHARINDEX
SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)) AS Address
FROM NashvilleHousing

-- But we have also ',' at the end. So we can remove it by  adding ' -1 '
SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS Address
FROM NashvilleHousing

-- Also, we need the address after ','
SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

-- Now, we need to update our table by adding these new columns
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- There is, also, another address column named OwnerAddress. This time we do it through an easier way by using PARSENAME. But remember that it works with '.' , so we should replace ',' with '.'


SELECT 
  PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3),
  PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2),
  PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1) 
FROM NashvilleHousing

-- Now, we need to update our table by adding these new columns

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)


-- In the column "SoldAsVacant" there are Y,N,Yes and No. We can check it 

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

-- So, we need to change Y and N to Yes and No by using Case Statement

SELECT  SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing

-- Now, we need to update our table by adding these new column

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Now, we are going to remove duplicates. First we use Row_Number to check if there are duplicates

WITH RowNumCTE AS 
(
SELECT *,
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
)
SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress

-- We see that there are 104 duplicated rows. So, we just need to replace "SELECT * " with " DELETE"
WITH RowNumCTE AS 
(
SELECT *,
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
)
DELETE 
FROM RowNumCTE
WHERE row_num >1

-- Now, we want to delete unused columns. ** It is good to know that instead of what we do here, we can create view a new table.

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress,
            SaleDate,
			OwnerAddress,
			TaxDistrict
