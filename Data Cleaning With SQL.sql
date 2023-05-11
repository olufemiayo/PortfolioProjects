--DATA CLEANING WITH SQL
select *
from PortfolioProject..housing$

--1. Standardize Date 
select SaleDate
from PortfolioProject..housing$

alter table PortfolioProject..housing$
add dateconverted date

update PortfolioProject..housing$
set dateconverted = convert(date, SaleDate)

select dateconverted
from PortfolioProject..housing$

--2. Populate Property address data
select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..housing$ a
join PortfolioProject..housing$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]


update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..housing$ a
join PortfolioProject..housing$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]


--3.Breaking out address into individual columns
select c.PropertyAddress, c.ParcelID, d.OwnerAddress,d.ParcelID, isnull(d.OwnerAddress, c.PropertyAddress)
from PortfolioProject..housing$ c
join PortfolioProject..housing$ d
on c.ParcelID=d.ParcelID
where d.OwnerAddress is null

update d
set d.OwnerAddress=isnull(d.OwnerAddress, c.PropertyAddress)
from PortfolioProject..housing$ c
join PortfolioProject..housing$ d
on c.ParcelID=d.ParcelID
where d.OwnerAddress is null
---Now Break Owner address down 

select 
parsename(replace(OwnerAddress, ',','.'),3),
parsename(replace(OwnerAddress, ',','.'),2),
parsename(replace(OwnerAddress, ',','.'),1)
from PortfolioProject..housing$

alter table PortfolioProject..housing$
add OwnerHome nvarchar(255)
alter table PortfolioProject..housing$
add OwnerCity nvarchar(255)
alter table PortfolioProject..housing$
add OwnerState nvarchar(255)

update PortfolioProject..housing$
set ownerHome = parsename(replace(OwnerAddress, ',','.'),3)

update PortfolioProject..housing$
set ownerCity = parsename(replace(OwnerAddress, ',','.'),2)

update PortfolioProject..housing$
set ownerState = parsename(replace(OwnerAddress, ',','.'),1)

--4. Change Y and N to Yes and No
select distinct(SoldAsVacant), count(soldasvacant) num
from PortfolioProject..housing$
group by SoldAsVacant
order by num desc

select SoldAsVacant,
       case when SoldAsVacant='N' then 'No'
	        when SoldAsVacant='Y' then 'Yes'
			else SoldAsVacant
			end
from PortfolioProject..housing$

update PortfolioProject..housing$
set SoldAsVacant =  case when SoldAsVacant='N' then 'No'
	        when SoldAsVacant='Y' then 'Yes'
			else SoldAsVacant
			end
	        
--5. Remove Duplicates
with rowNumCTE as (
select *,
       ROW_NUMBER() over(
	   partition by ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by
					UniqueID) rowNum
from PortfolioProject..housing$)
--delete 
select *
from rowNumCTE
where rowNum > 1
--order by PropertyAddress

--6. Delete Unused Columns

select *
from PortfolioProject..housing$

alter table PortfolioProject..housing$
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict