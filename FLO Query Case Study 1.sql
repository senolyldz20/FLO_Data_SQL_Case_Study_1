-- 1. Customers isimli bir veritabanı ve verilen veri setindeki değişkenleri içerecek FLO isimli bir tablo oluşturunuz.
SELECT DISTINCT
    master_id
FROM FLO

-- 2. Kaç farklı müşterinin alışveriş yaptığını gösterecek sorguyu yazınız.
SELECT
    COUNT(DISTINCT master_id) AS MUSTERI_SAYISI
FROM
    FLO

-- 3. Toplam yapılan alışveriş sayısı ve ciroyu getirecek sorguyu yazınız.
SELECT
    SUM(order_num_total_ever_offline + FLO.order_num_total_ever_online) AS TOPLAM_SIPARIS,
    ROUND(SUM(customer_value_total_ever_offline + FLO.customer_value_total_ever_online), 2) AS TOPLAM_CIRO
FROM FLO


-- 4. Alışveriş başına ortalama ciroyu getirecek sorguyu yazınız.
SELECT
    (SUM(customer_value_total_ever_online) + SUM(customer_value_total_ever_offline)) /
    (SUM(order_num_total_ever_online) + SUM(order_num_total_ever_offline)) AS average_revenue_per_transaction
FROM FLO;


-- 5. En son alışveriş yapılan kanal (last_order_channel) üzerinden yapılan alışverişlerin toplam ciro ve alışveriş sayılarını
-- getirecek sorguyu yazınız.
SELECT
    last_order_channel,
    SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS Toplam_Ciro,
    SUM(order_num_total_ever_online + order_num_total_ever_offline) AS Toplam_Alısveris
FROM FLO
GROUP BY last_order_channel

-- 6. Store type kırılımında elde edilen toplam ciroyu getiren sorguyu yazınız.
SELECT
    store_type,
    ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online), 2) AS Toplam_Ciro
FROM FLO
GROUP BY store_type


-- 7. Yıl kırılımında alışveriş sayılarını getirecek sorguyu yazınız (Yıl olarak müşterinin ilk alışveriş tarihi (first_order_date) yılını
-- baz alınız)
SELECT
    YEAR(first_order_date) AS YIL,
    SUM(order_num_total_ever_online + order_num_total_ever_offline) AS Toplam_Alısverıs
FROM FLO
GROUP BY YEAR(first_order_date)
ORDER BY 2 DESC


--8. En son alışveriş yapılan kanal kırılımında alışveriş başına ortalama ciroyu hesaplayacak sorguyu yazınız.
SELECT
    last_order_channel,
    ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online),2) AS Toplam_Ciro,
    SUM(order_num_total_ever_offline + order_num_total_ever_online) AS Toplam_Siparis,
    ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online) / SUM(order_num_total_ever_offline + order_num_total_ever_online), 2) AS Verimlilik
FROM FLO
GROUP BY last_order_channel
ORDER BY 4 DESC

-- 9. Son 12 ayda en çok ilgi gören kategoriyi getiren sorguyu yazınız.
SELECT
    interested_in_categories,
    COUNT(*) Frekans_Bilgisi
FROM FLO
GROUP BY interested_in_categories
ORDER BY 2 DESC

-- 10. En çok tercih edilen store_type bilgisini getiren sorguyu yazınız.
SELECT
    store_type,
    COUNT(*) Frekans_Bilgisi
FROM FLO
GROUP BY store_type
ORDER BY 2 DESC

-- 11. En son alışveriş yapılan kanal (last_order_channel) bazında, en çok ilgi gören kategoriyi ve bu kategoriden ne kadarlık
-- alışveriş yapıldığını getiren sorguyu yazınız.
SELECT DISTINCT
    F.last_order_channel,
    (
        SELECT TOP 1
            interested_in_categories
        FROM FLO AS SubF
        WHERE SubF.last_order_channel = F.last_order_channel
        GROUP BY interested_in_categories
        ORDER BY SUM(SubF.order_num_total_ever_online + SubF.order_num_total_ever_offline) DESC
    ) AS top_interested_category,
    (
        SELECT TOP 1
            SUM(SubF.order_num_total_ever_online + SubF.order_num_total_ever_offline)
        FROM FLO AS SubF
        WHERE SubF.last_order_channel = F.last_order_channel
        GROUP BY interested_in_categories
        ORDER BY SUM(SubF.order_num_total_ever_online + SubF.order_num_total_ever_offline) DESC
    ) AS top_category_order_sum
FROM FLO AS F;

-- 12. En çok alışveriş yapan kişinin ID’ sini getiren sorguyu yazınız.
SELECT TOP 1
    master_id,
    SUM(order_num_total_ever_online + order_num_total_ever_offline) AS Toplam_Alısveris
FROM FLO
GROUP BY master_id
ORDER BY 2 DESC


-- 13. En çok alışveriş yapan kişinin alışveriş başına ortalama cirosunu ve alışveriş yapma gün ortalamasını (alışveriş sıklığını)
-- getiren sorguyu yazınız.

SELECT
    F1.master_id,
    ROUND((F1.Toplam_Ciro / F1.Toplam_Siparis), 2) AS Siparis_Başına_Ortalama,
    ROUND((DATEDIFF(DAY, first_order_date, last_order_date) / F1.Toplam_Siparis), 1) AS Alışveris_Gün_Ort
FROM
(
SELECT TOP 1
    master_id,
    first_order_date,
    last_order_date,
    SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS Toplam_Ciro,
    SUM(order_num_total_ever_offline + order_num_total_ever_online) AS Toplam_Siparis
FROM FLO
GROUP BY master_id, first_order_date, last_order_date
ORDER BY Toplam_Ciro DESC
) AS F1

-- 14. En çok alışveriş yapan (ciro bazında) ilk 100 kişinin alışveriş yapma gün ortalamasını (alışveriş sıklığını) getiren sorguyu
-- yazınız.

SELECT
    F1.master_id,
    F1.Toplam_Siparis,
    ROUND((F1.Toplam_Ciro / F1.Toplam_Siparis), 2) AS Siparis_Başına_Ortalama,
    ROUND((DATEDIFF(DAY, first_order_date, last_order_date) / F1.Toplam_Siparis),1) Alısveris_Gün_Ort
FROM
    (
    SELECT TOP 100
    master_id,
    first_order_date,
    last_order_date,
    SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS Toplam_Ciro,
    SUM(order_num_total_ever_online + order_num_total_ever_offline) AS Toplam_Siparis
    FROM FLO
    GROUP BY master_id, first_order_date, last_order_date ORDER BY Toplam_Ciro DESC
    ) F1


-- 15. En son alışveriş yapılan kanal (last_order_channel) kırılımında en çok alışveriş yapan müşteriyi getiren sorguyu yazınız.
SELECT DISTINCT last_order_channel,

(
	SELECT top 1 master_id
	FROM FLO  WHERE last_order_channel=f.last_order_channel
	group by master_id
	order by
	SUM(customer_value_total_ever_offline+customer_value_total_ever_online) desc
) EN_COK_ALISVERIS_YAPAN_MUSTERI,
(
	SELECT top 1 SUM(customer_value_total_ever_offline+customer_value_total_ever_online)
	FROM FLO  WHERE last_order_channel=f.last_order_channel
	group by master_id
	order by
	SUM(customer_value_total_ever_offline+customer_value_total_ever_online) desc
) CIRO
FROM FLO F


-- 16. En son alışveriş yapan kişinin ID’ sini getiren sorguyu yazınız. (Max son tarihte birden fazla alışveriş yapan ID bulunmakta.
-- Bunları da getiriniz.

SELECT master_id,last_order_date FROM FLO
WHERE last_order_date=(SELECT MAX(last_order_date) FROM FLO)





