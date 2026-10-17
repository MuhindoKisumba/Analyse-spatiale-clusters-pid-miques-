-- Trouver dans quelle zone de santé se trouve un cas
SELECT z.name AS zone_sante, COUNT(c.id) AS total_cas
FROM cas_epidemio c
JOIN zones_sante z
ON ST_Contains(z.geom, c.geom)
GROUP BY z.name
ORDER BY total_cas DESC;
