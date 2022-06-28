WITH results as(

SELECT b.Vendor,	
       b.Bid_Number,	
       b.Final_Price,
       b.Initial_Price,
       b.Supplier,	
       b.Awarded,	
       b.L1,	
       b.L2,	
       b.L3,
       STRING_AGG(b.Flagged,' ') Flagged,
       STRING_AGG(b.Same_initial_price_different_supplier,' ') Same_initial_price_different_supplier,
       STRING_AGG(b.Same_final_price_different_supplier,' ') Same_final_price_different_supplier,
       STRING_AGG(b._50percent_of_initial_price,' ') _50percent_of_initial_price,
       STRING_AGG(b._50percent_of_final_price,' ') _50percent_of_final_price,
       STRING_AGG(b.Final_price_higher_than_initial,' ') Final_price_higher_than_initial,
       STRING_AGG(b._75percent_of_initial_price,' ') _75percent_of_initial_price,
       STRING_AGG(b._75percent_of_final_price,' ') _75percent_of_final_price,
       STRING_AGG(b._33percent_of_initial_price,' ') _33percent_of_initial_price,
       STRING_AGG(b._33percent_of_final_price,' ') _33percent_of_final_price,
       STRING_AGG(b.Same_supplier,' ') Same_supplier
FROM(
    SELECT  a.*,
            CASE WHEN 'Yes' IN (a.Same_initial_price_different_supplier, 
                                a.Same_final_price_different_supplier, 
                                a._50percent_of_initial_price, 
                                a._50percent_of_final_price, 
                                a.Final_price_higher_than_initial, 
                                a._75percent_of_initial_price,
                                a._75percent_of_final_price,
                                a._33percent_of_initial_price,
                                a._33percent_of_final_price) THEN 'Yes' ELSE 'No' END Flagged
    FROM(
        SELECT DISTINCT t1.Vendor,	
                        t1.Bid_Number,	
                        ROUND(t1.Final_Price,2) Final_Price,
                        ROUND(t1.Initial_Price,2) Initial_Price,
                        t1.Supplier,	
                        t1.Awarded,	
                        t1.L1,	
                        t1.L2,	
                        t1.L3, 
                        CASE WHEN ROUND(t1.Initial_Price,2) = ROUND(t2.Initial_Price,2) AND t1.Supplier <>  t2.Supplier then 'Yes' else 'No' end Same_initial_price_different_supplier,
                        CASE WHEN ROUND(t1.Final_Price,2) = ROUND(t2.Final_Price,2) AND t1.Supplier <>  t2.Supplier then 'Yes' else 'No' end Same_final_price_different_supplier,
                        CASE WHEN t1.Supplier = t2.Supplier then 'Yes' else 'No' end Same_supplier,
                        CASE WHEN ROUND(t1.Initial_Price,2) = ROUND(t2.Initial_Price,2)*0.5 OR ROUND(t2.Initial_Price,2) = ROUND(t1.Initial_Price,2)*0.5 then 'Yes' else 'No' end _50percent_of_initial_price,
                        CASE WHEN ROUND(t1.Final_Price,2) = ROUND(t2.Final_Price,2)*0.5 OR ROUND(t2.Final_Price,2) = ROUND(t1.Final_Price,2)*0.5 then 'Yes' else 'No' end _50percent_of_final_price,
                        CASE WHEN ROUND(t1.Initial_Price,2) = ROUND(t2.Initial_Price,2)*0.75 OR ROUND(t2.Initial_Price,2) = ROUND(t1.Initial_Price,2)*0.75 then 'Yes' else 'No' end _75percent_of_initial_price,
                        CASE WHEN ROUND(t1.Final_Price,2) = ROUND(t2.Final_Price,2)*0.75 OR ROUND(t2.Final_Price,2) = ROUND(t1.Final_Price,2)*0.75 then 'Yes' else 'No' end _75percent_of_final_price,
                        CASE WHEN ROUND(t1.Initial_Price,2) = ROUND(t2.Initial_Price,2)*0.33 OR ROUND(t2.Initial_Price,2) = ROUND(t1.Initial_Price,2)*0.33 then 'Yes' else 'No' end _33percent_of_initial_price,
                        CASE WHEN ROUND(t1.Final_Price,2) = ROUND(t2.Final_Price,2)*0.33 OR ROUND(t2.Final_Price,2) = ROUND(t1.Final_Price,2)*0.33 then 'Yes' else 'No' end _33percent_of_final_price,
                        CASE WHEN ROUND(t1.Final_Price,2) > ROUND(t1.Initial_Price,2) then 'Yes' else 'No' end Final_price_higher_than_initial
                        /*CASE WHEN (ROUND(t1.Final_Price,2) BETWEEN ROUND(t2.Final_Price,2)*0.45 AND ROUND(t2.Final_Price,2)*0.55 
                                                 OR ROUND(t2.Final_Price,2) BETWEEN ROUND(t1.Final_Price,2)*0.45 AND ROUND(t1.Final_Price,2)*0.55)
                                                 AND ROUND(t1.Final_Price,2) <> ROUND(t2.Final_Price,2)*0.5 
                                                 AND ROUND(t2.Final_Price,2) <> ROUND(t1.Final_Price,2)*0.5
                                                 then 'Yes' else 'No' end Final_price_between_44_55_percent*/
        FROM vendor_prices t1
        LEFT OUTER JOIN  vendor_prices t2
        ON t2.Bid_Number = t1.Bid_Number
        AND t2.Vendor <> t1.Vendor
        ORDER BY t1.Bid_Number 
        ) a
    ) b
    --WHERE b.Flagged = 'Yes' --_n = 1
    GROUP BY b.Vendor,	
             b.Bid_Number,	
             b.Final_Price,
             b.Initial_Price,
             b.Supplier,	
             b.Awarded,	
             b.L1,	
             b.L2,	
             b.L3
)
,
results2 as(
SELECT Vendor,	
       Bid_Number,	
       ROUND(Final_Price,2) Final_Price,
       ROUND(Initial_Price,2) Initial_Price,
       Supplier,	
       Awarded,	
       L1,	
       L2,	
       L3, 
       CASE WHEN REGEXP_CONTAINS(Same_initial_price_different_supplier, 'Yes') THEN 1 ELSE 0 END Same_initial_price_different_supplier,
       CASE WHEN REGEXP_CONTAINS(Same_final_price_different_supplier, 'Yes') THEN 1 ELSE 0 END Same_final_price_different_supplier,
       CASE WHEN REGEXP_CONTAINS(_50percent_of_initial_price, 'Yes') THEN 1 ELSE 0 END _50percent_of_initial_price,
       CASE WHEN REGEXP_CONTAINS(_50percent_of_final_price, 'Yes') THEN 1 ELSE 0 END _50percent_of_final_price,
       CASE WHEN REGEXP_CONTAINS(_75percent_of_initial_price, 'Yes') THEN 1 ELSE 0 END _75percent_of_initial_price,
       CASE WHEN REGEXP_CONTAINS(_75percent_of_final_price, 'Yes') THEN 1 ELSE 0 END _75percent_of_final_price,
       CASE WHEN REGEXP_CONTAINS(_33percent_of_initial_price, 'Yes') THEN 1 ELSE 0 END _33percent_of_initial_price,
       CASE WHEN REGEXP_CONTAINS(_33percent_of_final_price, 'Yes') THEN 1 ELSE 0 END _33percent_of_final_price,
       CASE WHEN REGEXP_CONTAINS(Final_price_higher_than_initial, 'Yes') THEN 1 ELSE 0 END Final_price_higher_than_initial,
       --CASE WHEN REGEXP_CONTAINS(Final_price_between_44_55_percent, 'Yes') THEN 1 ELSE 0 END Final_price_between_44_55_percent,
       CASE WHEN REGEXP_CONTAINS(Same_supplier, 'Yes') THEN 1 ELSE 0 END Same_supplier,
       CASE WHEN REGEXP_CONTAINS(Flagged, 'Yes') THEN 1 ELSE 0 END Flagged
       
FROM results 
)

SELECT r.*,
       SUM(Same_initial_price_different_supplier+
       Same_final_price_different_supplier+
       _50percent_of_initial_price+
       _50percent_of_final_price+
       _33percent_of_initial_price+
       _33percent_of_final_price+
       _75percent_of_initial_price+
       _75percent_of_final_price+
       Final_price_higher_than_initial) OVER(PARTITION BY Bid_Number) Lot_flag_count,

       (Same_initial_price_different_supplier+
       Same_final_price_different_supplier+
       _50percent_of_initial_price+
       _50percent_of_final_price+
       _33percent_of_initial_price+
       _33percent_of_final_price+
       _75percent_of_initial_price+
       _75percent_of_final_price+
       Final_price_higher_than_initial) Bid_flag_count
FROM results2 r